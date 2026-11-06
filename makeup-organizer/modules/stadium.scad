// Stadium (rounded rectangle) 2D shape.
// Centered at origin. r = corner radius.
module stadium(w, d, r) {
    cr = min(r, min(w, d) / 2);
    dx = w/2 - cr;
    dy = d/2 - cr;
    hull() {
        translate([-dx, -dy]) circle(r=cr);
        translate([ dx, -dy]) circle(r=cr);
        translate([-dx,  dy]) circle(r=cr);
        translate([ dx,  dy]) circle(r=cr);
    }
}
