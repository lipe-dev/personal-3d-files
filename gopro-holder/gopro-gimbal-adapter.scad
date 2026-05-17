// GoPro Gimbal Adapter
// Stack (bottom→top): weight block | phone grip | connector | GoPro 3-prong mount

$fn = 64;

/* ===================== CONFIGURE HERE ===================== */
// Phone grip (what the gimbal spring clamps grab)
grip_w = 60;     // width (mm)
grip_h = 40;     // height (mm)

// Connector (bridges grip to prongs, matches prong footprint)
connector_h = 8; // height (mm)

// Weight block — GoPro Hero 13 Black body dimensions
weight_w = 71.8;
weight_d = 33.4;
weight_h = 44.9;

corner_r = 3;    // rounding radius for grip and weight block (mm)
/* ========================================================== */

// --- GoPro mount (fixed standard dims) ---
gp_prong_w  = 3;    // prong thickness (stacking direction)
gp_prong_d  = 9;    // prong depth (width of each tab)
gp_prong_h  = 13;   // prong height
gp_gap      = 2.5;  // gap between prongs
gp_pin_d    = 5;    // pin hole diameter
gp_pin_z    = 6.5;  // pin hole center height from prong base
gp_total_w  = 3 * gp_prong_w + 2 * gp_gap; // 14mm

module rounded_box(w, d, h, r) {
    translate([r, r, r])
    minkowski() {
        cube([w - 2*r, d - 2*r, h - 2*r]);
        sphere(r, $fn = 24);
    }
}

module weight_block() {
    color("Gray")
        rounded_box(weight_w, weight_d, weight_h, corner_r);
}

module phone_grip() {
    color("SteelBlue")
        rounded_box(grip_w, gp_prong_d, grip_h, corner_r);
}

module connector() {
    color("SlateGray")
        cube([gp_total_w, gp_prong_d, connector_h]);
}

module prong() {
    union() {
        cube([gp_prong_w, gp_prong_d, gp_prong_h - gp_prong_d / 2]);
        translate([gp_prong_w / 2, gp_prong_d / 2, gp_prong_h - gp_prong_d / 2])
            rotate([0, 90, 0])
                cylinder(r = gp_prong_d / 2, h = gp_prong_w, center = true);
    }
}

module gopro_mount() {
    color("Coral")
    difference() {
        union() {
            for (i = [0:2]) {
                translate([i * (gp_prong_w + gp_gap), 0, 0])
                    prong();
            }
        }
        // pin hole through all prongs along X
        translate([-1, gp_prong_d / 2, gp_pin_z])
            rotate([0, 90, 0])
                cylinder(d = gp_pin_d, h = gp_total_w + 2);
    }
}

// Assembly — all centered on X=0, each section centered on its own Y depth
z0 = 0;
z1 = z0 + weight_h;
z2 = z1 + connector_h;
z3 = z2 + grip_h;

translate([-weight_w/2,    -weight_d/2,    z0]) weight_block();
translate([-gp_total_w/2,  -gp_prong_d/2,  z1]) connector();
translate([-grip_w/2,      -gp_prong_d/2,  z2]) phone_grip();
translate([-gp_total_w/2,  -gp_prong_d/2,  z3]) gopro_mount();
