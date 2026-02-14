# Makeup Organizer — Development Notes

A detailed account of designing and building a fully parametric, Gridfinity-compatible makeup organizer in OpenSCAD, with AI-assisted development using Claude Code.

---

## The Concept

A modular makeup organizer system built around the Gridfinity standard — the popular open-source grid system for workshop and desk organization. The organizer consists of **trays** (outer shells that sit on the Gridfinity baseplate) and **cups** (removable inserts that hold actual items). The trays feature interchangeable decorative exteriors and configurable interior layouts.

The key design goals:
- **Gridfinity compatibility** — sits perfectly on standard baseplates
- **Parametric everything** — change one number, the whole design updates
- **Three tray styles** — straight, rounded (Minkowski), and puffed (sine bulge)
- **Pluggable decorations** — switch between decoration styles with a single variable
- **Configurable interiors** — multi-cup layouts with optional divider walls and through-holes

---

## Core Geometry: The Stadium Shape

The fundamental 2D profile is a **stadium** (rectangle with semicircular or rounded ends). Rather than using OpenSCAD's `square()` with `offset()`, we build it from four corner circles joined with `hull()`:

```openscad
module stadium(w, d, r=0) {
    cr = r > 0 ? min(r, min(w,d)/2) : min(w,d)/2;
    dx = w/2 - cr;
    dy = d/2 - cr;
    hull() {
        translate([-dx, -dy]) circle(r=cr);
        translate([ dx, -dy]) circle(r=cr);
        translate([-dx,  dy]) circle(r=cr);
        translate([ dx,  dy]) circle(r=cr);
    }
}
```

This approach allows independent control of the corner radius — from sharp rectangles (`r` very small) to full capsule shapes (`r = w/2`). Every tray body, cup, cavity, and decoration band is built on this primitive.

---

## The Decoration Budget System

A central design concept is the **decoration budget** — a fixed band of space (`decor_budget = 5mm`) reserved between the Gridfinity grid boundary and the tray wall. This budget is what decorations "spend" to add visual interest:

```
Gridfinity grid edge
    ├── decor_budget (5mm) ──┤
    │  puff_max │  wall_t │  interior
    │   (2mm)   │ (1.2mm) │
```

- The tray dimensions are inset from the grid by `decor_budget` on each side
- Outward-protruding decorations (columns, bricks, honeycomb bands) use the space between the tray wall and the grid edge
- The puffed tray's sine bulge consumes `puff_max` (2mm) of this budget at its widest
- Remaining budget after the puff = `decor_budget - puff_max = 3mm` available for decoration depth

This system guarantees that no decoration ever extends past the Gridfinity grid boundary, regardless of which style is selected.

---

## Three Tray Styles

### Straight Tray (`tray-straight.scad`)

The simplest: a `linear_extrude()` of the stadium profile. The tray dimensions are expanded by `puff_max` so that all three tray styles occupy the same Gridfinity footprint:

```openscad
tw = tray_w + 2*puff_max;
td = tray_d + 2*puff_max;
tr = end_r + puff_max;
linear_extrude(tray_h) stadium(tw, td, tr);
```

### Rounded Tray (`tray-rounded.scad`)

Uses Minkowski sum of the base stadium extrusion with a sphere to produce smooth, rounded edges on all corners:

```openscad
cr = min(round_r, tray_h/2);
translate([0, 0, cr])
    minkowski() {
        linear_extrude(tray_h - 2*cr)
            stadium(tray_w, tray_d, end_r);
        sphere(r=cr);
    }
```

The base extrusion is shortened by `2*cr` so the Minkowski expansion brings it back to the correct height. Decorations for this style are clipped to avoid extending past the rounded edges.

### Puffed Tray (`tray-puffed.scad`)

A sine-wave bulge profile, built from 30 stacked slices with varying widths:

```openscad
for (i = [0:puff_slices-1]) {
    z = i * slice_h;
    bulge = puff_max * sin(i / puff_slices * 180);
    translate([0, 0, z])
        linear_extrude(slice_h + 0.01)
            stadium(tray_w + 2*bulge, tray_d + 2*bulge, end_r + bulge);
}
```

