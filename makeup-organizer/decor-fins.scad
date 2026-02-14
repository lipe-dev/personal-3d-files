// Makeup Organizer — Fin Decoration
// Trapezoidal fins evenly spaced around the tray perimeter.
// Side view (looking along tangent):
//      /--\     fin_w_inner (narrow tip)
//     /    \
//    /      \
//   /--------\  fin_w_outer (wide base at wall)
//   |  wall  |

include <params.scad>
use <shared.scad>

// 2D fin cross-section (viewed along tangent direction)
// X = outward from wall, Y = vertical
module fin_profile() {
    hull() {
        // Inner edge at wall (X=0): wide, top corner
        if (fin_r_inner_top > 0)
            translate([fin_r_inner_top, fin_w_outer/2 - fin_r_inner_top])
                circle(r=fin_r_inner_top, $fn=16);
        else
            translate([0, fin_w_outer/2]) square([0.01, 0.01]);
        // Inner edge at wall (X=0): wide, bottom corner
        if (fin_r_inner_bot > 0)
            translate([fin_r_inner_bot, -fin_w_outer/2 + fin_r_inner_bot])
                circle(r=fin_r_inner_bot, $fn=16);
        else
            translate([0, -fin_w_outer/2]) square([0.01, 0.01]);
        // Outer edge at tip (X=fin_reach): narrow, top corner
        if (fin_r_outer_top > 0)
            translate([fin_reach - fin_r_outer_top, fin_w_inner/2 - fin_r_outer_top])
                circle(r=fin_r_outer_top, $fn=16);
        else
            translate([fin_reach, fin_w_inner/2]) square([0.01, 0.01]);
        // Outer edge at tip (X=fin_reach): narrow, bottom corner
        if (fin_r_outer_bot > 0)
            translate([fin_reach - fin_r_outer_bot, -fin_w_inner/2 + fin_r_outer_bot])
                circle(r=fin_r_outer_bot, $fn=16);
        else
            translate([fin_reach, -fin_w_inner/2]) square([0.01, 0.01]);
    }
}

// Single fin on the tray surface
module fin(pos, tangent, h, bulge_offset) {
    nx = tangent[1]; ny = -tangent[0];
    ang = atan2(tangent[1], tangent[0]);
    cx = pos[0] + nx * bulge_offset;
    cy = pos[1] + ny * bulge_offset;
    translate([cx, cy, h/2])
        rotate([0, 0, ang])
            rotate([90, 0, 0])
                // geo X = tangent, geo Y = up (Z world), geo Z = inward
                // Fin profile in XY, extrude along Z
                // Mirror Z so extrusion goes outward
                mirror([0, 0, 1])
                    // Rotate profile: X=outward→-Z(outward after mirror), Y=vertical→Y(up)
                    rotate([0, 90, 0])
                        linear_extrude(fin_t, center=true)
                            fin_profile();
}

// Straight fins
module fins_straight(w, d, r, h) {
    if (fin_reach > 0) {
        perim = stad_perim(w, d, r);
        count = floor(perim / fin_spacing);
        step = perim / count;
        for (i = [0:count-1]) {
            s = i * step;
            pos = stad_pos(s, w, d, r);
            tan = stad_tangent(s, w, d, r);
            fin(pos, tan, h, 0);
        }
    }
}

// Puffed fins — pushed out by max bulge
module fins_puffed(w, d, r, h) {
    if (fin_reach > 0) {
        perim = stad_perim(w, d, r);
        count = floor(perim / fin_spacing);
        step = perim / count;
        for (i = [0:count-1]) {
            s = i * step;
            pos = stad_pos(s, w, d, r);
            tan = stad_tangent(s, w, d, r);
            fin(pos, tan, h, puff_max);
        }
    }
}
