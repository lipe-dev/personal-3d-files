// GoPro Gimbal Adapter
// Bottom: counterweight | Lower clamp body | Upper clamp body | Top: GoPro 3-prong mount

$fn = 64;

/* ===================== CONFIGURE HERE ===================== */
body_d          = 12;      // depth (thickness gimbal grips, shared)
body_bot_w      = 75;      // lower section width (mm)
body_bot_h      = 55;      // lower section height (mm)
body_top_w      = 40;      // upper section width (mm)
body_top_h      = 60;      // upper section height (mm)
target_weight_g = 100;     // counterweight target mass (g)
pla_density     = 0.00124; // g/mm³ at 100% infill
/* ========================================================== */

// --- Derived ---
cw_h = target_weight_g / (body_bot_w * body_d * pla_density);

// --- GoPro mount (fixed standard dims) ---
gp_prong_w  = 3;    // prong thickness (stacking direction)
gp_prong_d  = 9;    // prong depth (width of each tab)
gp_prong_h  = 13;   // prong height
gp_gap      = 2.5;  // gap between prongs
gp_pin_d    = 5;    // pin hole diameter
gp_pin_z    = 6.5;  // pin hole center height from prong base
gp_total_w  = 3 * gp_prong_w + 2 * gp_gap; // 14mm

module counterweight() {
    color("Gray")
        cube([body_bot_w, body_d, cw_h]);
}

module clamp_bottom() {
    color("SteelBlue")
        cube([body_bot_w, body_d, body_bot_h]);
}

module clamp_top() {
    color("Coral")
        cube([body_top_w, body_d, body_top_h]);
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

// Assembly
translate([-body_bot_w/2, -body_d/2, 0])                          counterweight();
translate([-body_bot_w/2, -body_d/2, cw_h])                       clamp_bottom();
translate([-body_top_w/2, -body_d/2, cw_h + body_bot_h])          clamp_top();
translate([-gp_total_w/2,  -body_d/2, cw_h + body_bot_h + body_top_h]) gopro_mount();
