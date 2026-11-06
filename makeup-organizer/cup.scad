// Makeup Organizer — Cup
// Removable insert with configurable height and divider grid.
// Self-contained: no external dependencies.

$fn = 64;
use <modules/stadium.scad>

/* ===================== CONFIGURE HERE ===================== */
cup_floors  = 3;        // height in F units (1F = 49mm)
cup_rows    = 3;        // divider rows (along depth)
cup_cols    = 2;        // divider columns (along width)
/* ========================================================== */

/* --- Gridfinity base --- */
grid_pitch  = 42;
grid_clear  = 0.5;
F           = 49;       // height unit = 7 × 7mm gridfinity heights

function grid_size(n) = n * grid_pitch - grid_clear;

/* --- Cup footprint (2×4 gridfinity units) --- */
cup_grid_w   = 2;
cup_grid_d   = 4;
decor_budget = 5;
wall_t       = 1.2;
cup_wall     = 2.5;
cup_base_t   = 1.5;
cup_extra_h  = 10;      // lip that sticks out above tray

cup_w   = grid_size(cup_grid_w) - 2*decor_budget - 2*wall_t;  // 71.1mm
cup_d   = grid_size(cup_grid_d) - 2*decor_budget - 2*wall_t;  // 155.1mm
end_r   = cup_w / 2;

/* --- Derived --- */
cup_h   = cup_floors * F + cup_extra_h;
inner_w = cup_w - 2*cup_wall;
inner_d = cup_d - 2*cup_wall;

/* --- Cup body --- */
module cup_body() {
    difference() {
        linear_extrude(cup_h)
            stadium(cup_w, cup_d);
        translate([0, 0, cup_base_t])
            linear_extrude(cup_h)
                stadium(inner_w, inner_d);
    }
    intersection() {
        translate([0, 0, cup_base_t])
            linear_extrude(cup_h - cup_base_t)
                stadium(inner_w, inner_d);
        union() {
            if (cup_cols > 1)
                for (i = [1:cup_cols-1]) {
                    x = -inner_w/2 + i * inner_w/cup_cols;
                    translate([x, 0, cup_base_t])
                        linear_extrude(cup_h - cup_base_t)
                            square([cup_wall, inner_d], center=true);
                }
            if (cup_rows > 1)
                for (i = [1:cup_rows-1]) {
                    y = -inner_d/2 + i * inner_d/cup_rows;
                    translate([0, y, cup_base_t])
                        linear_extrude(cup_h - cup_base_t)
                            square([inner_w, cup_wall], center=true);
                }
        }
    }
}

cup_body();
