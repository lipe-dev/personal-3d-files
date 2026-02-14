// Makeup Organizer — Side-by-side Preview
// Shows all 3 tray styles with gridfinity grid visualization.

include <params.scad>
use <tray-straight.scad>
use <tray-rounded.scad>
use <tray-puffed.scad>

// --- Render: 3 trays side by side ---
spread = tray_d + 2*puff_max + 20;

color("SteelBlue") translate([0, -spread, 0]) tray_straight();
color("CadetBlue") tray_rounded();
color("Teal")      translate([0, spread, 0])  tray_puffed();

// // Cups in each tray
// for (offset = [-spread, 0, spread])
//     for (i = [0:cups_wide-1])
//         color("Coral")
//             translate([cup_cx(i), offset, tray_base_t])
//                 cup(1);

// --- Gridfinity baseplate visualization ---
gf_x = tray_grid_w;
gf_y = cup_grid_d;
plate_w = gf_x * grid_pitch;
plate_d = gf_y * grid_pitch;
plate_t = 1;

for (offset = [-spread, 0, spread]) {
    color("gray", 0.3)
        translate([0, offset, -plate_t - 0.5])
            linear_extrude(plate_t)
                square([plate_w, plate_d], center=true);

    color("white", 0.5)
        translate([0, offset, -0.4])
            for (i = [0:gf_x])
                translate([i * grid_pitch - plate_w/2, 0, 0])
                    cube([0.5, plate_d, 0.5], center=true);

    color("white", 0.5)
        translate([0, offset, -0.4])
            for (j = [0:gf_y])
                translate([0, j * grid_pitch - plate_d/2, 0])
                    cube([plate_w, 0.5, 0.5], center=true);
}
