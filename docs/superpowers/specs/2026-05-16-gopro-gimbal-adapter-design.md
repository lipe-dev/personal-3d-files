# GoPro Gimbal Adapter — Design Spec

**Date:** 2026-05-16  
**File:** `gopro-holder/gopro-gimbal-adapter.scad`

## Problem

Generic phone gimbals (spring-clamp type) can't hold a GoPro Hero directly. Need an adapter block that: (1) fits in the gimbal clamps like a phone, (2) presents a standard GoPro 3-prong mount at the top, (3) adds counterweight to compensate for GoPro being ~100g lighter than a typical phone.

## Shape — 3 stacked sections

```
┌──────────────────────────┐
│   GoPro 3-prong mount    │  top
├──────────────────────────┤
│      Clamp body          │  mid
├──────────────────────────┤
│     Counterweight        │  bottom
└──────────────────────────┘
```

## Modules

### `clamp_body()`
Rectangular block the gimbal spring clamps grip.
- Default: 75 × 12 × 55 mm
- All dims parametric via config block

### `gopro_mount()`
Standard GoPro 3-prong finger interface, centered on top face of clamp body.
- 3 prongs, each 5 mm wide, 9 mm tall, 15 mm deep
- 2 gaps of 2.5 mm between prongs
- Total mount width: 22.5 mm
- 5 mm pin hole through all prongs (horizontal, X axis)
- Prong base merges flush into clamp body top

### `counterweight()`
Solid block below clamp body, sized to hit `target_weight_g`.
- Height computed: `h = target_weight_g / (body_w * body_d * pla_density)`
- `pla_density = 0.00124` g/mm³
- Same W×D as clamp body for uniform profile
- Print at 100% infill

## Config block

```scad
body_w          = 75;    // gimbal clamp width (mm)
body_d          = 12;    // thickness gimbal grips (mm)
body_h          = 55;    // clamp zone height (mm)
target_weight_g = 100;   // counterweight target mass (g)
pla_density     = 0.00124; // g/mm³ at 100% infill
```

## Assembly

Counterweight at z=0, clamp body above it, GoPro prongs on top. Single `union()`. No external dependencies. `$fn = 64`.

## Print notes

- Counterweight section: 100% infill
- Rest: standard 15–20% infill, 3 walls
- Orientation: upright (prongs pointing up)
- No supports needed
