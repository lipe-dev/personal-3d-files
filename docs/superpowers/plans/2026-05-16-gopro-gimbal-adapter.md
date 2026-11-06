# GoPro Gimbal Adapter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Single parametric SCAD file producing a 3-section GoPro-to-phone-gimbal adapter: solid counterweight block at bottom, clampable body in middle, standard 3-prong GoPro mount at top.

**Architecture:** One self-contained file with a config block, three modules (`counterweight`, `clamp_body`, `gopro_mount`), and a final assembly `union()`. No external library dependencies. Height of counterweight block is computed from `target_weight_g` and PLA density so the user can dial in the target mass.

**Tech Stack:** OpenSCAD (any recent version), no libraries.

---

### Task 1: Scaffold file with config block and empty modules

**Files:**
- Create: `gopro-holder/gopro-gimbal-adapter.scad`

- [ ] **Step 1: Create the file**

```scad
// GoPro Gimbal Adapter
// Bottom: counterweight block | Middle: gimbal clamp body | Top: GoPro 3-prong mount

$fn = 64;

/* ===================== CONFIGURE HERE ===================== */
body_w          = 75;      // gimbal clamp width (mm)
body_d          = 12;      // thickness gimbal grips (mm)
body_h          = 55;      // clamp zone height (mm)
target_weight_g = 100;     // counterweight target mass (g)
pla_density     = 0.00124; // g/mm³ at 100% infill
/* ========================================================== */

// --- Derived ---
cw_h = target_weight_g / (body_w * body_d * pla_density);

module counterweight() {}
module clamp_body() {}
module gopro_mount() {}

// Assembly
counterweight();
translate([0, 0, cw_h]) clamp_body();
translate([0, 0, cw_h + body_h]) gopro_mount();
```

- [ ] **Step 2: Open in OpenSCAD, press F5 — expect empty scene, no errors**

- [ ] **Step 3: Commit**

```bash
git add gopro-holder/gopro-gimbal-adapter.scad
git commit -m "feat: scaffold gopro gimbal adapter with config block"
```

---

### Task 2: Implement `counterweight()` module

**Files:**
- Modify: `gopro-holder/gopro-gimbal-adapter.scad`

- [ ] **Step 1: Replace empty `counterweight()` with solid block**

```scad
module counterweight() {
    cube([body_w, body_d, cw_h]);
}
```

- [ ] **Step 2: Press F5 in OpenSCAD**

Expected: rectangular block at bottom. Check console — `cw_h` should print ~67mm for defaults (100 / (75 × 12 × 0.00124) ≈ 89.5mm — adjust `target_weight_g` if block seems too tall).

- [ ] **Step 3: Center the geometry on X axis for symmetry**

Replace the `counterweight()` call in the assembly section:

```scad
translate([-body_w/2, -body_d/2, 0]) counterweight();
translate([-body_w/2, -body_d/2, cw_h]) clamp_body();
translate([-body_w/2, -body_d/2, cw_h + body_h]) gopro_mount();
```

And update `counterweight()` to use local coords (block starts at origin internally, centering handled by caller):

```scad
module counterweight() {
    cube([body_w, body_d, cw_h]);
}
```

- [ ] **Step 4: Press F5 — block should be centered on X/Y origin**

- [ ] **Step 5: Commit**

```bash
git add gopro-holder/gopro-gimbal-adapter.scad
git commit -m "feat: add counterweight block sized by target weight"
```

---

### Task 3: Implement `clamp_body()` module

**Files:**
- Modify: `gopro-holder/gopro-gimbal-adapter.scad`

- [ ] **Step 1: Replace empty `clamp_body()` with solid rectangular block**

```scad
module clamp_body() {
    cube([body_w, body_d, body_h]);
}
```

- [ ] **Step 2: Press F5**

Expected: two stacked blocks — shorter counterweight below (≈90mm), taller clamp body above (55mm). Combined looks like a thick rectangular slab.

