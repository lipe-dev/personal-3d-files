# Pokeball Plus Auto-Press Button Holder — Design

## Goal

3D-printable device that holds the top button of a Pokemon Pokeball Plus pressed, with a reliable on/off toggle. Replaces an existing latch-style design that loses tension over time due to plastic creep at the snap-fit point.

## Constraints

- **Pokeball Plus dimensions:** 48 mm sphere
- **Top button:** ~18 mm diameter, located at top pole
- **Front button:** on front face — must remain unobstructed (not pressed by holder)
- **Charge port / strap loop:** on rear face — must remain accessible
- **Hardware on hand:** M3 screws + nuts (existing user inventory)
- **Failure mode to avoid:** continuous load on a flexing/snapping plastic feature (creep, fatigue)

## Approach

C-clamp-style screw mechanism. Threads distribute clamp load across many turns of engagement instead of one stressed snap-fit, eliminating the creep failure mode.

A side-wrapping strap (left ↔ right axis) holds the device on the ball, leaving front and rear faces fully clear. A clamp tower at the top contains a thumbscrew with a swiveling pad that descends onto the 18 mm top button.

## Parts

Four printed parts, color-coordinated to match Pokeball aesthetic:

| # | Name              | Color (filament) | Qty |
|---|-------------------|------------------|-----|
| 1 | Top arc           | Red              | 1   |
| 2 | Left middle stub  | Black            | 1   |
| 3 | Right middle stub | Black            | 1   |
| 4 | Bottom arc        | White (or gray)  | 1   |
| 5 | Plunger thumbscrew | Any              | 1   |
| 6 | Swivel pad        | Any              | 1   |

Hardware: 2× M3 socket-head cap screws, 12 mm long. 2× M3 hex nuts.

## Geometry

### Sphere socket

All four arc/stub inner faces share a 48 mm-diameter spherical inner profile. Light tolerance (~0.3 mm clearance) so ball seats without forcing.

### Top arc (red)

- Spans top hemisphere from left equator to right equator, passing over the top pole
- Band width: ~15 mm (in the front↔back direction, narrow enough to clear front button + rear port)
- Wall thickness in screw-mating zone (each end): **5 mm**
- Each end has a vertical M3 through-hole with a **5 mm Ø rounded counterbore** on the upper face, for socket-head cap screw head recess
- Apex carries the integrated clamp tower (see below)

### Black middle stubs (L and R)

- Two mirrored small blocks, each sitting on the equator at left and right
- Thickness (height between top arc end and bottom arc end): **3 mm**
- Footprint matches the arc end profile, with smooth transition outer face
- Vertical M3 through-hole, aligned with arc holes

### Bottom arc (white)

- Mirrors top arc geometry across the equator: spans bottom hemisphere from left to right under the bottom pole
- Same 15 mm band width
- Wall thickness in screw zone: **5 mm**
- Each end has an M3 through-hole topped with a **hex recess** sized for an M3 nut (6.0 mm across-flats, ~2.6 mm deep, +0.2 mm tolerance for fit)
- Nut drops in from above (the face that mates with the black stub), captured between the stub and the recess floor

### Clamp tower (on top arc)

- Hollow cylinder rising from top arc apex, centered over the 18 mm top button
- Outer diameter: ~16 mm
- Height above arc: ~20 mm
- Top wall has internal M8 printed thread (coarse, single start, ~1.25 mm pitch — easy to print FDM, low backlash)
- Bottom of tower (button side) is open, plunger swivel pad fits within bore

### Plunger thumbscrew

- M8 threaded shaft matching tower threads
- Knurled knob on top: ~20 mm Ø, ~6 mm tall, easy to grip and twist by hand
- Bottom tip has a snap-capture groove for the swivel pad (~1 mm wide groove, 0.6 mm deep)

### Swivel pad

- Disc, ~16 mm Ø
- Snap-fits onto plunger tip groove via a central socket with retention lip; rotates freely on screw tip so its contact face does not twist on the Pokeball button when the screw turns
- Contact face flat or very slightly domed

## Hardware Stack-up

Per side:

```
[allen head + counterbore]   ← top of red arc
   |
   v   M3 shaft passes through:
[ 5 mm red arc ]
[ 3 mm black stub ]
[ 5 mm white arc with hex nut at top ]
   ^
   |  M3 nut sits in hex recess facing black stub

Total stack: 5 + 3 + 5 = 13 mm
Screw length: 12 mm
Counterbore depth: ~3 mm  →  thread engagement: ~9 mm into the assembly
                              of which ~4 mm reaches/passes through the nut
```

Tightening the M3s clamps red→black→white firmly around the equator on each side.

## Toggle Action

- **Engage:** twist plunger knob clockwise. Threaded shaft descends through tower. Swivel pad presses on 18 mm top button. Stop when resistance feels firm. Threads distribute load along the engaged length — no flexing snap, no creep.
- **Disengage:** twist counterclockwise. Swivel pad lifts off button. Button releases.

## Print Orientation & Settings

- **Top arc:** print with mating face UP (counterbores point up, print clean). Outer dome curves toward bed; the two arc ends each have a flat mating pad (5 mm thick, the screw zone) that sits flat on the bed and supports the print. Curved span between ends bridges/arches above the bed — short enough that no support is needed if the arc's lowest underside angle stays above ~45° from horizontal. Tower projects upward from the mating face — prints cleanly above the part.
- **Black stubs:** mating face down (or up, symmetric). Trivial print, no supports.
- **Bottom arc:** print with mating face UP (hex recesses point up, drop nuts in cleanly, no support needed in cavity). The two flat 5 mm screw-zone pads at each end sit on the bed; outer dome arches above. Same bridging consideration as top arc.
- **Plunger thumbscrew:** knob up, threads vertical. Printed M8 threads should be tuned (vertical printed threads usually need ~0.2 mm radial clearance in OpenSCAD `thread()` modules).
- **Swivel pad:** flat, contact face up.

Filament: PETG recommended for the load-bearing parts (top arc, bottom arc, plunger) due to better creep resistance than PLA. PLA acceptable for stubs (low load).

## Tolerances Summary

| Feature                       | Nominal | Tolerance |
|-------------------------------|---------|-----------|
| Sphere socket inner Ø         | 48.3 mm | +0.3 mm clearance over 48 mm ball |
| M3 through-hole               | 3.4 mm  | +0.4 mm clearance |
| Hex nut recess (across flats) | 6.0 mm  | +0.2 mm |
| Hex nut recess depth          | 2.6 mm  | +0.2 mm |
| Counterbore (allen head)      | 5.0 mm  | as drawn |
| M8 printed thread clearance   | -       | radial 0.2 mm |
| Swivel pad snap groove        | 1.0 mm  | -0.1 mm for retention |

## Repository Structure

OpenSCAD source files to be added under `pokeball-plus-button-holder/`:

- `params.scad` — shared dimensions / tolerances
- `top-arc.scad` — top arc with integrated clamp tower
- `middle-stub.scad` — single mirrored module used for both L and R
- `bottom-arc.scad` — bottom arc with hex nut recesses
- `plunger.scad` — thumbscrew + swivel pad
- `preview-all.scad` — full assembly preview

## Out of Scope

- No electronic components, no motors, no automation beyond the manual screw toggle
- No charging-while-engaged dock integration (rear port is left clear; user manages cable separately)
- No retention features for the strap loop on the rear (strap loop area is simply not enclosed)
