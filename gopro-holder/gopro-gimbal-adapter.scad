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

// --- GoPro mount (fixed standard dims) ---
gp_prong_w  = 5;    // each prong width
gp_prong_d  = 15;   // prong depth
gp_prong_h  = 9;    // prong height
gp_gap      = 2.5;  // gap between prongs
gp_pin_d    = 5;    // pin hole diameter
gp_total_w  = 3 * gp_prong_w + 2 * gp_gap; // 20mm

module counterweight() {
    cube([body_w, body_d, cw_h]);
}
module clamp_body() {
    cube([body_w, body_d, body_h]);
}
module gopro_mount() {}

// Assembly
translate([-body_w/2, -body_d/2, 0]) counterweight();
translate([-body_w/2, -body_d/2, cw_h]) clamp_body();
translate([-body_w/2 + (body_w - gp_total_w)/2, -gp_prong_d/2, cw_h + body_h]) gopro_mount();
