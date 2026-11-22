---
title: NYC addresses
sidebar: false
toc: false
head: |
  <style>
  html,
  html body {
    height: 100%;
    margin: 0;
    overflow: hidden;
    background: #e8eaed;
    color: #1c1c1c;
    font: 13px/1.35 system-ui, sans-serif;
  }

  #observablehq-header,
  #observablehq-footer,
  #observablehq-sidebar,
  #observablehq-toc {
    display: none;
  }

  html body #observablehq-center,
  html body #observablehq-main {
    max-width: none;
    height: 100%;
    margin: 0;
    padding: 0;
  }

  .app {
    position: fixed;
    inset: 0;
    display: grid;
    grid-template-columns: minmax(0, 1fr) 400px;
    grid-template-rows: minmax(0, 1fr);
    background: #e8eaed;
  }

  .map-stage {
    position: relative;
    min-width: 0;
    min-height: 0;
  }

  #map {
    position: absolute;
    inset: 0;
  }

  .map-loading {
    position: absolute;
    z-index: 2;
    inset: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    background: #e8eaed;
    color: #3d4450;
    font: 600 13px/1.2 system-ui, sans-serif;
  }

  .map-loading[hidden],
  .graphs-loading[hidden] {
    display: none;
  }

  .graphs-loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 10px;
    min-height: 220px;
    margin-top: 8px;
    color: #3d4450;
    font: 600 13px/1.2 system-ui, sans-serif;
  }

  .map-spinner {
    width: 28px;
    height: 28px;
    border: 3px solid rgba(28, 28, 28, 0.16);
    border-top-color: #1c1c1c;
    border-radius: 50%;
    animation: map-spin 0.7s linear infinite;
  }

  @keyframes map-spin {
    to {
      transform: rotate(360deg);
    }
  }

  .nta-tip {
    position: absolute;
    z-index: 4;
    pointer-events: none;
    max-width: 9rem;
    padding: 2px 6px;
    border-radius: 4px;
    background: rgba(22, 36, 54, 0.92);
    color: #fff;
    font: 600 12px/1.25 system-ui, sans-serif;
    text-align: center;
    transform: translate(-50%, -50%);
  }

  .nta-tip[hidden] {
    display: none;
  }

  .hud {
    position: absolute;
    z-index: 3;
    top: 12px;
    left: 12px;
    box-sizing: border-box;
    width: min(380px, calc(100% - 24px));
    max-width: 100%;
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

  #layer-control,
  #layer-control form,
  #layer-control select {
    max-width: 100%;
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
    box-sizing: border-box;
    width: min(340px, calc(100% - 24px));
    max-width: 100%;
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

  .popup-scores tr {
    cursor: pointer;
  }

  .popup-scores tr:hover th,
  .popup-scores tr:hover td {
    background: #eef3f8;
  }

  .popup-scores tr.is-active th,
  .popup-scores tr.is-active td,
  .popup-scores tr.is-active:hover th,
  .popup-scores tr.is-active:hover td {
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

  .graphs-close {
    display: none;
    border: 0;
    border-radius: 8px;
    background: #1c1c1c;
    color: #fff;
    font: 650 13px/1 system-ui, sans-serif;
    padding: 10px 12px;
    cursor: pointer;
  }

  .graphs-edge {
    display: flex;
    position: absolute;
    z-index: 4;
    top: 50%;
    right: 0;
    transform: translateY(-50%);
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 56px;
    padding: 0;
    border: 1px solid rgba(28, 28, 28, 0.28);
    border-right: 0;
    border-radius: 8px 0 0 8px;
    background: #fff;
    color: #1c1c1c;
    box-shadow: -2px 2px 12px rgba(20, 24, 32, 0.22);
    cursor: pointer;
  }

  .app.graphs-collapsed {
    grid-template-columns: minmax(0, 1fr);
  }

  .app.graphs-collapsed .graphs-panel {
    display: none;
  }

  @media (min-width: 1000px) {
    .app:not(.graphs-collapsed) .graphs-edge svg {
      transform: rotate(180deg);
    }
  }

  .graphs-edge svg {
    display: block;
  }

  .graphs-panel {
    min-width: 0;
    min-height: 0;
    overflow: auto;
    box-sizing: border-box;
    background: #f6f7f9;
    border-left: 1px solid #d5dae1;
    padding: 14px 14px 24px;
    font: 13px/1.35 system-ui, sans-serif;
    color: #1c1c1c;
  }

  .graphs-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    margin-top: 12px;
  }

  .graphs-title {
    font-size: 15px;
    font-weight: 700;
  }

  .graphs-count {
    margin-top: 2px;
    font-variant-numeric: tabular-nums;
  }

  .graphs-note,
  .graphs-status,
  .graphs-empty {
    margin: 10px 0 0;
    color: #3d4450;
    font-size: 12px;
  }

  .metric-charts {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 12px;
  }

  .metric-chart {
    box-sizing: border-box;
    background: #fff;
    border: 1px solid #e1e5eb;
    border-radius: 10px;
    padding: 8px 8px 2px;
    cursor: pointer;
  }

  .metric-chart * {
    cursor: pointer;
  }

  .metric-chart:hover {
    border-color: #7aa2d4;
  }

  .metric-chart.is-active {
    background: #e7f0fb;
    border-color: #7aa2d4;
  }

  .metric-chart h3 {
    margin: 0 8px;
    font-size: 13px;
    font-weight: 650;
  }

  .metric-stats {
    margin: 2px 8px 0;
    color: #3d4450;
    font-size: 11px;
    font-variant-numeric: tabular-nums;
  }

  .metric-plot {
    overflow: hidden;
  }

  .metric-plot svg {
    display: block;
    max-width: 100%;
    height: auto;
  }

  .neighborhoods {
    margin-top: 0;
  }

  .tools-tray {
    box-sizing: border-box;
    padding: 8px;
    border: 1px solid #e1e5eb;
    border-radius: 10px;
    background: #fff;
  }

  .tools-title {
    font-size: 13px;
    font-weight: 650;
  }

  .tool-list {
    display: flex;
    flex-direction: row;
    align-items: stretch;
    gap: 6px;
    margin-top: 6px;
  }

  .select-mode {
    display: flex;
    flex: 1 1 0;
    align-items: center;
    justify-content: center;
    min-width: 0;
    margin: 0;
    padding: 6px 8px;
    border: 1px solid #e1e5eb;
    border-radius: 8px;
    background: #fff;
    color: inherit;
    font: inherit;
    font-weight: 600;
    text-align: center;
    cursor: pointer;
  }

  .select-mode:hover {
    border-color: #7aa2d4;
  }

  .select-mode.is-active {
    background: #e7f0fb;
    border-color: #7aa2d4;
  }

  .boundary-toggle {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    margin-top: 8px;
    padding: 4px 4px;
    cursor: pointer;
    font-size: 13px;
  }

  .nta-row input,
  .boundary-toggle input {
    appearance: none;
    box-sizing: border-box;
    width: 14px;
    height: 14px;
    margin: 2px 0 0;
    border: 1.5px solid #9aa3ad;
    border-radius: 4px;
    background: #fff center / 10px 10px no-repeat;
    flex: 0 0 auto;
    cursor: pointer;
  }

  .nta-row input:checked,
  .boundary-toggle input:checked {
    border-color: #1d4e89;
    background-color: #1d4e89;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12'%3E%3Cpath d='M2.4 6.2 4.7 8.6 9.6 3.4' fill='none' stroke='white' stroke-width='1.6' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  }

  .nta-row input:indeterminate {
    border-color: #1d4e89;
    background-color: #fff;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12'%3E%3Cpath d='M2.5 6h7' fill='none' stroke='%231d4e89' stroke-width='1.6' stroke-linecap='round'/%3E%3C/svg%3E");
  }

  .select-mode:focus-visible,
  .nta-row input:focus-visible,
  .boundary-toggle input:focus-visible {
    outline: 2px solid #7aa2d4;
    outline-offset: 2px;
  }

  .neighborhood-tools {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    margin-top: 10px;
  }

  .neighborhood-tools[hidden],
  .neighborhood-list[hidden],
  #inspect-mode-note[hidden],
  #select-mode-note[hidden] {
    display: none;
  }

  .neighborhood-tools button {
    border: 1px solid #d5dae1;
    border-radius: 8px;
    background: #fff;
    color: #1c1c1c;
    font: 600 12px/1 system-ui, sans-serif;
    padding: 6px 10px;
    cursor: pointer;
  }

  .neighborhood-tools button:hover {
    background: #eef1f4;
  }

  #neighborhood-selected {
    color: #5c6570;
    font-size: 12px;
    font-variant-numeric: tabular-nums;
  }

  .neighborhood-list {
    max-height: min(240px, 32vh);
    overflow: auto;
    margin-top: 8px;
  }

  .nta-branch > summary {
    display: flex;
    align-items: flex-start;
    gap: 2px;
    padding: 1px 4px;
    border-radius: 6px;
    cursor: pointer;
    list-style: none;
  }

  .nta-branch > summary:hover {
    background: #f4f6f8;
  }

  .nta-branch > summary::-webkit-details-marker {
    display: none;
  }

  .nta-twist {
    flex: 0 0 auto;
    width: 20px;
    margin-top: 2px;
    color: #8b95a1;
    font-size: 18px;
    line-height: 1;
    text-align: center;
  }

  .nta-branch > summary .nta-twist::before {
    content: "▸";
  }

  .nta-branch[open] > summary .nta-twist::before {
    content: "▾";
  }

  .nta-children {
    margin: 0 0 2px 18px;
    padding-left: 8px;
    border-left: 1px solid #e6eaef;
  }

  .nta-row {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    flex: 1;
    min-width: 0;
    padding: 4px 4px;
    border-radius: 6px;
    cursor: pointer;
  }

  .nta-children > .nta-row:hover {
    background: #f4f6f8;
  }

  .nta-row:has(input:checked) {
    background: #eef3f8;
  }

  .nta-row span {
    flex: 1;
    min-width: 0;
  }

  .neighborhood-list > .nta-branch > summary .nta-row span {
    font-weight: 650;
    color: #1c1c1c;
  }

  .nta-children > .nta-branch > summary .nta-row span {
    font-weight: 600;
    color: #2c3440;
  }

  .nta-children > .nta-row span {
    font-weight: 450;
    color: #5c6570;
  }

  .nta-source {
    margin: 6px 6px 4px;
    color: #5c6570;
    font-size: 11px;
  }

  @media (max-width: 999px) {
    .app {
      grid-template-columns: minmax(0, 1fr);
    }

    .hud {
      top: 8px;
      left: 8px;
      width: calc(100% - 64px);
      max-height: calc(100dvh - 96px);
      overflow: auto;
      padding: 8px 10px;
      font-size: 12px;
    }

    .hud-title {
      font-size: 14px;
    }

    .hud-source,
    .layer-note {
      font-size: 11px;
    }

    #layer-control form {
      flex-wrap: wrap;
    }

    #layer-control select {
      flex: 1 1 8rem;
    }

    .hud-stats {
      flex-wrap: wrap;
      gap: 4px 12px;
    }

    .legend {
      left: 8px;
      bottom: 22px;
      width: calc(100% - 16px);
      padding: 6px 8px 7px;
    }

    .app.graphs-open .graphs-edge {
      display: none;
    }

    .graphs-panel {
      display: none;
      border-left: 0;
    }

    .app.graphs-open .graphs-panel {
      display: block;
      position: fixed;
      inset: 0;
      z-index: 40;
    }

    .app.graphs-open .graphs-close {
      display: inline-flex;
      flex: 0 0 auto;
    }

    .maplibregl-popup {
      max-width: calc(100vw - 28px) !important;
    }

    .neighborhood-list {
      max-height: 40vh;
    }
  }
  </style>
