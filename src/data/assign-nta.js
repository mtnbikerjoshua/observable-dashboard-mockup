// One neighborhood id per address. 0 means the point is outside every NTA.
// Ids are 1-based and follow ntaAreas order. A boundary point stays with the
// first NTA that contains it.

const CELL = 0.0008;

export function assignAddressesToNtas(collection, ntaAreas, lonColumn, latColumn) {
  if (!collection?.features?.length) throw new Error("NTA polygons failed to load");
  if (lonColumn.length !== latColumn.length) {
    throw new Error(`lon has ${lonColumn.length} values and lat has ${latColumn.length}`);
  }

  const byCode = new Map();
  for (const feature of collection.features) {
    const code = feature.properties?.nta2020;
    const name = feature.properties?.ntaname;
    const borough = feature.properties?.boroname;
    if (!code || !name || !borough || !feature.geometry) {
      throw new Error("An NTA polygon is missing nta2020, ntaname, boroname, or geometry");
    }
    if (byCode.has(code)) throw new Error(`Duplicate NTA polygon ${code}`);
    byCode.set(code, feature);
  }

  const neighborhoods = [];
  const hierarchy = [];
  const used = new Set();
  for (const group of ntaAreas) {
    const areas = [];
    for (const area of group.areas) {
      const leaves = [];
      for (const code of area.ntas) {
        const feature = byCode.get(code);
        if (!feature) {
          throw new Error(`${code} is listed under ${group.borough} / ${area.name} but has no polygon`);
        }
        if (feature.properties.boroname !== group.borough) {
          throw new Error(`${code} is in ${feature.properties.boroname}, listed under ${group.borough}`);
        }
        const id = neighborhoods.length + 1;
        const neighborhood = {
          id,
          code,
          name: feature.properties.ntaname,
          borough: group.borough,
          area: area.name
        };
        feature.id = id;
        feature.properties = {
          name: neighborhood.name,
          borough: neighborhood.borough,
          area: neighborhood.area
        };
        neighborhoods.push(neighborhood);
        leaves.push(neighborhood);
        used.add(code);
      }
      areas.push({name: area.name, neighborhoods: leaves});
    }
    hierarchy.push({borough: group.borough, areas});
  }
  for (const [code, feature] of byCode) {
    if (!used.has(code)) {
      throw new Error(`NTA ${code} (${feature.properties.ntaname ?? feature.properties.name}) is not in an area`);
    }
  }

  const polygons = neighborhoods.map((neighborhood) =>
    preparePolygon(byCode.get(neighborhood.code), neighborhood.id)
  );
  const neighborhoodIds = locatePoints(polygons, lonColumn, latColumn);
  return {neighborhoods, hierarchy, neighborhoodIds};
}

