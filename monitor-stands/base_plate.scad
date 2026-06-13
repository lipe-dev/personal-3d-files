// Base plate — Atlas monitor stand
// Parametric profile stack: define layers bottom→top, width auto-accumulates
//
// Layer types  [type, height, param]
//   "V"   vertical face          — no width change
//   "D"   diagonal taper         — param = angle from horizontal (45=classic chamfer)
//   "CC"  concave quarter-circle — param = curve radius (narrows by 2*r)
//   "CV"  convex quarter-circle  — param = curve radius, MAY overhang, check in slicer
//   "DT"  dentils                — param = [tooth_w, gap_w, cut_depth]
//   "SW"  wave/swirl groove      — param = [amplitude, n_waves, groove_r, n_grooves]
//                                   n_grooves=1 → single wave, =2 → interleaved swirl
//   "SP"  spiral shells          — param = [spiral_r, turns, groove_r, mode, gap]
//                                   square grid, alternating mirror, gap=space between shells
//
// PRINT CONSTRAINT: profile must only narrow going up (no layer wider than one below).
// "D" with angle > 45° from horizontal will overhang — use ≤ 45° for support-free print.

base_w = 270;   // starting width at bottom (square base)

profile = [
    // ══ DEMO SHOWCASE — all layer types, multiple configs ══════

    // ── D: diagonal tapers ─────────────────────────────────────
    ["V",  2,  0],
    ["D",  5,  45],               // 45° — classic chamfer
    ["V",  2,  0],
    ["D",  5,  30],               // 30° — shallower, more gradual
    ["V",  2,  0],

    // ── DT: dentils — bold then fine ───────────────────────────
    ["DT", 9,  [11, 7, 3.5]],    // bold: wide teeth, deep cuts
    ["V",  2,  0],
    ["DT", 5,  [5,  3, 1.8]],    // fine: tight repeating pattern
    ["V",  2,  0],

    // ── CC + CV: concave then convex curves ────────────────────
    ["CC", 6,  6],                // concave — safe to print
    ["V",  2,  0],
    ["CV", 5,  5],                // convex — check slicer for overhang

    // ── SW: wave/swirl — subtractive then additive ─────────────
    ["V",  2,  0],
    ["SW", 10, [5, 6, 2.5, 2, 0]], // subtractive: 2-strand grooved swirl
    ["V",  2,  0],
    ["SW", 10, [4, 5, 2,   3, 1]], // additive:    3-strand raised braid

    // ── SP: spiral shells — subtractive then additive ──────────
    ["V",  2,  0],
    ["SP", 20, [7, 1.5, 1.5, 0, 3]], // subtractive: sp_r, turns, groove_r, mode, gap
    ["V",  2,  0],
    ["SP", 18, [6, 2.0, 1.5, 1, 3]], // additive: tight 2-turn shells raised out

    // ── close ──────────────────────────────────────────────────
    ["V",  2,  0],
    ["D",  4,  45],               // closing chamfer
    ["V",  2,  0],
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
    0;  // V, DT, SW, SP: no width change

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
        else if (t == "SW") layer_sw (w, h, z, p[0], p[1], p[2], p[3], p[4]);
        else if (t == "SP") layer_sp (w, h, z, p[0], p[1], p[2], p[3], p[4]);
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
            rotate([0, 0, face * 90]) {
                flat  = w - 2*margin;
                count = round(flat / period);   // round → symmetric, no missing end gap
                start = margin + (flat - count*period) / 2;
                for (i = [0:count-1]) {
                    x = -w/2 + start + i*period + tw;
                    if (x + gw <= w/2 - margin)  // clamp: never cut into corner margin
                        translate([x, w/2 - depth, z - 0.1])
                            cube([gw, depth + 0.1, h + 0.2]);
                }
            }
        }
    }
}

module layer_sp(w, h, z, sp_r, turns, groove_r, mode=0, gap=2) {
    // Square grid of Archimedean spiral shells, equal spacing in X and Z.
    // gap = space between spiral edges (like dentil gap). stride = diameter + gap.
    stride = sp_r * 2 + gap;
    rows   = max(1, floor((h - sp_r) / stride));
    cols   = max(1, floor((w - sp_r) / stride));

    module _spirals() {
        for (face = [0:3])
            rotate([0, 0, face*90])
                for (row = [0:rows-1])
                    for (col = [0:cols-1]) {
                        cx = -w/2 + sp_r + col * stride;
                        cz = z   + sp_r + row * stride;
                        if (cx < w/2 - sp_r && cz < z + h - groove_r)
                            _spiral(cx, cz, w, sp_r, turns, groove_r,
                                    mirror = (col + row) % 2 == 1);
                    }
    }

    if (mode == 0) difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _spirals(); }
    else           union()      { translate([-w/2,-w/2,z]) cube([w,w,h]); _spirals(); }
}

module _spiral(cx, cz, face_w, r_out, turns, gr, mirror=false, segs=52) {
    // Single Archimedean spiral. mirror=true reverses winding direction.
    r_in = gr * 1.2;
    dir   = mirror ? -1 : 1;
    start = mirror ? -45 : -135;  // mirrored shell opens the other way
    for (i = [0:segs-1]) {
        t0 = i / segs;  t1 = (i+1) / segs;
        a0 = start + dir * t0 * turns * 360;
        a1 = start + dir * t1 * turns * 360;
        rr0 = r_out * (1-t0) + r_in * t0;
        rr1 = r_out * (1-t1) + r_in * t1;
        hull() {
            translate([cx + rr0*cos(a0), face_w/2, cz + rr0*sin(a0)]) sphere(r=gr, $fn=6);
            translate([cx + rr1*cos(a1), face_w/2, cz + rr1*sin(a1)]) sphere(r=gr, $fn=6);
        }
    }
}

module layer_sw(w, h, z, amplitude, n_waves, groove_r, n_grooves, mode=0) {
    // mode 0 = subtractive (grooves cut in), mode 1 = additive (ridges protrude out)
    module _waves() {
        for (face = [0:3])
            rotate([0, 0, face*90])
                for (g = [0:n_grooves-1])
                    _wave_groove(w, h, z, amplitude, n_waves, groove_r,
                                 phase = g * 360 / n_grooves);
    }

    if (mode == 0) difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _waves(); }
    else           union()      { translate([-w/2,-w/2,z]) cube([w,w,h]); _waves(); }
}

module _wave_groove(w, h, z, amplitude, n_waves, r, phase, segs=80) {
    // Cuts a tube-shaped groove following a sine path along one face (the +Y face).
    for (i = [0:segs-1]) {
        x0 = -w/2 + (i)   * w/segs;
        x1 = -w/2 + (i+1) * w/segs;
        z0 = z + h/2 + amplitude * sin(phase + i     * n_waves * 360/segs);
        z1 = z + h/2 + amplitude * sin(phase + (i+1) * n_waves * 360/segs);
        hull() {
            translate([x0, w/2, z0]) sphere(r=r, $fn=8);
            translate([x1, w/2, z1]) sphere(r=r, $fn=8);
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
