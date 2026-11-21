---
title: NYC address grid
sidebar: false
toc: false
---

<style>
html,
body {
  height: 100%;
  margin: 0;
  overflow: hidden;
  background: #e8eaed;
}

#observablehq-header,
#observablehq-footer,
#observablehq-sidebar,
#observablehq-toc {
  display: none;
}

#observablehq-center,
#observablehq-main {
  max-width: none;
  height: 100%;
  margin: 0;
  padding: 0;
}

.map-stage {
  position: fixed;
  inset: 0;
  height: 100vh;
  width: 100vw;
}

#map {
  position: absolute;
  inset: 0;
}

.hud {
  position: absolute;
  z-index: 3;
  top: 12px;
  left: 12px;
  width: min(380px, calc(100vw - 24px));
  padding: 12px 14px 11px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: 0 8px 28px rgba(20, 24, 32, 0.16);
  font: 13px/1.35 system-ui, sans-serif;
  color: #1c1c1c;
}

.hud-title {
  font-size: 15px;
  font-weight: 700;
  letter-spacing: -0.01em;
}

.hud-source {
  margin-top: 2px;
  color: #4d5560;
  font-size: 12px;
}

#layer-control {
  margin-top: 8px;
}

#layer-control form {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
}

#layer-control label {
  font-weight: 650;
  white-space: nowrap;
}

#layer-control select {
  width: 100%;
  min-width: 0;
}

.hud-stats {
  display: flex;
  gap: 14px;
  margin-top: 8px;
  font-variant-numeric: tabular-nums;
}

.layer-note {
  margin-top: 6px;
  color: #3d4450;
  font-size: 12px;
}

.legend {
  position: absolute;
  z-index: 3;
  left: 12px;
  bottom: 28px;
  width: min(340px, calc(100vw - 24px));
  padding: 8px 10px 9px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: 0 8px 28px rgba(20, 24, 32, 0.16);
  pointer-events: none;
  font: 12px/1.35 system-ui, sans-serif;
}

.legend-title {
  font-weight: 700;
  margin-bottom: 4px;
}

