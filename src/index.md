---
title: NYC addresses
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

.maplibregl-popup .maplibregl-popup-content {
  font: 13px/1.2 system-ui, sans-serif;
  padding: 8px 10px;
  border-radius: 8px;
  color: #1c1c1c;
}

.popup-address {
  margin: 0 16px 6px 0;
  line-height: 1.2;
}

.popup-street {
  font-size: 16px;
  font-weight: 400;
  line-height: 1.2;
}

.popup-place {
  margin-top: 2px;
  font-size: 12px;
  font-weight: 400;
  line-height: 1.2;
  color: #5c6570;
}

.popup-scores {
  border-collapse: separate;
  border-spacing: 0;
  margin: 0;
}

.popup-scores th,
.popup-scores td {
  padding: 3px 6px;
  font-weight: 450;
  white-space: nowrap;
}

.popup-scores th {
  text-align: left;
  padding-left: 6px;
}

.popup-scores td {
  text-align: right;
  font-variant-numeric: tabular-nums;
  padding-left: 14px;
}

.popup-scores tr.is-active th,
.popup-scores tr.is-active td {
  background: #d4e3f7;
  font-weight: 700;
}

.popup-scores tr.is-active th {
  border-radius: 4px 0 0 4px;
}

.popup-scores tr.is-active td {
  border-radius: 0 4px 4px 0;
}

.maplibregl-ctrl-top-right {
  z-index: 3;
}

.maplibregl-canvas.point-hover {
  cursor: pointer !important;
}
</style>

<link rel="stylesheet" href="npm:maplibre-gl@5.24.1/dist/maplibre-gl.css">

<div class="map-stage">
  <div id="map"></div>
  <div class="hud">
    <div class="hud-title">NYC addresses</div>
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
import * as d3 from "npm:d3@7.9.2";

const [addressBuffer, addressLineText] = await Promise.all([
  FileAttachment("data/addresses.bin").arrayBuffer(),
  FileAttachment("data/address-lines.txt").text()
]);
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
const addressLines = addressLineText.endsWith("\n")
  ? addressLineText.slice(0, -1).split("\n")
  : addressLineText.split("\n");
if (addressLines.length !== pointCount) {
  throw new Error(`Address file has ${addressLines.length} lines; expected ${pointCount} points`);
}
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

const layerMeta = {
  poverty: {
    label: "Poverty (synthetic, 0–100)",
    shortLabel: "Poverty",
    domain: [0, 100],
    interpolate: d3.interpolateYlOrRd,
    note: "Synthetic. Higher toward the South Bronx, East New York / Brownsville, southeast Queens, and north Staten Island."
  },
  park_access: {
    label: "Park access (synthetic, 0–100)",
    shortLabel: "Park access",
    domain: [0, 100],
    interpolate: d3.interpolateGreens,
    note: "Synthetic. Higher nearer Central Park, Prospect Park, Flushing Meadows, Pelham Bay, Van Cortlandt, and the other major parks."
  },
  heat_vulnerability: {
    label: "Heat vulnerability (synthetic, 0–100)",
    shortLabel: "Heat vulnerability",
    domain: [0, 100],
    interpolate: d3.interpolateYlOrRd,
    note: "Synthetic. Higher where park access is low and in inland parts of the central Bronx, Brooklyn, and Queens."
  },
  transit_access: {
    label: "Transit access (synthetic, 0–100)",
    shortLabel: "Transit access",
    domain: [0, 100],
    interpolate: d3.interpolatePurples,
    note: "Synthetic. Higher in Manhattan south of about 96th Street, downtown Brooklyn, Jackson Heights, Jamaica, and St. George."
  }
};

for (const id of Object.keys(layerMeta)) {
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

function colorOf(id, value) {
  const meta = layerMeta[id];
  return d3.rgb(meta.interpolate(colorStop(value, meta.domain)));
}

const pointColors = Object.fromEntries(
  Object.keys(layerMeta).map((id) => {
    const colors = new Uint8Array(pointCount * 4);
    const values = metrics[id];
    for (let i = 0; i < pointCount; i++) {
      const color = colorOf(id, values[i]);
      const offset = i * 4;
      colors[offset] = color.r;
      colors[offset + 1] = color.g;
      colors[offset + 2] = color.b;
      colors[offset + 3] = 230;
    }
    return [id, colors];
  })
);

function formatMetric(value) {
  return Number(value).toFixed(1);
}

const mapUi = {
  layerId: "poverty",
  beforeId: undefined,
  hoveredIndex: -1
};
const mapHandle = {overlay: null, pointsLayer: null};

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
    antialiasing: false,
    // Meters project to pixels on the GPU. City zoom stays on the 0.8px floor.
    // 18 m is about 2.5px at zoom 14, where a subpixel dot lost the color
    // scale, and the 5px cap keeps street zoom from turning into large disks.
    radiusUnits: "meters",
    getRadius: 18,
    radiusMinPixels: 0.8,
    radiusMaxPixels: 5,
    beforeId: mapUi.beforeId,
    parameters: {
      depthWriteEnabled: false,
      depthCompare: "always"
    }
  });
}