---


<div class="app" id="app">
  <div class="map-stage">
    <div id="map"></div>
    <div id="map-loading" class="map-loading" role="status">
      <div class="map-spinner" aria-hidden="true"></div>
      Loading map
    </div>
    <div id="nta-tip" class="nta-tip" hidden></div>
    <button type="button" id="graphs-open" class="graphs-edge" aria-label="Graphs">
      <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true">
        <path d="M9 2.5 4.5 7 9 11.5" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </button>
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
  <aside id="graphs-panel" class="graphs-panel" aria-label="Distributions in the map view">
    <div id="neighborhoods" class="neighborhoods">
      <div class="tools-tray">
        <div class="tools-title">Tools</div>
        <div class="tool-list">
          <button type="button" id="select-points" class="select-mode is-active" aria-pressed="true">
            Inspect
          </button>
          <button type="button" id="select-neighborhoods" class="select-mode" aria-pressed="false">
            Select neighborhoods
          </button>
        </div>
        <p id="inspect-mode-note" class="graphs-note">Pan and zoom to see data for a specific area. Click on a point to see scores for that address.</p>
        <p id="select-mode-note" class="graphs-note" hidden>Choose neighborhoods below, or select them by clicking on the map.</p>
        <label class="boundary-toggle">
          <input type="checkbox" id="show-boundaries">
          Show neighborhood boundaries
        </label>
        <div id="neighborhood-tools" class="neighborhood-tools" hidden>
          <button type="button" id="clear-neighborhoods">Clear selection</button>
          <span id="neighborhood-selected">None selected</span>
        </div>
        <div id="neighborhood-list" class="neighborhood-list" hidden></div>
      </div>
    </div>
    <div class="graphs-header">
      <div>
        <div class="graphs-title">In this area</div>
        <div class="graphs-count"><strong id="view-count">…</strong> addresses</div>
      </div>
      <button type="button" id="graphs-close" class="graphs-close">Close</button>
    </div>
    <p id="graphs-note" class="graphs-note">Synthetic scores for addresses inside the current map view.</p>
    <p id="graphs-status" class="graphs-status" hidden></p>
    <div id="graphs-loading" class="graphs-loading" role="status">
      <div class="map-spinner" aria-hidden="true"></div>
      Loading graphs
    </div>
    <p id="graphs-empty" class="graphs-empty" hidden>No addresses in this area.</p>
    <div id="metric-charts" class="metric-charts" hidden></div>
  </aside>