.legend-scale {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-bar {
  flex: 1 1 auto;
  height: 10px;
  border-radius: 999px;
  border: 1px solid rgba(0, 0, 0, 0.15);
}

.legend-end {
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.legend-foot {
  margin-top: 4px;
  color: #4d5560;
}

.maplibregl-popup-content {
  font: 13px/1.4 system-ui, sans-serif;
  padding: 8px 10px;
  border-radius: 8px;
  color: #1c1c1c;
}

.maplibregl-ctrl-top-right {
  z-index: 3;
}
</style>

<link rel="stylesheet" href="npm:maplibre-gl@5.24.1/dist/maplibre-gl.css">

<div class="map-stage">
  <div id="map"></div>
  <div class="hud">
    <div class="hud-title">NYC address grid</div>
    <div class="hud-source">AddressPoint <code>uf93-f8nk</code>. Locations are real. Poverty, park access, heat vulnerability, and transit access are synthetic.</div>
    <div id="layer-control"></div>
    <div class="hud-stats">
      <div><strong id="address-total"></strong> addresses</div>
      <div id="mode-label"></div>
    </div>
    <div id="layer-note" class="layer-note"></div>
  </div>
  <div id="legend" class="legend"></div>
</div>

```js
import maplibregl from "npm:maplibre-gl@5.24.1";
import {MapboxOverlay} from "npm:@deck.gl/mapbox@9.4.1";
import {ScatterplotLayer} from "npm:@deck.gl/layers@9.4.1";
import {HexagonLayer} from "npm:@deck.gl/aggregation-layers@9.4.1";
import * as d3 from "npm:d3@7.9.2";

const addressBuffer = await FileAttachment("data/addresses.bin").arrayBuffer();
const view = new DataView(addressBuffer);
if (addressBuffer.byteLength < 8) {
  throw new Error(`Address file has ${addressBuffer.byteLength} bytes; expected a row count and a column count`);
}
const pointCount = view.getUint32(0, true);
const columnCount = view.getUint32(4, true);
const decoder = new TextDecoder();
let cursor = 8;
const columnNames = [];
for (let column = 0; column < columnCount; column++) {
  if (cursor + 4 > addressBuffer.byteLength) {
    throw new Error("Address file header is shorter than the column count");
  }
  const nameLength = view.getUint32(cursor, true);
  cursor += 4;
  if (cursor + nameLength > addressBuffer.byteLength) {
    throw new Error("Address file header is shorter than a column name");
  }
  columnNames.push(decoder.decode(new Uint8Array(addressBuffer, cursor, nameLength)));
  cursor += nameLength;
}
const bodyByteLength = addressBuffer.byteLength - cursor;
const expectedByteLength = pointCount * columnCount * 4;
if (bodyByteLength !== expectedByteLength) {
  throw new Error(
    `Address file has ${bodyByteLength} data bytes; expected ${expectedByteLength} for ${pointCount} rows and ${columnCount} columns`
  );
}
const packed = new Float32Array(pointCount * columnCount);
new Uint8Array(packed.buffer).set(new Uint8Array(addressBuffer, cursor, expectedByteLength));
const columnIndex = new Map(columnNames.map((name, index) => [name, index]));
const lonIndex = columnIndex.get("lon");
const latIndex = columnIndex.get("lat");
if (lonIndex == null || latIndex == null) throw new Error("Address file is missing lon or lat");
const metricNames = columnNames.filter((name) => name !== "lon" && name !== "lat");
const metrics = Object.fromEntries(metricNames.map((name) => [name, new Float32Array(pointCount)]));
const positions = new Float64Array(pointCount * 3);
for (let i = 0; i < pointCount; i++) {
  const offset = i * columnCount;
  positions[i * 3] = packed[offset + lonIndex];
  positions[i * 3 + 1] = packed[offset + latIndex];
  for (const name of metricNames) {
    metrics[name][i] = packed[offset + columnIndex.get(name)];
  }
}
const pointData = {
  length: pointCount,
  attributes: {
    getPosition: {value: positions, size: 3}
  }
};

const zoomPlanRows = await FileAttachment("data/zoom-plan.csv").csv({typed: true});
const zoomPlanByZoom = new Map(zoomPlanRows.map((row) => [row.zoom, row]));

function choiceForZoom(zoom) {
  let nearestZoom = null;
  for (const row of zoomPlanRows) {
    if (nearestZoom == null) {
      nearestZoom = row.zoom;
      continue;
    }
    const nearestDistance = Math.abs(nearestZoom - zoom);
    const rowDistance = Math.abs(row.zoom - zoom);
    if (rowDistance < nearestDistance || (rowDistance === nearestDistance && row.zoom > nearestZoom)) {
      nearestZoom = row.zoom;
    }
  }
  const row = zoomPlanByZoom.get(nearestZoom);
  if (!row) throw new Error(`No zoom-plan row for zoom ${nearestZoom}`);
  return {mode: row.mode, radius: row.radius_m};
}

const layerMeta = {
  poverty: {
    label: "Poverty (synthetic, 0–100)",
    shortLabel: "Poverty",
    synthetic: true,
    count: false,
    domain: [0, 100],
    interpolate: d3.interpolateYlOrRd,
    note: "Synthetic. Higher toward the South Bronx, East New York / Brownsville, southeast Queens, and north Staten Island."
  },
  park_access: {
    label: "Park access (synthetic, 0–100)",
    shortLabel: "Park access",
    synthetic: true,
    count: false,
    domain: [0, 100],
    interpolate: d3.interpolateGreens,
    note: "Synthetic. Higher nearer Central Park, Prospect Park, Flushing Meadows, Pelham Bay, Van Cortlandt, and the other major parks."
  },
  heat_vulnerability: {
    label: "Heat vulnerability (synthetic, 0–100)",
    shortLabel: "Heat vulnerability",
    synthetic: true,
    count: false,
    domain: [0, 100],
    interpolate: d3.interpolateYlOrRd,
    note: "Synthetic. Higher where park access is low and in inland parts of the central Bronx, Brooklyn, and Queens."
  },
  transit_access: {
    label: "Transit access (synthetic, 0–100)",
    shortLabel: "Transit access",
    synthetic: true,
    count: false,
    domain: [0, 100],
    interpolate: d3.interpolatePurples,
    note: "Synthetic. Higher in Manhattan south of about 96th Street, downtown Brooklyn, Jackson Heights, Jamaica, and St. George."
  },
  n_addresses: {
    label: "Address count (real)",
    shortLabel: "Address count",
    synthetic: false,
    count: true,
    interpolate: d3.interpolateBlues,
    note: "Real number of AddressPoint records. Hexes show the count in each hex. At street zoom, each point is one address."
  }
};

for (const id of Object.keys(layerMeta)) {
  if (layerMeta[id].count) continue;
  if (metrics[id] == null) throw new Error(`${id} is not in the address file`);
}

const layerInput = Inputs.select(
  new Map(Object.keys(layerMeta).map((id) => [layerMeta[id].label, id])),
  {label: "Color by", value: "poverty"}
);
const layerId = Generators.input(layerInput);
document.querySelector("#layer-control").append(layerInput);
document.querySelector("#address-total").textContent = pointCount.toLocaleString("en-US");

function colorStop(value, domain = [0, 1]) {
  const [low, high] = domain;
  const unit = (value - low) / (high - low);
  const clamped = Math.max(0, Math.min(1, unit));
  return 0.18 + 0.82 * clamped;
}

function rampColors(interpolate, steps = 12) {
  return d3.range(steps).map((step) => {
    const color = d3.rgb(interpolate(colorStop(step / (steps - 1))));
    return [color.r, color.g, color.b];
  });
}

function logCountColors(minCount, maxCount, steps = 16) {
  const lo = Math.max(minCount, 1);
  const hi = Math.max(maxCount, lo + 1);
  return d3.range(steps).map((step) => {
    const value = lo + (step / (steps - 1)) * (hi - lo);
    const t = Math.log(value / lo) / Math.log(hi / lo);
    const color = d3.rgb(layerMeta.n_addresses.interpolate(colorStop(t)));
    return [color.r, color.g, color.b];
  });
}

const metricColors = Object.fromEntries(
  Object.keys(layerMeta)
    .filter((id) => !layerMeta[id].count)
    .map((id) => [id, rampColors(layerMeta[id].interpolate)])
);

function colorOf(id, value) {
  const meta = layerMeta[id];
  const t = meta.count ? 0.55 : colorStop(value, meta.domain);
  return d3.rgb(meta.interpolate(t));
}

const pointColors = Object.fromEntries(
  Object.keys(layerMeta).map((id) => {
    const meta = layerMeta[id];
    const colors = new Uint8Array(pointCount * 4);
    const values = metrics[id];
    for (let i = 0; i < pointCount; i++) {
      const color = colorOf(id, meta.count ? 0 : values[i]);
      const offset = i * 4;
      colors[offset] = color.r;
      colors[offset + 1] = color.g;
      colors[offset + 2] = color.b;
      colors[offset + 3] = 230;
    }
    return [id, colors];
  })
);

function formatMetric(id, value) {
  return layerMeta[id].count
    ? Math.round(value).toLocaleString("en-US")
    : Number(value).toFixed(1);
}

function formatRadius(meters) {
  return meters >= 1000 ? `${(meters / 1000).toFixed(1)} km` : `${Math.round(meters)} m`;
}

const openingChoice = choiceForZoom(10.4);
const mapUi = {
  layerId: "poverty",
  mode: openingChoice.mode,
  radius: openingChoice.radius,
  beforeId: undefined,
  hexDomain: null,
  countDomainKey: ""
};
const mapHandle = {overlay: null};

function makeHexLayer() {
  const meta = layerMeta[mapUi.layerId];
  const countDomain = mapUi.hexDomain && mapUi.hexDomain[1] > mapUi.hexDomain[0] ? mapUi.hexDomain : [1, 100];
  const countRange = logCountColors(countDomain[0], countDomain[1]);
  return new HexagonLayer({
    id: "address-hexes",
    data: pointData,
    pickable: true,
    extruded: false,
    coverage: 1,
    radius: mapUi.radius,
    gpuAggregation: true,
    colorAggregation: meta.count ? "SUM" : "MEAN",
    colorScaleType: meta.count ? "quantize" : "linear",
    colorDomain: meta.count ? countDomain : meta.domain,
    colorRange: meta.count ? countRange : metricColors[mapUi.layerId],
    getColorWeight: meta.count ? 1 : (d, {index}) => metrics[mapUi.layerId][index],
    updateTriggers: {getColorWeight: mapUi.layerId},
    elevationScale: 0,
    opacity: 170 / 255,
    beforeId: mapUi.beforeId,
    onSetColorDomain: (domain) => {
      if (!domain || !(domain[1] > domain[0])) return;
      mapUi.hexDomain = domain;
      paintLegend();
      if (!meta.count) return;
      const key = `${domain[0].toFixed(2)},${domain[1].toFixed(2)}`;
      if (key === mapUi.countDomainKey) return;
      mapUi.countDomainKey = key;
      if (!mapHandle.overlay) return;
      mapHandle.overlay.setProps({layers: [makeHexLayer()]});
    },
    parameters: {
      depthWriteEnabled: false,
      depthCompare: "always"
    }
  });
}

function makePointLayer() {
  return new ScatterplotLayer({
    id: "address-points",
    data: {
      length: pointCount,
      attributes: {
        getPosition: {value: positions, size: 3},
        getFillColor: {value: pointColors[mapUi.layerId], size: 4}
      }
    },
    pickable: true,
    filled: true,
    stroked: false,
    radiusUnits: "pixels",
    getRadius: 3,
    radiusMinPixels: 2,
    radiusMaxPixels: 4,
    beforeId: mapUi.beforeId,
    parameters: {
      depthWriteEnabled: false,
      depthCompare: "always"
    }
  });
}

function makeActiveLayer() {
  return mapUi.mode === "points" ? makePointLayer() : makeHexLayer();
}

function paintLegend() {
  const meta = layerMeta[mapUi.layerId];
  const hexMode = mapUi.mode === "hex";
  document.querySelector("#mode-label").textContent = hexMode
    ? `Hexes · ${formatRadius(mapUi.radius)} radius`
    : "Individual addresses";
  document.querySelector("#layer-note").textContent = meta.note;
  const stops = meta.count && hexMode && mapUi.hexDomain
    ? logCountColors(mapUi.hexDomain[0], mapUi.hexDomain[1]).map((rgb) => `rgb(${rgb.join(",")})`)
    : d3.range(0, 1.0001, 0.1).map((t) => meta.interpolate(colorStop(t)));
  let minLabel = "0.0";
  let maxLabel = "100.0";
  let foot = "Mean score from 0 to 100 inside each hex.";
  if (meta.count && hexMode) {
    minLabel = mapUi.hexDomain ? formatMetric(mapUi.layerId, mapUi.hexDomain[0]) : "…";
    maxLabel = mapUi.hexDomain ? formatMetric(mapUi.layerId, mapUi.hexDomain[1]) : "…";
    foot = "Log color scale of addresses in each hex.";
  } else if (meta.count) {
    minLabel = "1";
    maxLabel = "1";
    foot = "Each point is one AddressPoint record.";
  } else if (!hexMode) {
    foot = "Score from 0 to 100 at this address.";
  }
  const title = `${meta.shortLabel} · ${meta.synthetic ? "synthetic" : "real"} · ${hexMode ? "hex" : "address"}`;
  document.querySelector("#legend").innerHTML = `
    <div class="legend-title">${title}</div>
    <div class="legend-scale">
      <span class="legend-end">${minLabel}</span>
      <span class="legend-bar" style="background: linear-gradient(to right, ${stops.join(", ")})"></span>
      <span class="legend-end">${maxLabel}</span>
    </div>
    <div class="legend-foot">${foot}</div>
  `;
}

paintLegend();
```

```js
const mapContainer = document.querySelector("#map");
const map = new maplibregl.Map({
  container: mapContainer,
  style: "https://tiles.openfreemap.org/styles/positron",
  center: [-73.94, 40.72],
  zoom: 10.4,
  minZoom: zoomPlanRows[0].zoom,
  attributionControl: true
});
map.addControl(new maplibregl.NavigationControl({showCompass: false}), "top-right");

const popup = new maplibregl.Popup({
  closeButton: false,
  closeOnClick: false,
  maxWidth: "240px"
});
let dragging = false;
let deckReady = false;

function syncZoomLayer() {
  const choice = choiceForZoom(map.getZoom());
  if (choice.mode === mapUi.mode && (choice.mode === "points" || choice.radius === mapUi.radius)) return;
  mapUi.mode = choice.mode;
  if (choice.mode === "hex") mapUi.radius = choice.radius;
  mapUi.hexDomain = null;
  mapUi.countDomainKey = "";
  overlay.setProps({layers: [makeActiveLayer()]});
  paintLegend();
}

const overlay = new MapboxOverlay({
  interleaved: true,
  layers: [makeActiveLayer()],
  onLoad: () => {
    deckReady = true;
  }
});
mapHandle.overlay = overlay;
map.addControl(overlay);

map.on("load", () => {
  const firstSymbol = map.getStyle().layers.find((layer) => layer.type === "symbol");
  if (!firstSymbol) {
    document.querySelector("#layer-note").textContent = "Basemap style has no symbol layer.";
    throw new Error("Basemap style has no symbol layer");
  }
  mapUi.beforeId = firstSymbol.id;
  overlay.setProps({layers: [makeActiveLayer()]});
  map.resize();
});
map.on("zoomend", syncZoomLayer);
map.on("dragstart", () => {
  dragging = true;
  popup.remove();
  map.getCanvas().style.cursor = "";
});
map.on("dragend", () => {
  dragging = false;
});
map.on("mousemove", (event) => {
  if (dragging || !deckReady) return;
  const picked = overlay.pickObject({x: event.point.x, y: event.point.y, radius: 1});
  const meta = layerMeta[mapUi.layerId];
  if (mapUi.mode === "hex") {
    const cell = picked?.object;
    if (!cell) {
      popup.remove();
      map.getCanvas().style.cursor = "";
      return;
    }
    map.getCanvas().style.cursor = "pointer";
    const valueLabel = meta.count ? "Addresses in hex" : `${meta.shortLabel} mean (synthetic)`;
    const valueText = meta.count
      ? Number(cell.count).toLocaleString("en-US")
      : formatMetric(mapUi.layerId, cell.colorValue);
    popup
      .setLngLat(event.lngLat)
      .setHTML(
        `<strong>${valueLabel}</strong>: ${valueText}<br>Addresses in hex: ${Number(cell.count).toLocaleString("en-US")}`
      )
      .addTo(map);
    return;
  }
  if (picked?.index == null || picked.index < 0) {
    popup.remove();
    map.getCanvas().style.cursor = "";
    return;
  }
  const value = meta.count ? 1 : metrics[mapUi.layerId][picked.index];
  map.getCanvas().style.cursor = "pointer";
  popup
    .setLngLat(event.lngLat)
    .setHTML(
      `<strong>${meta.shortLabel}${meta.synthetic ? " (synthetic)" : " (real)"}</strong>: ${formatMetric(mapUi.layerId, value)}<br>1 address`
    )
    .addTo(map);
});

const resizeObserver = new ResizeObserver(() => map.resize());
resizeObserver.observe(mapContainer);
invalidation.then(() => {
  resizeObserver.disconnect();
  popup.remove();
  map.remove();
});

const mapReady = overlay;
```

```js
mapReady;
mapUi.layerId = layerId;
mapUi.hexDomain = null;
mapUi.countDomainKey = "";
mapHandle.overlay.setProps({layers: [makeActiveLayer()]});
paintLegend();
```