Each slice overlaps by 0.01mm to prevent gaps. The sine function goes from 0 at the base, peaks at `puff_max` at the midpoint, and returns to 0 at the top. All puffed-style decorations must follow this same curve.

---

## Stadium Perimeter Functions

To place decorations evenly around the tray, we need to walk along the stadium perimeter mathematically. Three functions handle this:

- **`stad_perim(w, d, r)`** — total perimeter length (4 straight segments + 4 quarter-circle arcs)
- **`stad_pos(s, w, d, r)`** — XY position at distance `s` along the perimeter
- **`stad_tangent(s, w, d, r)`** — tangent direction at distance `s` (computed via finite difference)

The perimeter walk starts at the bottom-right corner arc, goes up the right side, around the top-right arc, across the top, and so on. Every decoration element (column, brick, hex cell) uses these functions to position itself on the perimeter and orient itself tangent to the surface.

From the tangent, we derive the **outward normal** for pushing decorations to the correct radial depth:

```openscad
nx = tangent[1]; ny = -tangent[0];  // 90° rotation of tangent = outward normal
```

---

## Decoration System Architecture

### The Selection Variable

A single string variable controls which decoration is active:

```openscad
decoration = "honeycomb";  // "none", "columns", "bricks", "honeycomb", "fluting"
```

Each tray file checks this variable and calls the appropriate decoration modules. This replaced an earlier approach of setting individual decoration depth parameters to 0, which was error-prone.

### CSG Order of Operations (Critical Lesson)

The order in which geometry is unioned and subtracted matters enormously. Through trial and error, we established this pattern:

```openscad
difference() {
    union() {
        tray_body;           // 1. Base tray shape
        decoration_geometry; // 2. Decorations added to exterior
        tray_interior_add(); // 3. Cup sleeves (inner structure)
    }
    decoration_cuts;         // 4. Decoration subtractions (hex holes, grooves)
    tray_interior_cut();     // 5. Hollow out interior cavity
}
```

**Why the cup sleeves must be inside the union**: If `tray_interior_add()` (cup sleeves) runs *after* the difference, it adds solid material on top of everything — covering up any inward-punching decoration holes. By placing it inside the union, the sleeves become part of the body that gets cut.

**Why decoration cuts must be at the tray level**: For decorations that punch inward (like honeycomb with `hex_inner > 0`), the hex holes need to subtract from both the decoration band *and* the tray wall. If the subtraction happens inside the decoration module, it only cuts the band.

### The Split Add/Cut Pattern

For decorations that optionally punch inward, we split each decoration into:
- **`decoration_add()`** — solid material to union with the body
- **`decoration_holes()`** — cuts applied at the tray level (after the full union)

When `hex_inner > 0`, the tray uses the split approach. When `hex_inner == 0`, the self-contained `honeycomb_straight()` / `honeycomb_puffed()` modules handle everything internally.

---

## Decoration: Columns (`decor-columns.scad`)

Half-round pill-shaped columns evenly spaced around the perimeter. Two variants:

### Straight Columns
Placed at stadium perimeter positions with rounded sphere caps:

```openscad
module col_pill(cr, h) {
    hull() {
        translate([0, 0, col_margin])     sphere(r=cr);
        translate([0, 0, h - col_margin]) sphere(r=cr);
    }
}
```

### Puffed Columns
Each column follows the sine bulge curve by being built from hulled sphere segments:

```openscad
module col_puff(cr, h, px, py) {
    for (j = [0:steps-1]) {
        b0 = puff_max * sin(z0 / h * 180);
        b1 = puff_max * sin(z1 / h * 180);
        hull() {
            translate([px + nx*b0, py + ny*b0, z0]) sphere(r=cr);
            translate([px + nx*b1, py + ny*b1, z1]) sphere(r=cr);
        }
    }
}
```

The column center is pushed outward by the bulge amount at each height, and adjacent segments are hulled together to create a smooth, curved column.