</div>

<link rel="stylesheet" href="npm:maplibre-gl@5.24.1/dist/maplibre-gl.css">


```js
// Own cell so these downloads start before maplibre and deck.gl evaluate.
const addressBufferPromise = FileAttachment("data/addresses.bin").arrayBuffer();
const ntaPromise = FileAttachment("data/nta-2020.geojson").json();
```

```js
import maplibregl from "npm:maplibre-gl@5.24.1";
import {MapboxOverlay} from "npm:@deck.gl/mapbox@9.4.1";
import {ScatterplotLayer} from "npm:@deck.gl/layers@9.4.1";
import {range} from "npm:d3-array@3.2.5";
import {rgb} from "npm:d3-color@3.1.1";
import {geoBounds, geoCentroid} from "npm:d3-geo@3.1.2";
import {interpolateGreens, interpolatePurples, interpolateYlOrRd} from "npm:d3-scale-chromatic@3.1.1";
import {ntaAreas} from "./data/nta-areas.js";
import {assignAddressesToNtas} from "./data/assign-nta.js";

const d3 = {range, rgb, geoBounds, geoCentroid, interpolateGreens, interpolatePurples, interpolateYlOrRd};

const [addressBuffer, ntaCollection] = await Promise.all([
  addressBufferPromise,
  ntaPromise
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
const metrics = Object.fromEntries(metricNames.map((name) => [name, new Float32Array(pointCount)]));
const lonColumn = new Float32Array(pointCount);
const latColumn = new Float32Array(pointCount);
const positions = new Float64Array(pointCount * 3);
for (let i = 0; i < pointCount; i++) {
  const offset = i * columnCount;
  const lon = packed[offset + lonIndex];
  const lat = packed[offset + latIndex];
  positions[i * 3] = lon;
  positions[i * 3 + 1] = lat;
  lonColumn[i] = lon;
  latColumn[i] = lat;
  for (const name of metricNames) {
    metrics[name][i] = packed[offset + columnIndex.get(name)];
  }
}

const assignedNeighborhoods = assignAddressesToNtas(ntaCollection, ntaAreas, lonColumn, latColumn);
const neighborhoods = assignedNeighborhoods.neighborhoods;
const neighborhoodHierarchy = assignedNeighborhoods.hierarchy;
const neighborhoodIds = assignedNeighborhoods.neighborhoodIds;

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

const metricOrder = ["poverty", "park_access", "heat_vulnerability", "transit_access"];

for (const id of metricOrder) {
  if (metrics[id] == null) throw new Error(`${id} is not in the address file`);
}

const layerInput = Inputs.select(
  new Map(Object.keys(layerMeta).map((id) => [layerMeta[id].label, id])),
  {label: "Color by", value: "poverty"}
);
const layerId = Generators.input(layerInput);
document.querySelector("#layer-control").append(layerInput);

function setMapMetric(metric) {
  if (metric === mapUi.layerId) return;
  layerInput.value = metric;
  layerInput.dispatchEvent(new Event("input", {bubbles: true}));
}
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

function colorRamp(interpolate) {
  const ramp = new Uint8Array(256 * 3);
  for (let step = 0; step < 256; step++) {
    const color = d3.rgb(interpolate(colorStop(step / 255)));
    const offset = step * 3;
    ramp[offset] = color.r;
    ramp[offset + 1] = color.g;
    ramp[offset + 2] = color.b;
  }
  return ramp;
}

const pointColors = Object.fromEntries(
  Object.keys(layerMeta).map((id) => {
    const ramp = colorRamp(layerMeta[id].interpolate);
    const colors = new Uint8Array(pointCount * 4);
    const values = metrics[id];
    for (let i = 0; i < pointCount; i++) {
      const step = Math.max(0, Math.min(255, Math.round(values[i] * 2.55)));
      const rampOffset = step * 3;
      const offset = i * 4;
      colors[offset] = ramp[rampOffset];
      colors[offset + 1] = ramp[rampOffset + 1];
      colors[offset + 2] = ramp[rampOffset + 2];
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
  hoveredIndex: -1,
  selectMode: false,
  selectionActive: false,
  showBoundaries: false,
  hoveredNta: null
};
const boundaryManual = {city: null, selected: null, select: null};
const mapHandle = {overlay: null, pointsLayer: null, fill: null, deckReady: false};
const selectedMask = new Uint8Array(neighborhoods.length + 1);

function colorsForMap() {
  const base = pointColors[mapUi.layerId];
  if (!mapUi.selectionActive) return base;
  const colors = new Uint8Array(base);
  for (let i = 0; i < pointCount; i++) {
    if (selectedMask[neighborhoodIds[i]] === 0) {
      const offset = i * 4;
      colors[offset] = 139;
      colors[offset + 1] = 144;
      colors[offset + 2] = 150;
      colors[offset + 3] = 200;
    }
  }
  return colors;
}

function makePointLayer(fill = colorsForMap()) {
  mapHandle.fill = fill;
  return new ScatterplotLayer({
    id: "address-points",
    data: {
      length: pointCount,
      attributes: {
        getPosition: {value: positions, size: 3},
        getFillColor: {value: fill, size: 4}
      }
    },
    pickable: !mapUi.selectMode,
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
  const fill = mapHandle.fill;
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
        const offset = index * 4;
        return [fill[offset], fill[offset + 1], fill[offset + 2], fill[offset + 3]];
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
// Street names are for the click popup. Drawing the map does not wait on them.
const addressLinePromise = FileAttachment("data/address-lines.txt").text();

const mapContainer = document.querySelector("#map");
const nycBounds = d3.geoBounds(ntaCollection);
const map = new maplibregl.Map({
  container: mapContainer,
  style: "https://tiles.openfreemap.org/styles/positron",
  bounds: nycBounds,
  fitBoundsOptions: {padding: 40},
  minZoom: 8,
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
    mapHandle.deckReady = true;
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
  if (mapUi.hoveredNta != null) placeNeighborhoodLabel(mapUi.hoveredNta);
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

const selectedNeighborhoods = new Set();
const neighborhoodLeaves = [];
const neighborhoodGroups = [];
const neighborhoodSelection = {onChange: null, onMode: null};
let ntaLayersReady = false;

function paintNeighborhoodState() {
  if (!ntaLayersReady) return;
  for (const neighborhood of neighborhoods) {
    map.setFeatureState(
      {source: "nta", id: neighborhood.id},
      {selected: selectedNeighborhoods.has(neighborhood.id)}
    );
  }
}

function syncNeighborhoodLayers() {
  if (!ntaLayersReady) return;
  const picking = mapUi.selectMode;
  const showFill = picking || mapUi.selectionActive;
  const cityWide = mapUi.showBoundaries && !picking && !mapUi.selectionActive;
  const showLines = mapUi.showBoundaries;
  const allOutlines = picking || cityWide;
  map.setLayoutProperty("nta-fill", "visibility", showFill ? "visible" : "none");
  map.setLayoutProperty("nta-line", "visibility", showLines ? "visible" : "none");
  map.setLayoutProperty("nta-hover", "visibility", picking ? "visible" : "none");
  const selectedOnly = !picking && mapUi.selectionActive
    ? ["match", ["id"], [...selectedNeighborhoods], true, false]
    : null;
  map.setFilter("nta-fill", selectedOnly);
  map.setFilter("nta-line", selectedOnly);
  map.setPaintProperty("nta-fill", "fill-opacity", [
    "case",
    ["boolean", ["feature-state", "selected"], false],
    0.2,
    picking ? 0.012 : 0
  ]);
  map.setPaintProperty("nta-line", "line-color", [
    "case",
    ["boolean", ["feature-state", "selected"], false],
    "#000000",
    allOutlines ? "#000000" : "rgba(0,0,0,0)"
  ]);
  map.setPaintProperty("nta-line", "line-opacity", [
    "case",
    ["boolean", ["feature-state", "selected"], false],
    0.72,
    allOutlines ? 0.62 : 0
  ]);
  map.setPaintProperty("nta-line", "line-width", [
    "case",
    ["boolean", ["feature-state", "selected"], false],
    2.5,
    allOutlines ? 2.0 : 0
  ]);
}

function clearNeighborhoodHover() {
  const tip = document.querySelector("#nta-tip");
  tip.hidden = true;
  if (!ntaLayersReady || mapUi.hoveredNta == null) {
    mapUi.hoveredNta = null;
    return;
  }
  map.setFeatureState({source: "nta", id: mapUi.hoveredNta}, {hover: false});
  mapUi.hoveredNta = null;
}

const neighborhoodCentroids = new Map(
  ntaCollection.features.map((feature) => [feature.id, d3.geoCentroid(feature)])
);

function placeNeighborhoodLabel(id, name, point) {
  const tip = document.querySelector("#nta-tip");
  tip.hidden = false;
  if (name != null) tip.textContent = name;
  const centroid = neighborhoodCentroids.get(id);
  const projected = centroid ? map.project(centroid) : null;
  const width = mapContainer.clientWidth;
  const height = mapContainer.clientHeight;
  const inside = projected
    && projected.x >= 28
    && projected.y >= 28
    && projected.x <= width - 28
    && projected.y <= height - 28;
  const at = inside ? projected : point;
  if (!at) return;
  tip.style.left = `${at.x}px`;
  tip.style.top = `${at.y}px`;
}

function showNeighborhoodHover(id, name, point) {
  if (id !== mapUi.hoveredNta) {
    if (mapUi.hoveredNta != null) {
      map.setFeatureState({source: "nta", id: mapUi.hoveredNta}, {hover: false});
    }
    mapUi.hoveredNta = id;
    map.setFeatureState({source: "nta", id}, {hover: true});
  }
  placeNeighborhoodLabel(id, name, point);
}

function syncNeighborhoodChecks() {
  for (const leaf of neighborhoodLeaves) {
    leaf.box.checked = selectedNeighborhoods.has(leaf.id);
    leaf.box.indeterminate = false;
  }
  for (const group of neighborhoodGroups) {
    let selected = 0;
    for (const id of group.ids) if (selectedNeighborhoods.has(id)) selected++;
    group.box.checked = selected === group.ids.length && selected > 0;
    group.box.indeterminate = selected > 0 && selected < group.ids.length;
  }
  const count = document.querySelector("#neighborhood-selected");
  const n = selectedNeighborhoods.size;
  count.textContent = n === 0 ? "None selected" : `${n.toLocaleString("en-US")} selected`;
}

function commitNeighborhoodSelection() {
  selectedMask.fill(0);
  for (const id of selectedNeighborhoods) selectedMask[id] = 1;
  mapUi.selectionActive = selectedNeighborhoods.size > 0;
  paintNeighborhoodState();
  applyBoundaryForMode();
  syncNeighborhoodLayers();
  syncNeighborhoodChecks();
  renderLayers(true);
  neighborhoodSelection.onChange?.();
}

function toggleNeighborhood(id) {
  if (selectedNeighborhoods.has(id)) selectedNeighborhoods.delete(id);
  else selectedNeighborhoods.add(id);
  commitNeighborhoodSelection();
}

function setNeighborhoods(ids, on) {
  for (const id of ids) {
    if (on) selectedNeighborhoods.add(id);
    else selectedNeighborhoods.delete(id);
  }
  commitNeighborhoodSelection();
}

function clearNeighborhoodSelection() {
  selectedNeighborhoods.clear();
  commitNeighborhoodSelection();
}

function boundarySituation() {
  if (mapUi.selectMode) return "select";
  if (mapUi.selectionActive) return "selected";
  return "city";
}

function applyBoundaryForMode() {
  const remembered = boundaryManual[boundarySituation()];
  const on = remembered ?? (mapUi.selectMode || mapUi.selectionActive);
  mapUi.showBoundaries = on;
  document.querySelector("#show-boundaries").checked = on;
}

function setSelectMode(on) {
  if (mapUi.selectMode === on) return;
  mapUi.selectMode = on;
  clearNeighborhoodHover();
  if (on) {
    popup.remove();
    mapUi.hoveredIndex = -1;
    const canvas = map.getCanvas();
    canvas.classList.remove("point-hover");
    canvas.style.cursor = "";
  }
  applyBoundaryForMode();
  syncNeighborhoodLayers();
  renderLayers(true);
  neighborhoodSelection.onMode?.();
}

map.on("load", () => {
  const firstSymbol = map.getStyle().layers.find((layer) => layer.type === "symbol");
  if (!firstSymbol) {
    document.querySelector("#layer-note").textContent = "Basemap style has no symbol layer.";
    throw new Error("Basemap style has no symbol layer");
  }
  const labelLayerId = firstSymbol.id;
  map.addSource("nta", {type: "geojson", data: ntaCollection});
  map.addLayer({
    id: "nta-fill",
    type: "fill",
    source: "nta",
    layout: {visibility: "none"},
    paint: {
      "fill-color": [
        "case",
        ["boolean", ["feature-state", "selected"], false],
        "#8eafcc",
        "#2c4668"
      ],
      "fill-opacity": 0
    }
  }, labelLayerId);
  map.addLayer({
    id: "nta-hover",
    type: "fill",
    source: "nta",
    layout: {visibility: "none"},
    paint: {
      "fill-color": "#2c4668",
      "fill-opacity": ["case", ["boolean", ["feature-state", "hover"], false], 0.62, 0]
    }
  }, labelLayerId);
  map.addLayer({
    id: "nta-line",
    type: "line",
    source: "nta",
    layout: {visibility: "none", "line-join": "round", "line-cap": "round"},
    paint: {
      "line-color": "#000000",
      "line-width": [
        "case",
        ["boolean", ["feature-state", "selected"], false],
        2.5,
        2.0
      ]
    }
  }, labelLayerId);
  // Points slot in under the hover fill, so the outline and the
  // translucent hover stay above the address dots. Labels stay above the outlines.
  mapUi.beforeId = "nta-hover";
  ntaLayersReady = true;
  paintNeighborhoodState();
  syncNeighborhoodLayers();
  renderLayers(true);
  map.resize();
  document.querySelector("#map-loading").hidden = true;
});
map.on("dragstart", () => {
  dragging = true;
  clearHover();
  clearNeighborhoodHover();
});
map.on("dragend", () => {
  dragging = false;
});
map.on("mouseout", () => {
  clearHover();
  clearNeighborhoodHover();
});
map.on("mousemove", (event) => {
  if (mapUi.selectMode) {
    if (dragging || !ntaLayersReady) return;
    clearHover();
    const hits = map.queryRenderedFeatures(event.point, {layers: ["nta-fill"]});
    const hit = hits[0];
    const id = hit == null ? null : Number(hit.id);
    if (!Number.isInteger(id)) {
      clearNeighborhoodHover();
      map.getCanvas().style.cursor = "";
      return;
    }
    map.getCanvas().style.cursor = "pointer";
    showNeighborhoodHover(id, hit.properties.name, event.point);
    return;
  }
  if (mapUi.hoveredNta != null) clearNeighborhoodHover();
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

map.on("click", (event) => {
  if (!mapUi.selectMode) return;
  if (!ntaLayersReady) return;
  const hits = map.queryRenderedFeatures(event.point, {layers: ["nta-fill"]});
  if (!hits.length) return;
  const id = Number(hits[0].id);
  if (Number.isInteger(id)) toggleNeighborhood(id);
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
const addressLineText = await addressLinePromise;
const addressLines = addressLineText.endsWith("\n")
  ? addressLineText.slice(0, -1).split("\n")
  : addressLineText.split("\n");
if (addressLines.length !== pointCount) {
  throw new Error(`Address file has ${addressLines.length} lines; expected ${pointCount} points`);
}

function popupHtml(index) {
  const selected = mapUi.layerId;
  const address = addressLines[index]
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
  const parts = address.split(", ");
  const street = parts[0];
  const place = parts.slice(1).join(", ");
  const rows = metricOrder.map((name) => {
    const active = name === selected ? ` class="is-active"` : "";
    return `<tr${active} data-metric="${name}"><th>${layerMeta[name].shortLabel}</th><td>${formatMetric(metrics[name][index])}</td></tr>`;
  }).join("");
  return `<div class="popup-address"><div class="popup-street">${street}</div><div class="popup-place">${place}</div></div><table class="popup-scores">${rows}</table>`;
}

popup.on("open", () => {
  const element = popup.getElement();
  if (element.dataset.metricBound) return;
  element.dataset.metricBound = "1";
  element.addEventListener("click", (event) => {
    const row = event.target.closest("tr[data-metric]");
    if (!row) return;
    setMapMetric(row.dataset.metric);
  });
});

map.on("click", (event) => {
  if (mapUi.selectMode || !mapHandle.deckReady) return;
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
```