function preparePolygon(feature, ntaId) {
  const geometry = feature.geometry;
  const partsIn = geometry.type === "Polygon"
    ? [geometry.coordinates]
    : geometry.type === "MultiPolygon"
      ? geometry.coordinates
      : null;
  if (!partsIn) throw new Error(`NTA ${ntaId} geometry is ${geometry.type}`);
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  const parts = [];
  for (const rings of partsIn) {
    if (!rings?.length) throw new Error(`NTA ${ntaId} has an empty polygon part`);
    const outer = flattenRing(rings[0]);
    const holes = rings.slice(1).map(flattenRing);
    for (const flat of [outer, ...holes]) {
      for (let i = 0; i < flat.length; i += 2) {
        const x = flat[i];
        const y = flat[i + 1];
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
    parts.push({outer, holes});
  }
  return {ntaId, minX, minY, maxX, maxY, parts};
}

function flattenRing(ring) {
  const flat = new Float64Array(ring.length * 2);
  for (let i = 0; i < ring.length; i++) {
    flat[i * 2] = ring[i][0];
    flat[i * 2 + 1] = ring[i][1];
  }
  return flat;
}

function locatePoints(polygons, lonColumn, latColumn) {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;
  for (const poly of polygons) {
    if (poly.minX < minX) minX = poly.minX;
    if (poly.minY < minY) minY = poly.minY;
    if (poly.maxX > maxX) maxX = poly.maxX;
    if (poly.maxY > maxY) maxY = poly.maxY;
  }
  const originX = minX - CELL;
  const originY = minY - CELL;
  const cols = Math.ceil((maxX - originX) / CELL) + 1;
  const rows = Math.ceil((maxY - originY) / CELL) + 1;
  const grid = new Uint16Array(cols * rows);
  const mixed = new Uint8Array(cols * rows);
  const candidates = new Map();

  function addCandidate(cell, polyIndex) {
    let list = candidates.get(cell);
    if (!list) {
      list = [];
      candidates.set(cell, list);
    } else if (list.includes(polyIndex)) {
      return;
    }
    list.push(polyIndex);
    mixed[cell] = 1;
  }

  function walkEdge(x1, y1, x2, y2, polyIndex) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    const stepCol = dx > 0 ? 1 : dx < 0 ? -1 : 0;
    const stepRow = dy > 0 ? 1 : dy < 0 ? -1 : 0;
    let col = Math.floor((x1 - originX) / CELL);
    let row = Math.floor((y1 - originY) / CELL);
    const colEnd = Math.floor((x2 - originX) / CELL);
    const rowEnd = Math.floor((y2 - originY) / CELL);
    const tDeltaCol = stepCol === 0 ? Infinity : Math.abs(CELL / dx);
    const tDeltaRow = stepRow === 0 ? Infinity : Math.abs(CELL / dy);
    let tMaxCol = Infinity;
    let tMaxRow = Infinity;
    if (stepCol > 0) tMaxCol = (originX + (col + 1) * CELL - x1) / dx;
    else if (stepCol < 0) tMaxCol = (originX + col * CELL - x1) / dx;
    if (stepRow > 0) tMaxRow = (originY + (row + 1) * CELL - y1) / dy;
    else if (stepRow < 0) tMaxRow = (originY + row * CELL - y1) / dy;
    if (tMaxCol < 0) tMaxCol = 0;
    if (tMaxRow < 0) tMaxRow = 0;
    const limit = Math.abs(colEnd - col) + Math.abs(rowEnd - row) + 4;
    for (let n = 0; n < limit; n++) {
      if (col >= 0 && row >= 0 && col < cols && row < rows) addCandidate(row * cols + col, polyIndex);
      if (col === colEnd && row === rowEnd) return;
      if (tMaxCol < tMaxRow) {
        col += stepCol;
        tMaxCol += tDeltaCol;
      } else if (tMaxRow < tMaxCol) {
        row += stepRow;
        tMaxRow += tDeltaRow;
      } else {
        col += stepCol;
        row += stepRow;
        tMaxCol += tDeltaCol;
        tMaxRow += tDeltaRow;
      }
    }
    throw new Error(`NTA edge walk failed for polygon ${polygons[polyIndex].ntaId}`);
  }

  polygons.forEach((poly, polyIndex) => {
    for (const part of poly.parts) {
      const rings = [part.outer, ...part.holes];
      for (const flat of rings) {
        const n = flat.length >> 1;
        for (let i = 0; i < n; i++) {
          const j = (i + 1) % n;
          walkEdge(flat[i * 2], flat[i * 2 + 1], flat[j * 2], flat[j * 2 + 1], polyIndex);
        }
      }
    }
    const row0 = Math.max(0, Math.floor((poly.minY - originY) / CELL));
    const row1 = Math.min(rows - 1, Math.floor((poly.maxY - originY) / CELL));
    for (let row = row0; row <= row1; row++) {
      const y = originY + (row + 0.5) * CELL;
      const xs = [];
      for (const part of poly.parts) {
        for (const flat of [part.outer, ...part.holes]) {
          const n = flat.length >> 1;
          let x1 = flat[(n - 1) * 2];
          let y1 = flat[(n - 1) * 2 + 1];
          for (let i = 0; i < n; i++) {
            const x2 = flat[i * 2];
            const y2 = flat[i * 2 + 1];
            if ((y1 > y) !== (y2 > y)) xs.push(((x2 - x1) * (y - y1)) / (y2 - y1) + x1);
            x1 = x2;
            y1 = y2;
          }
        }
      }
      xs.sort((a, b) => a - b);
      const base = row * cols;
      for (let k = 0; k + 1 < xs.length; k += 2) {
        let c0 = Math.floor((xs[k] - originX) / CELL);
        let c1 = Math.floor((xs[k + 1] - originX) / CELL);
        if (c0 < 0) c0 = 0;
        if (c1 >= cols) c1 = cols - 1;
        for (let col = c0; col <= c1; col++) {
          const cell = base + col;
          if (!mixed[cell]) grid[cell] = poly.ntaId;
        }
      }
    }
  });

  const neighborhoodIds = new Uint16Array(lonColumn.length);
  const maxXGrid = originX + cols * CELL;
  const maxYGrid = originY + rows * CELL;
  for (let i = 0; i < lonColumn.length; i++) {
    const x = lonColumn[i];
    const y = latColumn[i];
    if (x < originX || y < originY || x >= maxXGrid || y >= maxYGrid) continue;
    const col = Math.floor((x - originX) / CELL);
    const row = Math.floor((y - originY) / CELL);
    const cell = row * cols + col;
    if (!mixed[cell]) {
      neighborhoodIds[i] = grid[cell];
      continue;
    }
    const list = candidates.get(cell);
    let found = 0;
    if (list) {
      for (const polyIndex of list) {
        if (polyContains(polygons[polyIndex], x, y)) {
          found = polygons[polyIndex].ntaId;
          break;
        }
      }
    }
    if (found === 0 && grid[cell] !== 0) {
      const filled = polygons[grid[cell] - 1];
      if (filled && polyContains(filled, x, y)) found = filled.ntaId;
    }
    neighborhoodIds[i] = found;
  }
  return neighborhoodIds;
}

function polyContains(poly, x, y) {
  if (x < poly.minX || x > poly.maxX || y < poly.minY || y > poly.maxY) return false;
  for (const part of poly.parts) {
    if (!ringContains(x, y, part.outer)) continue;
    let inHole = false;
    for (const hole of part.holes) {
      if (ringContains(x, y, hole)) {
        inHole = true;
        break;
      }
    }
    if (!inHole) return true;
  }
  return false;
}

function ringContains(x, y, flat) {
  const n = flat.length >> 1;
  let inside = false;
  let x1 = flat[(n - 1) * 2];
  let y1 = flat[(n - 1) * 2 + 1];
  for (let i = 0; i < n; i++) {
    const x2 = flat[i * 2];
    const y2 = flat[i * 2 + 1];
    const dx = x2 - x1;
    const dy = y2 - y1;
    const len2 = dx * dx + dy * dy;
    if (len2 > 0) {
      const cross = (x - x1) * dy - (y - y1) * dx;
      if (cross * cross <= 1e-20 * len2) {
        const dot = (x - x1) * dx + (y - y1) * dy;
        if (dot >= 0 && dot <= len2) return true;
      }
    }
    if ((y1 > y) !== (y2 > y) && x < (dx * (y - y1)) / dy + x1) inside = !inside;
    x1 = x2;
    y1 = y2;
  }
  return inside;
}
