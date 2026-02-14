// Makeup Organizer — Brick Decoration
// Bevelled bricks in running-bond pattern around the tray perimeter.

include <params.scad>
use <shared.scad>

// Single brick: flat cube oriented tangent to the surface
module brick(s, w, d, r, z, bulge_offset) {
    perim = stad_perim(w, d, r);
    bw = brick_len - brick_gap;
    bh = brick_h - brick_gap;

    s_center = s % perim;
    pos = stad_pos(s_center, w, d, r);
    tan = stad_tangent(s_center, w, d, r);
    // Normal = outward from perimeter
    nx = tan[1]; ny = -tan[0];
    // Angle of tangent for rotation
    ang = atan2(tan[1], tan[0]);

    // Brick center pushed outward
    cx = pos[0] + nx * (brick_depth/2 + bulge_offset);
    cy = pos[1] + ny * (brick_depth/2 + bulge_offset);

    translate([cx, cy, z])
        rotate([0, 0, ang])
            hull() {
                // Front face — full size, in XZ plane
                translate([0, brick_depth/2, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            polygon([
                                [-bw/2, -bh/2],
                                [ bw/2, -bh/2],
                                [ bw/2,  bh/2],
                                [-bw/2,  bh/2]
                            ]);
                // Back face — inset by bevel, in XZ plane
                translate([0, -brick_depth/2, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            polygon([
                                [-bw/2 + brick_bevel, -bh/2 + brick_bevel],
                                [ bw/2 - brick_bevel, -bh/2 + brick_bevel],
                                [ bw/2 - brick_bevel,  bh/2 - brick_bevel],
                                [-bw/2 + brick_bevel,  bh/2 - brick_bevel]
                            ]);
            }
}

// Straight bricks
module bricks_straight(w, d, r, h) {
    if (brick_h > 0) {
        perim = stad_perim(w, d, r);
        step = brick_len;
        count = floor(perim / step);
        actual_step = perim / count;
        rows = floor((h - 2*brick_margin) / brick_h);
        for (row = [0:rows]) {
            z = brick_margin + row * brick_h + brick_h/2;
            offset_s = (row % 2) * actual_step / 2;
            for (i = [0:count-1]) {
                s = i * actual_step + offset_s;
                brick(s, w, d, r, z, 0);
            }
        }
    }
}

// Puffed bricks follow the sine bulge
module bricks_puffed(w, d, r, h) {
    if (brick_h > 0) {
        perim = stad_perim(w, d, r);
        step = brick_len;
        count = floor(perim / step);
        actual_step = perim / count;
        rows = floor((h - 2*brick_margin) / brick_h);
        for (row = [0:rows]) {
            z = brick_margin + row * brick_h + brick_h/2;
            bulge = puff_max * sin(z / h * 180);
            offset_s = (row % 2) * actual_step / 2;
            for (i = [0:count-1]) {
                s = i * actual_step + offset_s;
                brick(s, w, d, r, z, bulge);
            }
        }
    }
}
