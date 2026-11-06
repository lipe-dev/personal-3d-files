// Rounded trapezoid 2D shape.
// Centered horizontally, base at y=0, top at y=h.
// r_sw/se = bottom corners, r_nw/ne = top corners.
module trapezoid(base_w, top_w, h, r_sw=0, r_se=0, r_nw=0, r_ne=0) {
    hull() {
        if (r_sw > 0) translate([-base_w/2 + r_sw, r_sw])  circle(r=r_sw);
        else          translate([-base_w/2, 0])              square(0.01);

        if (r_se > 0) translate([ base_w/2 - r_se, r_se])  circle(r=r_se);
        else          translate([ base_w/2, 0])              square(0.01);

        if (r_nw > 0) translate([-top_w/2 + r_nw, h - r_nw]) circle(r=r_nw);
        else          translate([-top_w/2, h])                 square(0.01);

        if (r_ne > 0) translate([ top_w/2 - r_ne, h - r_ne]) circle(r=r_ne);
        else          translate([ top_w/2, h])                 square(0.01);
    }
}
