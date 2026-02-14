// Makeup Organizer — Cup
// Removable insert with configurable height and divider grid.

include <params.scad>
use <shared.scad>

/* --- Cup Configuration --- */
cup_floors    = 3;      // height in F units (1F, 2F, 3F...)
cup_extra_h   = 10;     // extra height above floors (lip that sticks out)
cup_rows      = 8;      // number of rows (along depth)
cup_cols      = 4;      // number of columns (along width)

/* --- Derived --- */
cup_h         = cup_floors * F + cup_extra_h;
inner_w       = cup_w - 2*cup_wall;
inner_d       = cup_d - 2*cup_wall;

module cup_body() {
    // Outer shell
    difference() {
        linear_extrude(cup_h)
            stadium(cup_w, cup_d);
        translate([0, 0, cup_base_t])
            linear_extrude(cup_h)
                stadium(inner_w, inner_d);
    }
    // Dividers clipped to stadium interior
    intersection() {
        translate([0, 0, cup_base_t])
            linear_extrude(cup_h - cup_base_t)
                stadium(inner_w, inner_d);
        union() {
            // Column dividers (along width)
            if (cup_cols > 1) {
                for (i = [1:cup_cols-1]) {
                    x = -inner_w/2 + i * inner_w/cup_cols;
                    translate([x, 0, cup_base_t])
                        linear_extrude(cup_h - cup_base_t)
                            square([cup_wall, inner_d], center=true);
                }
            }
            // Row dividers (along depth)
            if (cup_rows > 1) {
                for (i = [1:cup_rows-1]) {
                    y = -inner_d/2 + i * inner_d/cup_rows;
                    translate([0, y, cup_base_t])
                        linear_extrude(cup_h - cup_base_t)
                            square([inner_w, cup_wall], center=true);
                }
            }
        }
    }
}

cup_body();