**Parameters**: `col_r` (radius, max = `decor_budget - puff_max`), `col_spacing` (center-to-center, 20mm), `col_margin` (top/bottom inset, 5mm).

---

## Decoration: Bricks (`decor-bricks.scad`)

Beveled bricks in a running-bond (offset) pattern. Each brick is a hull between two trapezoids — a larger front face and a smaller back face inset by the bevel amount:

```openscad
hull() {
    // Front face — full size
    translate([0, brick_depth/2, 0])
        rotate([90, 0, 0])
            linear_extrude(0.01)
                polygon([[-bw/2, -bh/2], [bw/2, -bh/2],
                         [bw/2, bh/2],   [-bw/2, bh/2]]);
    // Back face — inset by bevel
    translate([0, -brick_depth/2, 0])
        rotate([90, 0, 0])
            linear_extrude(0.01)
                polygon([[-bw/2+bevel, -bh/2+bevel], [bw/2-bevel, -bh/2+bevel],
                         [bw/2-bevel, bh/2-bevel],   [-bw/2+bevel, bh/2-bevel]]);
}
```

This produces a chamfered, tapered brick shape that looks good when 3D printed. The running-bond pattern offsets every other row by half a brick length.

### Design Iterations
- First attempt used Minkowski with spheres — far too computationally heavy for OpenSCAD
- Switched to hull of trapezoids — fast and visually clean
- Initial trapezoids were in the wrong plane (XY instead of XZ), making bricks paper-thin and sideways
- Fixed with `rotate([90, 0, 0])` to orient them perpendicular to the tray surface
- Tuned to print-friendly sizes: `brick_h=7`, `brick_len=16`, `brick_gap=1.2` (3 nozzle widths), `brick_bevel=0.8`

**Parameters**: `brick_h` (7mm), `brick_len` (16mm), `brick_depth` (1.2mm protrusion), `brick_gap` (1.2mm mortar), `brick_bevel` (0.8mm chamfer), `brick_margin` (5mm top/bottom inset).

---

## Decoration: Honeycomb (`decor-honeycomb.scad`)

The most complex decoration — a hexagonal grid pattern that can protrude outward, punch inward, or both. This went through the most iterations of any feature.

### How It Works

A solid band is extruded around the tray (outer protrusion), then hexagonal holes (`$fn=6` cylinders) are subtracted in a staggered grid pattern:

```openscad
// Each hex cell is a 6-sided cylinder oriented perpendicular to the tray surface
rotate([0, 0, ang])        // face tangent to perimeter
    rotate([90, 0, 0])     // tip outward
        rotate([0, 0, 30]) // flat-side vertical (pointy-top orientation)
            cylinder(r=hex_r, h=hex_total+2, center=true, $fn=6);
```

### The Hex Grid

Hex cells are placed in a staggered grid — every other row is offset by half the perimeter spacing:

```openscad
for (row = [0:rows]) {
    offset_s = (row % 2) * p_step / 2;  // stagger
    for (i = [0:p_count-1]) {
        s = (i * p_step + offset_s) % perim;
        // place hex cell at perimeter position s, height z
    }
}
```

The grid is vertically centered on the tray with `z_offset = (h - grid_h) / 2`.

### Spacing Parameters (Hard-Won)

Getting uniform hex spacing was the longest iterative process. The relationship between hex size, wall thickness, and spacing went through many formulas:

- `hex_r*2+gap` — too tight
- `sqrt(3)*hex_r+gap` — mathematically correct for regular hexagons but didn't account for wall thickness
- Various multipliers from `1.5` down to `0.6` — all either too loose or too tight

Final formulas after extensive visual iteration:
```openscad
hex_p_sp = hex_size * 1.8;  // perimeter spacing
hex_h_sp = hex_size * 1.6;  // vertical row spacing
hex_r    = hex_size - hex_wall/2;  // actual hex cut radius
```

The key insight was decoupling `hex_size` (spacing reference) from `hex_wall` (wall thickness). Earlier versions used a single formula where changing wall thickness would distort the grid proportions.

