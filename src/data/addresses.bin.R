# Packages: dplyr (new enough for recode_values), httr2, vroom, readr.
# pipe("cat", "wb") is the loader contract.
# Clear src/.observablehq/cache/data/addresses.bin to force a fresh pull.

suppressPackageStartupMessages({
  library(dplyr)
  library(httr2)
  library(readr)
  library(vroom)
})

# ---- Download AddressPoint ----
message("Requesting AddressPoint row count")

count_resp <- request("https://data.cityofnewyork.us/resource/uf93-f8nk.json") |>
  req_url_query(`$select` = "count(*)") |>
  req_user_agent("NYCAddressGridDashboard/1.0 (R httr2)") |>
  req_timeout(120) |>
  req_perform()

expected_n <- as.integer(resp_body_json(count_resp)[[1]]$count)
message("AddressPoint rows: ", expected_n)

page_size <- 250000L
offset <- 0L
page_dfs <- list()

while (offset < expected_n) {
  message("Downloading the_geom and boroughcode at offset ", offset)
  page_path <- tempfile(fileext = ".csv")
  request("https://data.cityofnewyork.us/resource/uf93-f8nk.csv") |>
    req_url_query(
      `$select` = "the_geom,boroughcode",
      `$order` = ":id",
      `$limit` = page_size,
      `$offset` = offset
    ) |>
    req_user_agent("NYCAddressGridDashboard/1.0 (R httr2)") |>
    req_timeout(600) |>
    req_perform(path = page_path)

  message("Downloaded ", file.info(page_path)$size, " bytes")

  page_df <- vroom(
    page_path,
    delim = ",",
    col_types = cols(
      the_geom = col_character(),
      boroughcode = col_integer()
    ),
    show_col_types = FALSE,
    progress = FALSE
  )
  stopifnot(nrow(page_df) > 0L)
  page_dfs[[length(page_dfs) + 1L]] <- page_df
  offset <- offset + nrow(page_df)
}

addresses_raw_df <- bind_rows(page_dfs)

stopifnot(nrow(addresses_raw_df) == expected_n)

# ---- Parse coordinates ----
addresses_df <- addresses_raw_df |>
  mutate(
    lon = as.numeric(sub(
      "^POINT \\(([-0-9.]+)[[:space:]]+([-0-9.]+)\\)$",
      "\\1",
      the_geom
    )),
    lat = as.numeric(sub(
      "^POINT \\(([-0-9.]+)[[:space:]]+([-0-9.]+)\\)$",
      "\\2",
      the_geom
    ))
  ) |>
  select(lon, lat, boroughcode)

stopifnot(
  !anyNA(addresses_df$lon),
  !anyNA(addresses_df$lat),
  all(addresses_df$boroughcode %in% 1L:5L),
  min(addresses_df$lon) > -74.3,
  max(addresses_df$lon) < -73.6,
  min(addresses_df$lat) > 40.4,
  max(addresses_df$lat) < 41.0
)

# ---- Synthetic metrics ----
gaussian_kernel <- function(lon, lat, center_lon, center_lat, sigma_lon, sigma_lat = sigma_lon) {
  exp(-(
    (lon - center_lon)^2 / (2 * sigma_lon^2) +
      (lat - center_lat)^2 / (2 * sigma_lat^2)
  ))
}

