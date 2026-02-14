// Makeup Organizer — Honeycomb Decoration
// Hex-cell pattern subtracted from a thin outer band.

include <params.scad>
use <shared.scad>

// Single hexagon oriented flat-side along perimeter (vertical)
module hex_cell(pos, tangent, z, bulge_offset) {
    nx = tangent[1]; ny = -tangent[0];  // outward normal
    ang = atan2(tangent[1], tangent[0]);
    cx = pos[0] + nx * (hex_depth/2 + bulge_offset);
    cy = pos[1] + ny * (hex_depth/2 + bulge_offset);
    translate([cx, cy, z])
        rotate([0, 0, ang])
            rotate([90, 0, 0])
                rotate([0, 0, 30])
                    cylinder(r=hex_r, h=hex_depth + 2, center=true, $fn=6);
}

// All hex holes for subtraction
module hex_holes(w, d, r, h, puffed=false, margin=0) {
    m = margin > 0 ? margin : hex_margin;
    perim = stad_perim(w, d, r);
    p_count = floor(perim / hex_p_sp);
    p_step = perim / p_count;
    rows = floor((h - 2*m) / hex_h_sp);
    grid_h = rows * hex_h_sp;
    z_offset = (h - grid_h) / 2;  // center vertically
    for (row = [0:rows]) {
        z = z_offset + row * hex_h_sp;
        bulge = puffed ? puff_max * sin(z / h * 180) : 0;
        offset_s = (row % 2) * p_step / 2;
        for (i = [0:p_count-1]) {
            s = (i * p_step + offset_s) % perim;
            pos = stad_pos(s, w, d, r);
            tan = stad_tangent(s, w, d, r);
            hex_cell(pos, tan, z, bulge);
        }
    }
}

// --- Straight honeycomb ---

module honeycomb_straight(w, d, r, h, margin=0) {
    if (hex_r > 0 && hex_depth > 0) {
        difference() {
            difference() {
                linear_extrude(h)
                    stadium(w + 2*hex_depth, d + 2*hex_depth, r + hex_depth);
                translate([0, 0, -1])
                    linear_extrude(h + 2)
                        stadium(w, d, r);
            }
            hex_holes(w, d, r, h, false, margin);
        }
    }
}

// --- Puffed honeycomb ---

module honeycomb_puffed(w, d, r, h, margin=0) {
    if (hex_r > 0 && hex_depth > 0) {
        slice_h = h / puff_slices;
        difference() {
            difference() {
                for (i = [0:puff_slices-1]) {
                    z = i * slice_h;
                    bulge = puff_max * sin(i / puff_slices * 180);
                    translate([0, 0, z])
                        linear_extrude(slice_h + 0.01)
                            stadium(w + 2*bulge + 2*hex_depth, d + 2*bulge + 2*hex_depth, r + bulge + hex_depth);
                }
                for (i = [0:puff_slices-1]) {
                    z = i * slice_h;
                    bulge = puff_max * sin(i / puff_slices * 180);
                    translate([0, 0, z])
                        linear_extrude(slice_h + 0.02)
                            stadium(w + 2*bulge, d + 2*bulge, r + bulge);
                }
            }
            hex_holes(w, d, r, h, true, margin);
        }
    }
}