### Dual-Depth Control: `hex_outer` and `hex_inner`

Instead of a simple boolean for inward mode, the final design uses two independent depth controls:

```openscad
hex_outer = 0;   // outward protrusion from tray wall (0 = flush)
hex_inner = 10;  // inward punch depth through tray wall (0 = no punch)
```

The hex cylinder is positioned so it spans exactly from `-hex_inner` to `+hex_outer` relative to the tray perimeter:

```openscad
center_offset = (hex_outer - hex_inner) / 2;
cx = pos[0] + nx * (center_offset + bulge_offset);
cy = pos[1] + ny * (center_offset + bulge_offset);
```

This allows:
- `hex_outer=3, hex_inner=0` — traditional outward band with hex pattern
- `hex_outer=0, hex_inner=5` — hexagons punched into the tray wall (no added material)
- `hex_outer=2, hex_inner=3` — both: outward band + inward punch-through
- `hex_outer=0, hex_inner=0` — disabled

### The Inward Punch Journey

Making hex holes punch through the tray wall was the most challenging problem:

1. **First attempt**: Added `hex_inward` boolean toggle. Holes only subtracted from the decoration band, not the tray body. *"Looks the same to me."*

2. **Split add/cut pattern**: Restructured into `honeycomb_*_add()` (solid band, no holes) and separate `hex_holes()` called at the tray level. The tray's `difference()` now subtracts hex holes from the entire union of body + band.

3. **Holes not deep enough**: The hex cylinder was centered on the band midpoint — it didn't reach past the tray wall to the interior cavity. Fixed by adjusting `center_offset` and increasing `hex_total`.

4. **Still showing a wall**: Even with deep-enough holes, a wall persisted. Root cause: `tray_interior_add()` (cup sleeves) was called *after* the main `difference()`, adding solid material on top of the hex holes. Fix: moved `tray_interior_add()` inside the `union()` so hex holes cut through the sleeves too.

5. **Replaced boolean with dual params**: `hex_inward` boolean replaced with `hex_outer` / `hex_inner` millimeter values for full control.

**Parameters**: `hex_size` (8mm spacing radius), `hex_wall` (1.2mm), `hex_outer` (outward depth), `hex_inner` (inward depth), `hex_margin` (5mm top/bottom inset).

---

## Decoration: Fluting (`decor-fluting.scad`)

Vertical half-round grooves carved into a thin outer band. Kept in the codebase but not actively used.

### How It Works

An outer band is extruded around the tray, then vertical cylinders are subtracted at evenly-spaced perimeter positions:

```openscad
difference() {
    // Outer band
    difference() {
        linear_extrude(h) stadium(w + 2*flute_depth, ...);
        linear_extrude(h + 2) stadium(w, d, r);
    }
    // Grooves
    for (i = [0:count-1]) {
        translate([pos + nx*flute_depth, ...])
            cylinder(r=flute_r, h=h+2);
    }
}
```

### Issues Encountered

- **"Normalized tree has 0 elements"**: Attempted 2D `difference()` inside `linear_extrude()`, which produces empty geometry in OpenSCAD. Fixed by using two separate 3D extrudes subtracted from each other.
- **Puffed variant too heavy**: With 30 slices × many grooves (each groove is hulled segments following the sine curve), the computation was prohibitive for multi-cup configurations.
- **Rounded tray overflow**: Fluting extended past the Minkowski-rounded edges. Fixed with intersection against the rounded envelope.
- **Aesthetic verdict**: *"I kinda hate fluting, let's scratch it."* — kept `flute_depth=0` as default but code remains for reference.

**Parameters**: `flute_depth` (3mm), `flute_r` (3mm groove radius), `flute_spacing` (10mm center-to-center), `flute_margin` (3mm inset).

---

## Decoration: Basket Weave (Scrapped)

An ambitious attempt at woven texture that was ultimately abandoned:

1. **Checkerboard bumps**: Spheres in a staggered grid — just looked like "a bunch of bumps"
2. **Elongated pills**: Spheres replaced with hull-based pills oriented along the tangent — "looks more like bricks"
3. **Tightened spacing**: Removed gaps — "just looks like vertical rows, no weaving effect"
4. **Depth offset for over/under**: Alternating pills pushed in/out to simulate weaving — still unconvincing

The fundamental problem: true weaving requires intersecting geometry that goes over *and* under, which is very hard to achieve with CSG operations on a curved surface. The effect never looked woven enough to justify the complexity.

---

## Interior Configuration

### Slot Arrays

The interior layout is controlled by two parallel arrays:

```openscad
slot_walls  = [1, 1, 0];  // 1 = walled pocket, 0 = open (merges with neighbors)
slot_floors = [1, 0, 1];  // 1 = solid floor, 0 = through-hole
```

Array length determines the number of cup positions. Each position can independently have walls (sleeve insert) and/or a floor. `0` in `slot_walls` creates an open cavity that merges with adjacent slots; `0` in `slot_floors` creates a through-hole (useful for items that need to poke through, or for weight reduction).

### Cup Sleeves

For walled slots, thin stadium-shaped tubes are added inside the tray cavity:

```openscad
module cup_sleeves() {
    difference() {
        linear_extrude(sh) stadium(cup_w + 2*sleeve_t, cup_d + 2*sleeve_t);
        linear_extrude(sh + 2) stadium(cup_w, cup_d);
    }
}
```

These sleeves define the pocket boundaries and provide a snug fit for removable cup inserts.

---

## Modularization: From Monolith to Modules

The entire system started as a single 607-line `organizer-cup.scad` file. Splitting it into modules was driven by:
- Each tray style should be independently renderable in OpenSCAD
- Decorations should be pluggable without touching tray code
- Parameters should live in one place

### Final File Structure

```
params.scad           — All configurable parameters (86 lines)
shared.scad           — Stadium, cup, cavity, perimeter functions (135 lines)
decor-columns.scad    — Column decoration (51 lines)
decor-bricks.scad     — Brick decoration (89 lines)
decor-honeycomb.scad  — Honeycomb decoration (106 lines)
decor-fluting.scad    — Fluting decoration (81 lines)
tray-straight.scad    — Straight tray (36 lines)
tray-rounded.scad     — Rounded tray (61 lines)
tray-puffed.scad      — Puffed tray (39 lines)
preview-all.scad      — Side-by-side comparison (48 lines)
```

### OpenSCAD Include Strategy

The critical lesson: **`use` vs `include` in OpenSCAD**.

- **`include <file>`** — pastes everything inline: variables, modules, functions, and executable code
- **`use <file>`** — imports *only* modules and functions; variables are **NOT** visible to the caller

This means **all parameters must live in `params.scad`**, and every file that needs them must use `include <params.scad>`. Initially, decoration parameters lived in their respective `decor-*.scad` files, but since tray files use `use <decor-*.scad>` (to get the modules), those variables were invisible — causing silent failures where decorations rendered with default/zero values.

The fix: move every parameter to `params.scad`, even decoration-specific ones. The decor files themselves also `include <params.scad>` to access the values.

---

## Debugging War Stories

### The Invisible Honeycomb
When `hex_inward` was first implemented, changing it from `false` to `true` produced no visible difference. Root cause: `honeycomb_straight()` did `difference() { band; hex_holes; }` internally — holes only cut the band, never the tray body. Required restructuring into the split add/cut pattern.

### The Phantom Wall
Even after hex holes were deep enough, a wall persisted between the hex holes and the tray interior. Root cause: `tray_interior_add()` (cup sleeves) was called after the main `difference()`, re-adding solid material on top of the holes. This was a subtle CSG ordering issue — the sleeves needed to be part of the union *before* the hex holes were subtracted.

### The Fluting Empty Tree
`difference()` between two 2D shapes inside `linear_extrude()` produces valid geometry mathematically, but OpenSCAD's CGAL backend chokes on it, producing "normalized tree has 0 elements." The fix: perform the difference in 3D (two separate `linear_extrude()` calls, then subtract).