address_metrics_df <- addresses_df |>
  mutate(
    poverty_borough_baseline = recode_values(
      boroughcode,
      1 ~ -0.15,
      2 ~ 0.30,
      3 ~ 0.06,
      4 ~ 0.00,
      5 ~ 0.08,
      unmatched = "error"
    ),
    poverty_raw =
      poverty_borough_baseline +
      1.40 * gaussian_kernel(lon, lat, -73.910, 40.818, 0.022) +
      1.25 * gaussian_kernel(lon, lat, -73.905, 40.665, 0.020) +
      1.10 * gaussian_kernel(lon, lat, -73.748, 40.668, 0.024) +
      0.95 * gaussian_kernel(lon, lat, -74.145, 40.635, 0.018) -
      0.90 * gaussian_kernel(lon, lat, -73.956, 40.773, 0.014) -
      0.85 * gaussian_kernel(lon, lat, -73.976, 40.787, 0.014) -
      0.75 * gaussian_kernel(lon, lat, -73.979, 40.671, 0.012) -
      0.70 * gaussian_kernel(lon, lat, -73.845, 40.719, 0.014),
    park_access_raw =
      gaussian_kernel(lon, lat, -73.9654, 40.7829, 0.020) +
      gaussian_kernel(lon, lat, -73.9690, 40.6602, 0.015) +
      gaussian_kernel(lon, lat, -73.8407, 40.7397, 0.018) +
      gaussian_kernel(lon, lat, -73.8080, 40.8670, 0.020) +
      gaussian_kernel(lon, lat, -73.8860, 40.8978, 0.016) +
      gaussian_kernel(lon, lat, -73.8550, 40.7020, 0.014) +
      gaussian_kernel(lon, lat, -73.9330, 40.5960, 0.014) +
      gaussian_kernel(lon, lat, -73.9250, 40.8725, 0.012) +
      gaussian_kernel(lon, lat, -73.8770, 40.8580, 0.013) +
      gaussian_kernel(lon, lat, -74.1135, 40.6180, 0.012),
    heat_inland_raw =
      1.30 * gaussian_kernel(lon, lat, -73.890, 40.848, 0.028) +
      1.20 * gaussian_kernel(lon, lat, -73.935, 40.662, 0.026) +
      1.15 * gaussian_kernel(lon, lat, -73.825, 40.715, 0.030),
    heat_vulnerability_raw = heat_inland_raw + 0.65 / (park_access_raw + 0.22),
    south_of_96th = 1 / (1 + exp(160 * (lat - 40.795))),
    transit_access_raw =
      1.70 * (boroughcode == 1L) * south_of_96th *
        gaussian_kernel(lon, lat, -73.985, 40.748, 0.018, 0.050) +
      1.25 * gaussian_kernel(lon, lat, -73.984, 40.693, 0.012) +
      1.10 * gaussian_kernel(lon, lat, -73.883, 40.755, 0.011) +
      1.15 * gaussian_kernel(lon, lat, -73.794, 40.702, 0.013) +
      1.05 * gaussian_kernel(lon, lat, -74.073, 40.644, 0.011)
  )

# ---- Rescale metrics to 0-100 ----
rescale_0_100 <- function(values) {
  value_min <- min(values)
  value_max <- max(values)
  100 * (values - value_min) / (value_max - value_min)
}

address_points_df <- address_metrics_df |>
  transmute(
    lon,
    lat,
    poverty = rescale_0_100(poverty_raw),
    park_access = rescale_0_100(park_access_raw),
    heat_vulnerability = rescale_0_100(heat_vulnerability_raw),
    transit_access = rescale_0_100(transit_access_raw)
  )

stopifnot(
  min(address_points_df$poverty) >= 0,
  max(address_points_df$poverty) <= 100,
  min(address_points_df$park_access) >= 0,
  max(address_points_df$park_access) <= 100,
  min(address_points_df$heat_vulnerability) >= 0,
  max(address_points_df$heat_vulnerability) <= 100,
  min(address_points_df$transit_access) >= 0,
  max(address_points_df$transit_access) <= 100
)

message(
  "Points: ", nrow(address_points_df),
  " lon ", min(address_points_df$lon), " to ", max(address_points_df$lon),
  " lat ", min(address_points_df$lat), " to ", max(address_points_df$lat),
  " poverty ", min(address_points_df$poverty), " to ", max(address_points_df$poverty),
  " park_access ", min(address_points_df$park_access), " to ", max(address_points_df$park_access),
  " heat_vulnerability ", min(address_points_df$heat_vulnerability), " to ", max(address_points_df$heat_vulnerability),
  " transit_access ", min(address_points_df$transit_access), " to ", max(address_points_df$transit_access)
)

# ---- Write little-endian points ----
# stdout is the loader output. The header names are the schema.
# The float32 body follows, little-endian, in that column order.
binary_column_names <- c(
  "lon", "lat", "poverty", "park_access", "heat_vulnerability", "transit_access"
)
stopifnot(identical(names(address_points_df), binary_column_names))

output_con <- pipe("cat", "wb")
writeBin(as.integer(nrow(address_points_df)), output_con, size = 4L, endian = "little")
writeBin(as.integer(length(binary_column_names)), output_con, size = 4L, endian = "little")
for (column_name in binary_column_names) {
  column_name_bytes <- charToRaw(column_name)
  writeBin(as.integer(length(column_name_bytes)), output_con, size = 4L, endian = "little")
  writeBin(column_name_bytes, output_con)
}
writeBin(
  as.numeric(t(as.matrix(address_points_df))),
  output_con,
  size = 4L,
  endian = "little"
)
flush(output_con)
close(output_con)