```js
// Dynamic so DuckDB, Mosaic, and Arrow are not preloaded ahead of the map.
const [vg, {clauseComposite}, {tableFromArrays, tableToIPC}] = await Promise.all([
  import("npm:@uwdata/vgplot@0.35.1"),
  import("npm:@uwdata/mosaic-core@0.35.1"),
  import("npm:apache-arrow@17.0.0")
]);

const narrowMedia = window.matchMedia("(max-width: 999px)");
const app = document.querySelector("#app");

function fitPopupWidth() {
  popup.setMaxWidth(
    narrowMedia.matches
      ? `${Math.max(160, Math.min(320, window.innerWidth - 28))}px`
      : "320px"
  );
}

const graphsEdge = document.querySelector("#graphs-open");

function syncEdgeLabel() {
  const closesDockedPanel = !narrowMedia.matches && !app.classList.contains("graphs-collapsed");
  graphsEdge.setAttribute("aria-label", closesDockedPanel ? "Hide graphs" : "Graphs");
}

function syncMapToLayout() {
  if (!narrowMedia.matches) app.classList.remove("graphs-open");
  syncEdgeLabel();
  fitPopupWidth();
  map.resize();
}

fitPopupWidth();
syncEdgeLabel();
narrowMedia.addEventListener("change", syncMapToLayout);
graphsEdge.addEventListener("click", () => {
  if (narrowMedia.matches) {
    app.classList.add("graphs-open");
    map.resize();
    document.querySelector("#graphs-close").focus();
    return;
  }
  app.classList.toggle("graphs-collapsed");
  syncEdgeLabel();
  map.resize();
});
document.querySelector("#graphs-close").addEventListener("click", () => {
  app.classList.remove("graphs-open");
  map.resize();
  graphsEdge.focus();
});

// Histograms follow the current map bounds. Selected neighborhoods
// also drop gray (unselected) points from the graphs.
const mapViewSource = {};
const mapView = vg.Selection.intersect();

function publishMapView() {
  const bounds = map.getBounds();
  const selected = selectedNeighborhoods.size
    ? [...selectedNeighborhoods]
    : null;
  mapView.update(clauseComposite(
    [
      {type: "interval", field: "lon", value: [bounds.getWest(), bounds.getEast()]},
      {type: "interval", field: "lat", value: [bounds.getSouth(), bounds.getNorth()]},
      {type: "point", field: "nta", value: selected}
    ],
    {source: mapViewSource}
  ));
}

function syncNeighborhoodPanel() {
  const show = mapUi.selectMode;
  document.querySelector("#neighborhood-list").hidden = !show;
  document.querySelector("#neighborhood-tools").hidden = !show;
  document.querySelector("#inspect-mode-note").hidden = show;
  document.querySelector("#select-mode-note").hidden = !show;
  const inspect = document.querySelector("#select-points");
  const picker = document.querySelector("#select-neighborhoods");
  inspect.classList.toggle("is-active", !show);
  inspect.setAttribute("aria-pressed", String(!show));
  picker.classList.toggle("is-active", show);
  picker.setAttribute("aria-pressed", String(show));
}

neighborhoodSelection.onChange = () => {
  syncNeighborhoodPanel();
  publishMapView();
};
neighborhoodSelection.onMode = syncNeighborhoodPanel;

function neighborhoodBranch(title, ids) {
  const details = document.createElement("details");
  details.className = "nta-branch";
  const summary = document.createElement("summary");
  const twist = document.createElement("span");
  twist.className = "nta-twist";
  twist.setAttribute("aria-hidden", "true");
  const label = document.createElement("label");
  label.className = "nta-row";
  const box = document.createElement("input");
  box.type = "checkbox";
  const name = document.createElement("span");
  name.textContent = title;
  label.append(box, name);
  label.addEventListener("click", (event) => event.stopPropagation());
  summary.append(twist, label);
  const children = document.createElement("div");
  children.className = "nta-children";
  details.append(summary, children);
  box.addEventListener("change", () => setNeighborhoods(ids, box.checked));
  neighborhoodGroups.push({box, ids});
  return {details, children};
}

const neighborhoodList = document.querySelector("#neighborhood-list");
for (const borough of neighborhoodHierarchy) {
  const boroughIds = borough.areas.flatMap((area) => area.neighborhoods.map((neighborhood) => neighborhood.id));
  const boroughBranch = neighborhoodBranch(borough.borough, boroughIds);
  for (const area of borough.areas) {
    const areaIds = area.neighborhoods.map((neighborhood) => neighborhood.id);
    const areaBranch = neighborhoodBranch(area.name, areaIds);
    for (const neighborhood of area.neighborhoods) {
      const label = document.createElement("label");
      label.className = "nta-row";
      const box = document.createElement("input");
      box.type = "checkbox";
      const name = document.createElement("span");
      name.textContent = neighborhood.name;
      label.append(box, name);
      box.addEventListener("change", () => {
        if (box.checked) selectedNeighborhoods.add(neighborhood.id);
        else selectedNeighborhoods.delete(neighborhood.id);
        commitNeighborhoodSelection();
      });
      neighborhoodLeaves.push({box, id: neighborhood.id});
      areaBranch.children.append(label);
    }
    boroughBranch.children.append(areaBranch.details);
  }
  neighborhoodList.append(boroughBranch.details);
}
const ntaSource = document.createElement("p");
ntaSource.className = "nta-source";
ntaSource.innerHTML = "2020 NTAs, NYC Open Data <code>9nt8-h7nd</code>.";
neighborhoodList.append(ntaSource);
syncNeighborhoodChecks();

document.querySelector("#select-points").addEventListener("click", () => {
  setSelectMode(false);
});
document.querySelector("#select-neighborhoods").addEventListener("click", () => {
  setSelectMode(true);
});
document.querySelector("#show-boundaries").addEventListener("change", (event) => {
  mapUi.showBoundaries = event.target.checked;
  boundaryManual[boundarySituation()] = event.target.checked;
  syncNeighborhoodLayers();
});
document.querySelector("#clear-neighborhoods").addEventListener("click", () => {
  clearNeighborhoodSelection();
});

let viewTimer = 0;
function scheduleMapView() {
  window.clearTimeout(viewTimer);
  viewTimer = window.setTimeout(publishMapView, 200);
}

const connector = new vg.DuckDBWASMConnector();
vg.coordinator().databaseConnector(connector);
const connection = await connector.getConnection();
const addressTable = tableFromArrays({
  lon: lonColumn,
  lat: latColumn,
  nta: neighborhoodIds,
  poverty: metrics.poverty,
  park_access: metrics.park_access,
  heat_vulnerability: metrics.heat_vulnerability,
  transit_access: metrics.transit_access
});
await connection.insertArrowFromIPCStream(tableToIPC(addressTable, "stream"), {
  name: "addresses",
  create: true
});

publishMapView();

const chartsRoot = document.querySelector("#metric-charts");
for (const name of metricOrder) {
  const section = document.createElement("section");
  section.className = "metric-chart";
  section.dataset.metric = name;
  const title = document.createElement("h3");
  title.textContent = layerMeta[name].shortLabel;
  const stats = document.createElement("p");
  stats.className = "metric-stats";
  const host = document.createElement("div");
  host.className = "metric-plot";
  host.append(vg.plot(
    vg.rectY(vg.from("addresses", {filterBy: mapView}), {
      x: vg.bin(name, {step: 5}),
      y: vg.count(),
      fill: colorOf(name, 70).formatHex(),
      inset: 0.5
    }),
    vg.xDomain([0, 100]),
    vg.yGrid(true),
    vg.xLabel(null),
    vg.yLabel(null),
    vg.yTickFormat("s"),
    vg.xTicks(5),
    vg.marginLeft(44),
    vg.marginRight(10),
    vg.marginTop(6),
    vg.marginBottom(22),
    vg.width(336),
    vg.height(124),
    vg.style({background: "transparent", color: "#1c1c1c", fontSize: "11px"})
  ));
  section.append(title, stats, host);
  section.addEventListener("click", () => setMapMetric(name));
  chartsRoot.append(section);
}

function markActiveChart(id) {
  for (const section of document.querySelectorAll(".metric-chart")) {
    section.classList.toggle("is-active", section.dataset.metric === id);
  }
}

markActiveChart(mapUi.layerId);

class ViewCountClient extends vg.MosaicClient {
  constructor(filterBy) {
    super(filterBy);
  }

  fields() {
    return [];
  }

  query(filter) {
    const columns = {n: vg.count()};
    for (const name of metricOrder) {
      columns[`${name}_mean`] = vg.avg(name);
      columns[`${name}_median`] = vg.median(name);
      columns[`${name}_ge50`] = vg.count().where(vg.gte(name, 50));
    }
    const query = vg.Query.from("addresses").select(columns);
    return filter ? query.where(filter) : query;
  }

  queryResult(data) {
    const n = Number(data.getChild("n").get(0));
    document.querySelector("#view-count").textContent = n.toLocaleString("en-US");
    document.querySelector("#graphs-loading").hidden = true;
    document.querySelector("#graphs-status").hidden = true;
    document.querySelector("#graphs-empty").hidden = n !== 0;
    document.querySelector("#metric-charts").hidden = n === 0;
    for (const name of metricOrder) {
      const line = document.querySelector(`.metric-chart[data-metric="${name}"] .metric-stats`);
      line.hidden = n === 0;
      if (n === 0) continue;
      const mean = Number(data.getChild(`${name}_mean`).get(0));
      const median = Number(data.getChild(`${name}_median`).get(0));
      const ge50 = Number(data.getChild(`${name}_ge50`).get(0));
      const percent = Math.round(ge50 / n * 100);
      line.textContent = `Mean ${mean.toFixed(1)} · Median ${median.toFixed(1)} · ${percent}% ≥ 50`;
    }
    return this;
  }

  queryError(error) {
    document.querySelector("#graphs-loading").hidden = true;
    const status = document.querySelector("#graphs-status");
    status.hidden = false;
    status.textContent = error instanceof Error ? error.message : String(error);
    return this;
  }
}

const viewCount = new ViewCountClient(mapView);
vg.coordinator().connect(viewCount);
map.on("moveend", scheduleMapView);
map.resize();

invalidation.then(() => {
  window.clearTimeout(viewTimer);
  map.off("moveend", scheduleMapView);
  narrowMedia.removeEventListener("change", syncMapToLayout);
  viewCount.destroy();
});
```

```js
mapReady;
mapUi.layerId = layerId;
renderLayers(true);
paintLegend();
markActiveChart(layerId);
if (popup.isOpen()) popup.setHTML(popupHtml(mapUi.popupIndex));
```