### The Variable Scope Trap
After modularizing, changing `slot_walls = [1, 1, 1]` in `params.scad` caused mysterious rendering failures. The decoration parameters in `decor-*.scad` files were invisible to tray files because `use` doesn't import variables. Symptoms: decorations silently rendering at zero size or not at all. Fix: centralize ALL parameters in `params.scad`.

### Puffed Body Can't Use 2D Difference
The puffed tray body is built from 30 stacked slices. To create a hollow band for decorations, you can't subtract a 2D shape and then extrude — you need to create two separate 3D slice stacks and subtract one from the other:

```openscad
// WRONG — produces empty geometry:
linear_extrude(h)
    difference() { stadium(outer); stadium(inner); }

// CORRECT — 3D difference of two slice stacks:
difference() {
    for (i = ...) linear_extrude(...) stadium(outer + bulge);
    for (i = ...) linear_extrude(...) stadium(inner + bulge);
}
```

---

## Key Design Decisions

1. **Stadium over rectangle**: Rounded ends are more aesthetically pleasing and structurally stronger for 3D printing than sharp corners.

2. **Decoration budget over ad-hoc sizing**: Reserving a fixed space for decorations guarantees Gridfinity compatibility regardless of decoration choice.

3. **Single decoration variable**: Much cleaner UX than zeroing out individual depth parameters. One variable, one selection.

4. **Dual hex depth params over boolean**: `hex_outer` + `hex_inner` gives continuous control rather than just on/off. Enables creative combinations (flush exterior with punched-through walls, protruding band without punch-through, or both).

5. **30 puff slices**: Enough for smooth curves, not so many that rendering becomes prohibitive. The 0.01mm overlap between slices prevents visible seams.

6. **Scrapping ideas that don't work**: Basket weave and fluting were both abandoned when they didn't achieve the desired aesthetic. Better to move on than to over-engineer a poor visual effect.

---

## Parameter Reference

| Parameter | Value | Description |
|-----------|-------|-------------|
| `grid_pitch` | 42mm | Gridfinity standard grid size |
| `F` | 49mm | Height unit (7 × 7mm Gridfinity heights) |
| `decor_budget` | 5mm | Reserved space for decorations |
| `wall_t` | 1.2mm | Tray wall thickness |
| `puff_max` | 2mm | Maximum sine bulge outward |
| `puff_slices` | 30 | Number of slices for puffed body |
| `round_r` | 3mm | Minkowski rounding radius |
| `decoration` | string | Active decoration: "none"/"columns"/"bricks"/"honeycomb"/"fluting" |
| `col_r` | 3mm | Column radius |
| `col_spacing` | 20mm | Column center-to-center distance |
| `brick_h` | 7mm | Brick height |
| `brick_len` | 16mm | Brick length along perimeter |
| `brick_depth` | 1.2mm | Brick outward protrusion |
| `brick_bevel` | 0.8mm | Brick edge chamfer |
| `hex_size` | 8mm | Hex cell spacing radius |
| `hex_wall` | 1.2mm | Wall between hex cells |
| `hex_outer` | 0-5mm | Outward honeycomb protrusion |
| `hex_inner` | 0-10mm | Inward hex punch-through depth |
| `flute_depth` | 0mm | Fluting band depth (0 = disabled) |

---

## Tools and Workflow

- **OpenSCAD** — programmatic CAD with CSG (Constructive Solid Geometry)
- **Claude Code** — AI pair-programming assistant for iterative design
- **Workflow**: Describe desired change → Claude edits `.scad` files → Preview in OpenSCAD (F5) → Full render (F6) for boolean verification → Iterate

The iterative nature of this project — especially the honeycomb spacing tuning and the inward-punch debugging — was well-suited to AI-assisted development. Changes could be described in natural language ("make hex holes deeper", "0 outer, 5 inner") and applied instantly, with the visual feedback loop happening in OpenSCAD.
