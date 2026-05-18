// GoPro Gimbal Adapter
// Stack (bottom→top): weight block | connector | phone grip | GoPro 3-prong mount

$fn = 64;

// --- GoPro mount (fixed standard dims) ---
gp_prong_w  = 3;    // prong thickness (stacking direction)
gp_prong_d  = 15;   // prong depth — GoPro standard outer diameter
gp_prong_h  = 17;   // prong height — GoPro standard minimum
gp_gap      = 3.5;  // gap between prongs — GoPro standard slit width
gp_pin_d    = 5;    // pin hole diameter (M5)
gp_pin_z    = 8.5;  // pin hole center height from prong base
gp_total_w  = 3 * gp_prong_w + 2 * gp_gap; // 16mm

/* ===================== CONFIGURE HERE ===================== */
grip_w      = 60;         // phone grip width (mm)
grip_h      = 40;         // phone grip height (mm)
connector_h = gp_prong_h; // matches prong height — equal lever arm for balance

// Weight block — GoPro Hero 13 Black body dimensions
weight_w = 71.8;
weight_d = 33.4;
weight_h = 44.9;
/* ========================================================== */

module weight_block() {
    color("Gray")
        cube([weight_w, weight_d, weight_h]);
}

module phone_grip() {
    color("SteelBlue")
        cube([grip_w, gp_prong_d, grip_h]);
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

// Assembly — back face at Y=0 for flat bed placement
z0 = 0;
z1 = z0 + weight_h;
z2 = z1 + connector_h;
z3 = z2 + grip_h;

translate([-weight_w/2,   0, z0]) weight_block();
translate([-gp_total_w/2, 0, z1]) connector();
translate([-grip_w/2,     0, z2]) phone_grip();
translate([-gp_total_w/2, 0, z3]) gopro_mount();
