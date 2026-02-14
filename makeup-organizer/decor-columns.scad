// Makeup Organizer — Column Decoration
// Half-round columns evenly spaced around the tray perimeter.

include <params.scad>
use <shared.scad>

// Straight column with rounded caps
module col_pill(cr, h) {
    hull() {
        translate([0, 0, col_margin])       sphere(r=cr, $fn=16);
        translate([0, 0, h - col_margin])   sphere(r=cr, $fn=16);
    }
}

// Puffed column following sine curve
module col_puff(cr, h, px, py) {
    steps = 8;
    ch = h - 2*col_margin;
    // Normal direction: normalize position relative to tray center
    len_p = sqrt(px*px + py*py);
    nx = len_p > 0 ? px/len_p : 0;
    ny = len_p > 0 ? py/len_p : 0;
    for (j = [0:steps-1]) {
        z0 = col_margin + j * ch / steps;
        z1 = col_margin + (j+1) * ch / steps;
        b0 = puff_max * sin(z0 / h * 180);
        b1 = puff_max * sin(z1 / h * 180);
        hull() {
            translate([px + nx*b0, py + ny*b0, z0]) sphere(r=cr, $fn=16);
            translate([px + nx*b1, py + ny*b1, z1]) sphere(r=cr, $fn=16);
        }
    }
}

module columns(w, d, r, h, style="straight") {
    if (col_r > 0) {
        perim = stad_perim(w, d, r);
        count = floor(perim / col_spacing);
        step = perim / count;
        for (i = [0:count-1]) {
            s = i * step;
            pos = stad_pos(s, w, d, r);
            if (style == "puffed") {
                col_puff(col_r, h, pos[0], pos[1]);
            } else {
                translate(pos) col_pill(col_r, h);
            }
        }
    }
}