function renderLayers(rebuildPoints = false) {
  if (rebuildPoints || mapHandle.pointsLayer == null) {
    mapHandle.pointsLayer = makePointLayer();
  }
  const layers = [mapHandle.pointsLayer];
  const hoveredIndex = mapUi.hoveredIndex;
  if (hoveredIndex >= 0) {
    // The pixel cap is a layer uniform, so only this one dot is allowed past 5px.
    layers.push(new ScatterplotLayer({
      id: "address-point-hover",
      data: [hoveredIndex],
      pickable: false,
      filled: true,
      stroked: false,
      antialiasing: false,
      radiusUnits: "meters",
      getPosition: (index) => [positions[index * 3], positions[index * 3 + 1], 0],
      getFillColor: (index) => {
        const colors = pointColors[mapUi.layerId];
        const offset = index * 4;
        return [colors[offset], colors[offset + 1], colors[offset + 2], colors[offset + 3]];
      },
      getRadius: 27,
      radiusMinPixels: 1.2,
      radiusMaxPixels: 7.5,
      transitions: {getRadius: 80},
      beforeId: mapUi.beforeId,
      parameters: {
        depthWriteEnabled: false,
        depthCompare: "always"
      }
    }));
  }
  mapHandle.overlay.setProps({layers});
}

function paintLegend() {
  const meta = layerMeta[mapUi.layerId];
  document.querySelector("#mode-label").textContent = "Individual addresses";
  document.querySelector("#layer-note").textContent = meta.note;
  const stops = d3.range(0, 1.0001, 0.1).map((t) => meta.interpolate(colorStop(t)));
  document.querySelector("#legend").innerHTML = `
    <div class="legend-title">${meta.shortLabel} · synthetic · address</div>
    <div class="legend-scale">
      <span class="legend-end">0.0</span>
      <span class="legend-bar" style="background: linear-gradient(to right, ${stops.join(", ")})"></span>
      <span class="legend-end">100.0</span>
    </div>
    <div class="legend-foot">Score from 0 to 100 at this address.</div>
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
  minZoom: 9,
  maxZoom: 19,
  attributionControl: true
});
map.addControl(new maplibregl.NavigationControl({showCompass: false}), "top-right");

const popup = new maplibregl.Popup({
  closeButton: true,
  closeOnClick: false,
  maxWidth: "320px"
});
let dragging = false;
let deckReady = false;

mapHandle.pointsLayer = makePointLayer();
const overlay = new MapboxOverlay({
  interleaved: true,
  layers: [mapHandle.pointsLayer],
  onLoad: () => {
    deckReady = true;
    // deck.gl 9.4 writes the picking layer id to blendColor. This luma build
    // only applies blendConstant, so every pick came back empty.
    const pickPass = overlay._deck.deckPicker.pickLayersPass;
    const getLayerParameters = pickPass.getLayerParameters.bind(pickPass);
    pickPass.getLayerParameters = (layer, layerIndex, viewport) => {
      const parameters = getLayerParameters(layer, layerIndex, viewport);
      if (parameters.blendColor && !parameters.blendConstant) {
        parameters.blendConstant = parameters.blendColor;
      }
      return parameters;
    };
  }
});
mapHandle.overlay = overlay;
map.addControl(overlay);

function syncDeckView() {
  const center = map.getCenter();
  overlay._deck.setProps({
    viewState: {
      longitude: ((center.lng + 540) % 360) - 180,
      latitude: center.lat,
      zoom: map.getZoom(),
      bearing: map.getBearing(),
      pitch: map.getPitch(),
      padding: map.getPadding(),
      repeat: map.getRenderWorldCopies()
    }
  });
}
map.on("move", syncDeckView);
syncDeckView();

function clearHover() {
  const canvas = map.getCanvas();
  canvas.classList.remove("point-hover");
  canvas.style.cursor = "";
  if (mapUi.hoveredIndex === -1) return;
  mapUi.hoveredIndex = -1;
  renderLayers();
}

map.on("load", () => {
  const firstSymbol = map.getStyle().layers.find((layer) => layer.type === "symbol");
  if (!firstSymbol) {
    document.querySelector("#layer-note").textContent = "Basemap style has no symbol layer.";
    throw new Error("Basemap style has no symbol layer");
  }
  mapUi.beforeId = firstSymbol.id;
  renderLayers(true);
  map.resize();
});
map.on("dragstart", () => {
  dragging = true;
  clearHover();
});
map.on("dragend", () => {
  dragging = false;
});
map.on("mouseout", () => {
  clearHover();
});
map.on("mousemove", (event) => {
  if (dragging || !deckReady) return;
  const picked = overlay.pickObject({x: event.point.x, y: event.point.y, radius: 2});
  const index = picked?.index;
  if (index == null || index < 0) {
    clearHover();
    return;
  }
  const canvas = map.getCanvas();
  canvas.classList.add("point-hover");
  canvas.style.cursor = "pointer";
  if (index === mapUi.hoveredIndex) return;
  mapUi.hoveredIndex = index;
  renderLayers();
});
function popupHtml(index) {
  const selected = mapUi.layerId;
  const address = addressLines[index]
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
  const parts = address.split(", ");
  const street = parts[0];
  const place = parts.slice(1).join(", ");
  const rows = ["poverty", "park_access", "heat_vulnerability", "transit_access"].map((name) => {
    const active = name === selected ? ` class="is-active"` : "";
    return `<tr${active}><th>${layerMeta[name].shortLabel}</th><td>${formatMetric(metrics[name][index])}</td></tr>`;
  }).join("");
  return `<div class="popup-address"><div class="popup-street">${street}</div><div class="popup-place">${place}</div></div><table class="popup-scores">${rows}</table>`;
}

map.on("click", (event) => {
  if (!deckReady) return;
  const picked = overlay.pickObject({x: event.point.x, y: event.point.y, radius: 2});
  if (picked?.index == null || picked.index < 0) {
    popup.remove();
    return;
  }
  const index = picked.index;
  mapUi.popupIndex = index;
  popup
    .setLngLat([positions[index * 3], positions[index * 3 + 1]])
    .setHTML(popupHtml(index))
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
renderLayers(true);
paintLegend();
if (popup.isOpen()) popup.setHTML(popupHtml(mapUi.popupIndex));
```
