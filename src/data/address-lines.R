# Packages: dplyr (new enough for recode_values), httr2, vroom, readr.
# Reads the existing float32 points and writes one display line per row to stdout.
# Does not rewrite addresses.bin.

suppressPackageStartupMessages({
  library(dplyr)
  library(httr2)
  library(readr)
  library(vroom)
})

# ---- Read existing float32 lon/lat ----
message("Reading existing points")

points_con <- file("src/.observablehq/cache/data/addresses.bin", "rb")
point_count <- readBin(points_con, integer(), n = 1L, size = 4L, endian = "little")
column_count <- readBin(points_con, integer(), n = 1L, size = 4L, endian = "little")
column_names <- character(column_count)
for (column in seq_len(column_count)) {
  name_length <- readBin(points_con, integer(), n = 1L, size = 4L, endian = "little")
  column_names[[column]] <- rawToChar(readBin(points_con, raw(), n = name_length))
}
packed <- readBin(
  points_con,
  numeric(),
  n = point_count * column_count,
  size = 4L,
  endian = "little"
)
close(points_con)

stopifnot(
  identical(
    column_names,
    c("lon", "lat", "poverty", "park_access", "heat_vulnerability", "transit_access")
  ),
  length(packed) == point_count * column_count
)

existing_lon <- packed[seq(1L, by = column_count, length.out = point_count)]
existing_lat <- packed[seq(2L, by = column_count, length.out = point_count)]
message("Existing points: ", point_count)

# ---- Download AddressPoint address fields ----
message("Requesting AddressPoint row count")

count_resp <- request("https://data.cityofnewyork.us/resource/uf93-f8nk.json") |>
  req_url_query(`$select` = "count(*)") |>
  req_user_agent("NYCAddressGridDashboard/1.0 (R httr2)") |>
  req_timeout(120) |>
  req_perform()

expected_n <- as.integer(resp_body_json(count_resp)[[1]]$count)
message("AddressPoint rows: ", expected_n)
stopifnot(expected_n == point_count)

page_size <- 250000L
offset <- 0L
page_dfs <- list()

while (offset < expected_n) {
  message("Downloading address fields at offset ", offset)
  page_path <- tempfile(fileext = ".csv")
  request("https://data.cityofnewyork.us/resource/uf93-f8nk.csv") |>
    req_url_query(
      `$select` = "the_geom,house_number,house_number_suffix,full_street_name,boroughcode,zipcode",
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
      house_number = col_character(),
      house_number_suffix = col_character(),
      full_street_name = col_character(),
      boroughcode = col_integer(),
      zipcode = col_character()
    ),
    show_col_types = FALSE,
    progress = FALSE
  )
  stopifnot(nrow(page_df) > 0L)
  page_dfs[[length(page_dfs) + 1L]] <- page_df
  offset <- offset + nrow(page_df)
}

addresses_raw_df <- bind_rows(page_dfs)
stopifnot(nrow(addresses_raw_df) == point_count)

# ---- Parse coordinates and check row alignment ----
# The float file was written in :id order. Float32 lon/lat are not unique, so
# a coordinate join would match some rows more than once. Each downloaded row
# has to land on the existing point at the same index.

quantize_f32 <- function(values) {
  raw_con <- rawConnection(raw(0), open = "w+b")
  writeBin(as.numeric(values), raw_con, size = 4L, endian = "little")
  seek(raw_con, 0L)
  quantized <- readBin(raw_con, numeric(), n = length(values), size = 4L, endian = "little")
  close(raw_con)
  quantized
}

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
    )),
    lon_f32 = quantize_f32(lon),
    lat_f32 = quantize_f32(lat)
  )

stopifnot(!anyNA(addresses_df$lon), !anyNA(addresses_df$lat))

mismatched_row <- which(
  addresses_df$lon_f32 != existing_lon | addresses_df$lat_f32 != existing_lat
)
if (length(mismatched_row) > 0L) {
  i <- mismatched_row[[1]]
  stop(
    length(mismatched_row), " address rows do not match the existing lon/lat at the same index. First is row ",
    i, ": downloaded ", addresses_df$lon_f32[[i]], " ", addresses_df$lat_f32[[i]],
    ", existing ", existing_lon[[i]], " ", existing_lat[[i]]
  )
}

# ---- Display lines ----
# Borough names from zip codes on one row of each code:
# 1 = 10019 Manhattan, 2 = 10469 Bronx, 3 = 11231 Brooklyn,
# 4 = 11369 Queens, 5 = 10305 Staten Island.
address_lines_df <- addresses_df |>
  mutate(
    borough_name = recode_values(
      boroughcode,
      1 ~ "Manhattan",
      2 ~ "Bronx",
      3 ~ "Brooklyn",
      4 ~ "Queens",
      5 ~ "Staten Island",
      unmatched = "error"
    ),
    house_number_text = if_else(is.na(house_number), "", house_number),
    suffix_text = if_else(is.na(house_number_suffix), "", house_number_suffix),
    house_label = case_when(
      suffix_text != "" & grepl("^[A-Za-z]$", suffix_text) ~ paste0(house_number_text, suffix_text),
      suffix_text != "" ~ paste(house_number_text, suffix_text),
      .default = house_number_text
    ),
    street_line = if_else(
      house_label == "",
      full_street_name,
      paste(house_label, full_street_name)
    ),
    zip_text = if_else(is.na(zipcode), "", trimws(zipcode)),
    address_line = if_else(
      zip_text == "",
      paste(street_line, borough_name, sep = ", "),
      paste(street_line, borough_name, zip_text, sep = ", ")
    )
  )

stopifnot(
  !anyNA(address_lines_df$full_street_name),
  !any(address_lines_df$full_street_name == ""),
  !anyNA(address_lines_df$address_line),
  !any(address_lines_df$address_line == ""),
  !any(grepl("[\r\n]", address_lines_df$address_line)),
  "1883 ADAM CLAYTON POWELL JR BLVD, Manhattan, 10026" %in% address_lines_df$address_line
)

message("Address lines: ", nrow(address_lines_df))

output_con <- pipe("cat", "wb")
writeLines(address_lines_df$address_line, output_con, useBytes = TRUE)
flush(output_con)
close(output_con)
