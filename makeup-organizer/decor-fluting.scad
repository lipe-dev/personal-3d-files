// Makeup Organizer — Fluting Decoration
// Vertical grooves carved into a thin outer band.

include <params.scad>
use <shared.scad>

// Straight fluting: band + vertical grooves
module fluting_straight(w, d, r, h) {
    if (flute_depth > 0) {
        perim = stad_perim(w, d, r);
        count = floor(perim / flute_spacing);
        step = perim / count;
        difference() {
            difference() {
                linear_extrude(h)
                    stadium(w + 2*flute_depth, d + 2*flute_depth, r + flute_depth);
                translate([0, 0, -1])
                    linear_extrude(h + 2)
                        stadium(w, d, r);
            }
            for (i = [0:count-1]) {
                s = i * step;
                pos = stad_pos(s, w, d, r);
                tan = stad_tangent(s, w, d, r);
                nx = tan[1]; ny = -tan[0];
                translate([pos[0] + nx*flute_depth, pos[1] + ny*flute_depth, flute_margin])
                    cylinder(r=flute_r, h=h - 2*flute_margin, $fn=12);
            }
        }
    }
}

// Puffed fluting: puffed band + straight vertical grooves
// Grooves are straight cylinders at max bulge offset — simple and fast.
module fluting_puffed(w, d, r, h) {
    if (flute_depth > 0) {
        perim = stad_perim(w, d, r);
        count = floor(perim / flute_spacing);
        step = perim / count;
        slice_h = h / puff_slices;
        difference() {
            // Puffed outer band
            difference() {
                for (i = [0:puff_slices-1]) {
                    z = i * slice_h;
                    bulge = puff_max * sin(i / puff_slices * 180);
                    translate([0, 0, z])
                        linear_extrude(slice_h + 0.01)
                            stadium(w + 2*bulge + 2*flute_depth, d + 2*bulge + 2*flute_depth, r + bulge + flute_depth);
                }
                for (i = [0:puff_slices-1]) {
                    z = i * slice_h;
                    bulge = puff_max * sin(i / puff_slices * 180);
                    translate([0, 0, z])
                        linear_extrude(slice_h + 0.02)
                            stadium(w + 2*bulge, d + 2*bulge, r + bulge);
                }
            }
            // Straight grooves pushed out to max bulge
            for (i = [0:count-1]) {
                s = i * step;
                pos = stad_pos(s, w, d, r);
                tan = stad_tangent(s, w, d, r);
                nx = tan[1]; ny = -tan[0];
                translate([pos[0] + nx*(flute_depth + puff_max), pos[1] + ny*(flute_depth + puff_max), flute_margin])
                    cylinder(r=flute_r, h=h - 2*flute_margin, $fn=12);
            }
        }
    }
}
