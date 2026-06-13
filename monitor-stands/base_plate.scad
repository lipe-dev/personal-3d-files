// Base plate — Atlas monitor stand
// Parametric profile stack: define layers bottom→top, width auto-accumulates
//
// Layer types  [type, height, param]
//   "V"   vertical face          — no width change
//   "D"   diagonal taper         — param = angle from horizontal (45=classic chamfer)
//   "CC"  concave quarter-circle — param = curve radius (narrows by 2*r)
//   "CV"  convex quarter-circle  — param = curve radius, MAY overhang, check in slicer
//   "DT"  dentils                — param = [tooth_w, gap_w, cut_depth]
//
// PRINT CONSTRAINT: profile must only narrow going up (no layer wider than one below).
// "D" with angle > 45° from horizontal will overhang — use ≤ 45° for support-free print.

base_w = 270;   // starting width at bottom (square base)

profile = [
    // ── tier 1 (bottom, euthynteria) ──────────────────────────
    ["V",  2, 0],            // base fillet
    ["D",  5, 45],           // 45° chamfer — clean lead-in
    ["V",  2, 0],            // vertical band
    ["DT", 9, [9, 6, 3]],   // dentils: 9mm tooth, 6mm gap, 3mm deep
    ["V",  2, 0],
    ["CC", 5, 5],            // concave curve (narrows 10mm total)

    // ── tier 2 (middle, stereobate) ───────────────────────────
    ["V",  3, 0],
    ["D",  4, 30],           // 30° chamfer — shallower angle, gentler step
    ["V",  2, 0],
    ["DT", 7, [7, 5, 2.5]], // smaller dentils
    ["V",  2, 0],
    ["CC", 4, 4],            // smaller concave curve

    // ── tier 3 (top, stylobate — columns stand here) ──────────
    ["V",  3, 0],
    ["D",  3, 45],           // 45° chamfer
    ["V",  2, 0],
];

// ── Socket config (set after measuring sourced STLs) ─────────
rear_span      = 160;
atlas_y_offset = 66.7;
rear_y_offset  = -33.3;
socket_depth   = 15;
col_socket_d   = 25;
atlas_socket_d = 20;
socket_tol     = 0.3;

$fn = 60;

// ── Width/height tracking (recursive) ────────────────────────
function _dw(i) =
    (profile[i][0] == "D")  ? 2 * profile[i][1] * tan(profile[i][2]) :
    (profile[i][0] == "CC") ? 2 * profile[i][2] :
    (profile[i][0] == "CV") ? 2 * profile[i][2] :
    0;  // V and DT: no width change

function w_at(i) = (i == 0) ? base_w : w_at(i-1) - _dw(i-1);
function z_at(i) = (i == 0) ? 0     : z_at(i-1) + profile[i-1][1];

total_h = z_at(len(profile));
top_w   = w_at(len(profile));

echo("total_h =",  total_h);
echo("top_w =",    top_w);
echo("socket_floor =", total_h - socket_depth);

// ── Main ─────────────────────────────────────────────────────
difference() {
    profile_stack();
    socket_holes();
}

module profile_stack() {
    for (i = [0 : len(profile)-1]) {
        t    = profile[i][0];
        h    = profile[i][1];
        p    = profile[i][2];
        w    = w_at(i);
        z    = z_at(i);

        if      (t == "V")  layer_v  (w, h, z);
        else if (t == "D")  layer_d  (w, h, z, p);
        else if (t == "CC") layer_cc (w, h, z, p);
        else if (t == "CV") layer_cv (w, h, z, p);
        else if (t == "DT") layer_dt (w, h, z, p[0], p[1], p[2]);
    }
}

// ── Layer modules ─────────────────────────────────────────────

module layer_v(w, h, z) {
    translate([-w/2, -w/2, z]) cube([w, w, h]);
}

module layer_d(w, h, z, angle) {
    // Tapers inward: bottom width w, top width w2
    w2 = w - 2 * h * tan(angle);
    hull() {
        translate([-w/2,  -w/2,  z])   cube([w,  w,  0.01]);
        translate([-w2/2, -w2/2, z+h]) cube([w2, w2, 0.01]);
    }
}

module layer_cc(w, h, z, r, n=10) {
    // Concave quarter-circle: starts steep (vertical), accelerates inward
    // x_outer(t) = (w - 2r*sin(t*90)) / 2
    for (i = [0:n-1]) {
        t0 = i/n;  t1 = (i+1)/n;
        w0 = w - 2*r*sin(t0*90);
        w1 = w - 2*r*sin(t1*90);
        hull() {
            translate([-w0/2, -w0/2, z+h*t0]) cube([w0, w0, 0.01]);
            translate([-w1/2, -w1/2, z+h*t1]) cube([w1, w1, 0.01]);
        }
    }
}

module layer_cv(w, h, z, r, n=10) {
    // Convex quarter-circle: starts gentle, ends steep — may need slicer support
    // x_outer(t) = (w - 2r*(1-cos(t*90))) / 2
    for (i = [0:n-1]) {
        t0 = i/n;  t1 = (i+1)/n;
        w0 = w - 2*r*(1 - cos(t0*90));
        w1 = w - 2*r*(1 - cos(t1*90));
        hull() {
            translate([-w0/2, -w0/2, z+h*t0]) cube([w0, w0, 0.01]);
            translate([-w1/2, -w1/2, z+h*t1]) cube([w1, w1, 0.01]);
        }
    }
}

module layer_dt(w, h, z, tw, gw, depth) {
    // Dentils: vertical layer with evenly-spaced rectangular gap cuts on all 4 faces
    // tw=tooth width, gw=gap width, depth=cut depth
    period = tw + gw;
    margin = tw;  // solid tooth at each corner

    difference() {
        translate([-w/2, -w/2, z]) cube([w, w, h]);

        for (face = [0:3]) {
            // Rotate to each of the 4 faces
            rotate([0, 0, face * 90]) {
                flat = w - 2*margin;
                count = floor(flat / period);
                start = margin + (flat - count*period) / 2;
                for (i = [0:count-1]) {
                    x = -w/2 + start + i*period + tw;
                    translate([x, w/2 - depth, z - 0.1])
                        cube([gw, depth + 0.1, h + 0.2]);
                }
            }
        }
    }
}

module socket_holes() {
    translate([-rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);
    translate([ rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);
    translate([0, atlas_y_offset, total_h - socket_depth])
        cylinder(d = atlas_socket_d + socket_tol, h = socket_depth + 1);
}
