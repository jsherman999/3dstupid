# People Swarm — 3D Attribute Explorer

An interactive 3D visualization that plots people as labeled spheres across three axes — **Intelligence**, **Evil**, and **Having a Good Time** — and lets you scrub through a day-by-day timeline to watch how events affect the population over a year.

![Axes: Intelligence (X, red), Evil (Z, green), Good Time (Y/up, blue)](https://img.shields.io/badge/Three.js-r128-blue)

## What It Does

Each person is a colored globe positioned in 3D space according to their three attribute values (0–100). Intelligence is fixed; Evil and Good Time drift randomly day-to-day via a seeded Gaussian random walk. You can define **time events** that shift everyone's Good Time up or down by a percentage, with optional per-person overrides — then scrub through the timeline to see the swarm react.

Drop lines connect each globe to the Intelligence/Evil floor plane, making it easy to read Good Time (height) at a glance.

## Quick Start

### Option 1: Just open it
```
open particle-swarm.html
```

### Option 2: Serve locally (avoids some browser file:// restrictions)
```
python3 -m http.server 8420
# then visit http://localhost:8420/particle-swarm.html
```

### Option 3: launchd (macOS — always running)
See [launchd setup](#launchd-setup) below.

## Controls

### 3D Viewport
- **Left-drag** — Orbit camera
- **Right-drag** — Pan
- **Scroll wheel** — Zoom
- **Space** — Play/pause
- **← →** — Step ±1 day
- **↑ ↓** — Step ±30 days
- **Home / End** — Jump to start/end

### Left Panel
- **People** — Add/remove people (up to 50), edit names, set initial attribute values. Intelligence is read-only after creation.
- **Events** — Add events at the current day. Each event applies a signed percentage change to Good Time (negative = reduce, positive = boost). Expand an event to set per-person overrides.
- **Drift** — Control the magnitude of daily random drift for Evil and Good Time. Change the seed for a different random sequence.
- **Display** — Toggle name labels, motion trails, drop lines, axes, grid. Change background color and axis labels.

### Bottom Timeline
- **Scrubber bar** with month labels (Jan–Dec) and red event markers. Click or drag to scrub.
- **◄◄ / ◄ / ► / ►►** — Step ±1 or ±30 days.
- **Play** button with adjustable speed.

## Architecture

Single self-contained HTML file. No build step, no dependencies beyond a CDN-loaded Three.js.

| Component | Implementation |
|---|---|
| 3D rendering | Three.js r128 (WebGL) via CDN |
| Sphere materials | `MeshPhongMaterial` with specular highlights, emissive glow |
| Lighting | Ambient + Directional + Hemisphere (three-point) |
| Camera | Custom orbit controls (no OrbitControls import needed) |
| Random walk | Seeded PRNG (`mulberry32`) + Box-Muller Gaussian transform |
| Timeline data | Pre-computed `Float32Array` — `[days × people × 3]` |
| Name labels | CSS overlays projected from 3D via `Vector3.project()` |
| Drop lines | `LineBasicMaterial` segments from each sphere to Y=0 |
| UI | Vanilla JS DOM, no framework |

### Axis Mapping

The timeline stores attributes as `[intelligence, evil, goodTime]` per person per day. These map to 3D coordinates as:

| Attribute | 3D Axis | Direction | Color |
|---|---|---|---|
| Intelligence | X | Right | Red |
| Evil | Z | Depth | Green |
| Good Time | Y | **Up** | Blue |

Scale factor: attribute value 0–100 maps to 3D coordinate 0–50 (`CFG.scale = 0.5`).

### Event System

Events store a signed percentage (`-100` to `+100`). On the event's day, each person's Good Time is multiplied by `(1 + pct/100)`. A value of `-25` reduces Good Time by 25%; `+25` boosts it by 25%. Per-person overrides (keyed by stable person ID) let you customize the effect for individuals.

## launchd Setup

A `com.peopleswarm.server.plist` file is included for macOS. It runs a Python HTTP server on port 8420, serving the project directory. To install:

```bash
# Copy the plist to your LaunchAgents
cp com.peopleswarm.server.plist ~/Library/LaunchAgents/

# Edit the plist to update the WorkingDirectory path if needed
# (it should point to wherever you cloned this repo)

# Load and start
launchctl load ~/Library/LaunchAgents/com.peopleswarm.server.plist

# Visit in browser
open http://localhost:8420/particle-swarm.html
```

To stop:
```bash
launchctl unload ~/Library/LaunchAgents/com.peopleswarm.server.plist
```

To check status:
```bash
launchctl list | grep peopleswarm
```

## Future Ideas

- Bind attractor points to external data sources (APIs, CSV)
- Export timeline data as JSON/CSV for analysis
- Python data pipeline to populate people/events from spreadsheets
- Multiple event types (affecting Evil, or multiple attributes)
- Snapshot comparison mode (side-by-side days)

## License

MIT
