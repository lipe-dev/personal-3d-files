// Makeup Organizer — Weave Decoration
// Alternating horizontal/vertical bricks mimicking a woven pattern.

include <params.scad>
use <shared.scad>

// Single weave brick — D-shaped: flat back on tray, rounded belly outward
// In geometry space (before surface rotations):
//   X = tangent, Y = up, Z = inward (-Z = outward)
module weave_brick(pos, tangent, z, bulge_offset, vertical) {
    nx = tangent[1]; ny = -tangent[0];  // outward normal
    ang = atan2(tangent[1], tangent[0]);
    cx = pos[0] + nx * bulge_offset;
    cy = pos[1] + ny * bulge_offset;
    o = 0.5;
    len = (vertical ? weave_brick_w : weave_brick_h) + o;
    curve_r = (vertical ? weave_brick_h : weave_brick_w) / 2;
    translate([cx, cy, z])
        rotate([0, 0, ang])
            rotate([90, 0, 0])
                rotate([0, 0, vertical ? 90 : 0])
                    // Shallow D: full-width curve squashed to weave_depth
                    scale([1, 1, weave_depth / curve_r])
                        intersection() {
                            rotate([0, 90, 0])
                                cylinder(r=curve_r, h=len, center=true, $fn=16);
                            translate([0, 0, curve_r/2])
                                cube([len, 2*curve_r, curve_r], center=true);
                        }
}

// Straight weave
module weave_straight(w, d, r, h) {
    if (weave_depth > 0) {
        perim = stad_perim(w, d, r);
        p_count = floor(perim / weave_brick_w);
        p_step = perim / p_count;
        rows = floor((h - 2*weave_margin) / weave_brick_h);
        grid_h = rows * weave_brick_h;
        z_offset = (h - grid_h) / 2;
        for (row = [0:rows]) {
            z = z_offset + row * weave_brick_h;
            offset_s = 0;
            for (i = [0:p_count-1]) {
                s = (i * p_step + offset_s) % perim;
                pos = stad_pos(s, w, d, r);
                tan = stad_tangent(s, w, d, r);
                vertical = (i + row) % 2 == 0;
                weave_brick(pos, tan, z, 0, vertical);
            }
        }
    }
}

// Puffed weave — bricks follow sine bulge
module weave_puffed(w, d, r, h) {
    if (weave_depth > 0) {
        perim = stad_perim(w, d, r);
        p_count = floor(perim / weave_brick_w);
        p_step = perim / p_count;
        rows = floor((h - 2*weave_margin) / weave_brick_h);
        grid_h = rows * weave_brick_h;
        z_offset = (h - grid_h) / 2;
        for (row = [0:rows]) {
            z = z_offset + row * weave_brick_h;
            bulge = puff_max * sin(z / h * 180);
            offset_s = 0;
            for (i = [0:p_count-1]) {
                s = (i * p_step + offset_s) % perim;
                pos = stad_pos(s, w, d, r);
                tan = stad_tangent(s, w, d, r);
                vertical = (i + row) % 2 == 0;
                weave_brick(pos, tan, z, bulge, vertical);
            }
        }
    }
}
