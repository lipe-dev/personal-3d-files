// Plunger parts: M12 screw, matching nut, swivel pad
// Modules. Set PREVIEW=true to render side-by-side preview.
// Uses BOSL2.

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 96;

PREVIEW = true;

// --- Screw ---
screw_raw_len = 12;
screw_trim    = 2;
screw_length  = screw_raw_len - screw_trim;  // 12

knob_d = 20;
knob_h = 5;
rib_n  = 16;
rib_d  = 1.8;

// Ballpoint tip
tip_d = 11;

// Thread fitting tolerance: undersize the screw threads so the printed
// screw turns freely inside the printed nut. Bump if still tight.
thread_undersize = 0.4;

// Inner bore for captive shaft
shaft_bore_d = 6;
// Finger button pocket at the top of the knob
finger_d = 12;
finger_h = 3;

module plunger_screw() {
    difference() {
        union() {
            // Threaded shaft, bottom end sliced flat
            translate([0, 0, -screw_trim])
                intersection() {
                    screw("M12", head = "none",
                          length = screw_raw_len, thread = "coarse",
                          undersize = thread_undersize,
                          anchor = BOTTOM);
                    translate([0, 0, screw_trim])
                        cylinder(d = 20, h = screw_length);
                }
            // Knob with grip ribs at top
            translate([0, 0, screw_length - 3]) {
                cylinder(d = knob_d, h = knob_h);
                for (i = [0 : rib_n - 1])
                    rotate([0, 0, i * 360 / rib_n])
                        translate([knob_d / 2, 0, 0])
                            cylinder(d = rib_d, h = knob_h);
            }
        }
        // 6mm bore through the entire screw
        translate([0, 0, -tip_d])
            cylinder(d = shaft_bore_d, h = screw_length + knob_h + 2 * tip_d);
        // Spherical thumb recess — shallow bowl, exposes plunger tip
        knob_top_z  = screw_length - 3 + knob_h;
        bowl_depth  = 3;
        bowl_r      = (pow(finger_d/2, 2) + pow(bowl_depth, 2)) / (2 * bowl_depth);
        translate([0, 0, knob_top_z + (bowl_r - bowl_depth)])
            sphere(r = bowl_r);
    }
}

// --- Captive inner shaft (dumbbell) ---
// Insert from screw bottom. Bot cap (wider than bore) retains at screw tip.
// Top nub (wider than bore, fits in finger pocket) retains at top.
// Press top nub down → bot cap extends and presses button.
shaft_cap_d  = 8.5;  // cap dia — fits through M12 nut (~10mm inner), retained at bore (6mm)
shaft_cap_h  = 2;
shaft_body_d = shaft_bore_d - 0.4; // 5.6 — slides through bore
body_h       = 11;

// Straight step from body to cap (won the A/B test vs a 45° cone, 2026-11-06;
// the cone variant is in git history).
module plunger_inner_shaft() {
    cylinder(d = shaft_body_d, h = body_h);
    translate([0, 0, body_h]) {
        lens_r = (pow(shaft_cap_d/2, 2) + pow(shaft_cap_h, 2)) / (2 * shaft_cap_h);
        intersection() {
            translate([0, 0, -(lens_r - shaft_cap_h)])
                sphere(r = lens_r);
            cylinder(d = shaft_cap_d * 2, h = shaft_cap_h + 0.01);
        }
    }
}

// --- Nut ---
nut_raw_h  = 7;
nut_trim   = 1;
nut_height = nut_raw_h - 2 * nut_trim;       // 5

module plunger_nut() {
    intersection() {
        nut("M12", thread = "coarse", thickness = nut_raw_h);
        translate([0, 0, nut_trim])
            cylinder(d = 30, h = nut_height);
    }
}

// --- Swivel pad ---
pad_d = 16;
pad_h = 0.8;

module swivel_pad() {
    cylinder(d = pad_d, h = pad_h);
}

// --- Preview ---
if (PREVIEW) {
    translate([-30, 0, 0]) plunger_screw();
    translate([-10, 0, 0]) color("DimGray") plunger_inner_shaft();
    // plunger_nut rendered as part of main assembly, not standalone
    translate([ 35, 0, 0]) swivel_pad();
}