- [ ] **Step 3: Commit**

```bash
git add gopro-holder/gopro-gimbal-adapter.scad
git commit -m "feat: add clamp body block"
```

---

### Task 4: Implement `gopro_mount()` module

**Files:**
- Modify: `gopro-holder/gopro-gimbal-adapter.scad`

GoPro standard 3-prong mount dimensions (hardcoded — these are a fixed standard):
- 3 prongs, each 5mm wide × 15mm deep × 9mm tall
- 2 gaps of 2.5mm between prongs
- Total mount width: 3×5 + 2×2.5 = 20mm (centered on body)
- Pin hole: 5mm diameter, runs through all prongs along X axis at mid-height of prongs (z = 4.5mm up from base of prongs)

- [ ] **Step 1: Add GoPro mount constants just below config block derived section**

```scad
// --- GoPro mount (fixed standard dims) ---
gp_prong_w  = 5;    // each prong width
gp_prong_d  = 15;   // prong depth
gp_prong_h  = 9;    // prong height
gp_gap      = 2.5;  // gap between prongs
gp_pin_d    = 5;    // pin hole diameter
gp_total_w  = 3 * gp_prong_w + 2 * gp_gap; // 20mm
```

- [ ] **Step 2: Implement `gopro_mount()`**

```scad
module gopro_mount() {
    difference() {
        // 3 prongs as a union
        union() {
            for (i = [0:2]) {
                translate([i * (gp_prong_w + gp_gap), 0, 0])
                    cube([gp_prong_w, gp_prong_d, gp_prong_h]);
            }
        }
        // pin hole through all prongs along X, centered in depth and at mid-height
        translate([-1, gp_prong_d / 2, gp_prong_h / 2])
            rotate([0, 90, 0])
                cylinder(d = gp_pin_d, h = gp_total_w + 2);
    }
}
```

- [ ] **Step 3: Center mount on body in assembly — update the gopro_mount translate call**

The mount is 20mm wide, body is 75mm wide. Offset to center: `(body_w - gp_total_w) / 2`.

```scad
translate([-body_w/2 + (body_w - gp_total_w)/2, -gp_prong_d/2, cw_h + body_h]) gopro_mount();
```

Full assembly section should now read:

```scad
// Assembly
translate([-body_w/2, -body_d/2, 0]) counterweight();
translate([-body_w/2, -body_d/2, cw_h]) clamp_body();
translate([-body_w/2 + (body_w - gp_total_w)/2, -gp_prong_d/2, cw_h + body_h]) gopro_mount();
```

- [ ] **Step 4: Press F5**

Expected: two body blocks below, three small rectangular prongs on top center with a hole through them. Verify prongs sit flush on top of clamp body (no gap, no overlap beyond 1mm).

- [ ] **Step 5: Press F6 (full render) — no manifold errors in console**

- [ ] **Step 6: Commit**

```bash
git add gopro-holder/gopro-gimbal-adapter.scad
git commit -m "feat: add GoPro 3-prong mount with pin hole"
```

---

### Task 5: Final check and export

**Files:**
- Modify: `gopro-holder/gopro-gimbal-adapter.scad` (comment only if needed)

- [ ] **Step 1: Verify counterweight height makes sense**

In OpenSCAD console add a temporary echo to check computed height:

```scad
echo("counterweight height mm =", cw_h);
echo("estimated weight g =", body_w * body_d * cw_h * pla_density);
```

With defaults (target 100g): expect `cw_h ≈ 89.5`. That's a ~9cm block — reasonable. Remove echos after checking.

- [ ] **Step 2: Export STL**

File → Export → Export as STL → save as `gopro-holder/gopro-gimbal-adapter.stl`

- [ ] **Step 3: Final commit**

```bash
git add gopro-holder/gopro-gimbal-adapter.scad gopro-holder/gopro-gimbal-adapter.stl
git commit -m "feat: gopro gimbal adapter complete — parametric counterweight + GoPro 3-prong mount"
```
