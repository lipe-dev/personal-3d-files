// Makeup Organizer — Bin
// N cups wide, determined by array length.

/* ===================== CONFIGURE HERE ===================== */
walls  = [true, true, true];   // per-slot: true = individual walled pocket
floors = [false, false, false]; // per-slot: true = solid floor, false = through hole

// Wall profile — trapezoid cross-section extruded around bin perimeter
wall_base_w = 10;  // width at base
wall_top_w  = 4;   // width at top
wall_r_sw   = 0;   // inner-bottom corner radius
wall_r_nw   = 0;   // inner-top corner radius
wall_r_se   = 3;   // outer-bottom corner radius
wall_r_ne   = 2;   // outer-top corner radius
/* ========================================================== */

$fn = 64;
use <modules/stadium.scad>
use <modules/trapezoid.scad>

/* --- Gridfinity base --- */
grid_pitch   = 42;
grid_clear   = 0.5;
F            = 49;

function grid_size(n) = n * grid_pitch - grid_clear;

/* --- Cup footprint (2×4 gridfinity units) --- */
cup_grid_w   = 2;
cup_grid_d   = 4;
decor_budget = 5;
wall_t       = 1.2;

cup_w  = grid_size(cup_grid_w) - 2*decor_budget - 2*wall_t;  // 71.1mm
cup_d  = grid_size(cup_grid_d) - 2*decor_budget - 2*wall_t;  // 155.1mm
end_r  = cup_w / 2;  // stadium corner radius

/* --- Bin dimensions --- */
n          = len(walls);
bin_w      = grid_size(n * cup_grid_w) - 2*decor_budget;
bin_d      = grid_size(cup_grid_d)     - 2*decor_budget;
bin_h      = 1 * F;
base_t     = 2;
divider_t  = n > 1 ? (bin_w - 2*wall_t - n*cup_w) / (n-1) : 0;
dx         = bin_w/2 - end_r;
dy         = bin_d/2 - end_r;

function cup_cx(i) = -bin_w/2 + wall_t + cup_w/2 + i*(cup_w + divider_t);

/* --- Wall profile 2D (centered on bin edge, X=outward, Y=height) --- */
// Wall profile: translate shifts centered trapezoid so inner edge sits at X=0.
module wall_profile_2d() {
    translate([wall_base_w/2, 0])
        trapezoid(base_w=wall_base_w, top_w=wall_top_w, h=bin_h,
                  r_sw=wall_r_sw, r_nw=wall_r_nw, r_se=wall_r_se, r_ne=wall_r_ne);
}

/* --- Wall profile extruded around bin perimeter --- */
module bin_wall_profile() {
    // Right wall (+X)
    translate([bin_w/2, dy, 0])
        rotate([90, 0, 0])
            linear_extrude(2*dy)
                wall_profile_2d();
    // Left wall (-X)
    mirror([1, 0, 0])
        translate([bin_w/2, dy, 0])
            rotate([90, 0, 0])
                linear_extrude(2*dy)
                    wall_profile_2d();
    // Top wall (+Y)
    rotate([0, 0, 90])
        translate([bin_d/2, dx, 0])
            rotate([90, 0, 0])
                linear_extrude(2*dx)
                    wall_profile_2d();
    // Bottom wall (-Y)
    mirror([0, 1, 0])
        rotate([0, 0, 90])
            translate([bin_d/2, dx, 0])
                rotate([90, 0, 0])
                    linear_extrude(2*dx)
                        wall_profile_2d();
    // NE corner (+x+y)
    translate([dx, dy, 0])
        rotate_extrude(angle=90)
            translate([end_r, 0])
                wall_profile_2d();
    // NW corner (-x+y)
    translate([-dx, dy, 0])
        rotate([0, 0, 90])
            rotate_extrude(angle=90)
                translate([end_r, 0])
                    wall_profile_2d();
    // SW corner (-x-y)
    translate([-dx, -dy, 0])
        rotate([0, 0, 180])
            rotate_extrude(angle=90)
                translate([end_r, 0])
                    wall_profile_2d();
    // SE corner (+x-y)
    translate([dx, -dy, 0])
        rotate([0, 0, 270])
            rotate_extrude(angle=90)
                translate([end_r, 0])
                    wall_profile_2d();
}

/* --- Render --- */
// Base with floor holes
difference() {
    linear_extrude(base_t)
        stadium(bin_w, bin_d, end_r);
    for (i = [0:n-1])
        if (!floors[i])
            translate([cup_cx(i), 0, -1])
                linear_extrude(base_t + 2)
                    stadium(cup_w, cup_d, end_r);
}

// Per-slot walls
for (i = [0:n-1])
    if (walls[i])
        translate([cup_cx(i), 0, base_t])
            linear_extrude(bin_h - base_t)
                difference() {
                    stadium(cup_w + 2*wall_t, cup_d + 2*wall_t, end_r + wall_t);
                    stadium(cup_w, cup_d, end_r);
                }

// Wall profile
bin_wall_profile();

// Cups (outline only for fitment check)
cup_viz_h = 3 * F;
color("SteelBlue", 0.5)
    for (i = [0:n-1])
        translate([cup_cx(i), 0, base_t])
            linear_extrude(cup_viz_h)
                stadium(cup_w, cup_d, end_r);
