// Base plate — Atlas monitor stand
// Parametric profile stack: define layers bottom→top, width auto-accumulates
//
// Layer types  [type, height, param]
//   "V"   vertical face          — no width change
//   "D"   diagonal taper         — param = angle from horizontal (45=classic chamfer)
//   "CC"  concave quarter-circle — param = curve radius (narrows by 2*r)
//   "CV"  convex quarter-circle  — param = curve radius, MAY overhang, check in slicer
//   "DT"  dentils                — param = [tooth_w, gap_w, cut_depth]
//   "SW"  wave/swirl groove      — param = [amplitude, n_waves, groove_r, n_grooves, mode]
//                                   n_grooves=1 → single wave, =2 → interleaved swirl
//   "SP"  spiral shells          — param = [spiral_r, turns, groove_r, mode, face_gap, back_gap, orn, orn_r]
//                                   alternating <> mirror grid; face_gap=gap where openings face,
//                                   back_gap=gap where tails face (><)
//                                   orn: 0=none, 1=leaf, 2=flower  orn_r: ornament radius (0=auto)
//   "RV"  pyramid rivets         — param = [tri_s, pyr_h, mode]
//                                   triangular (tetrahedron) pyramids in ▲▽ tiling
//                                   mode 0=▲ raised / ▽ recessed (AVAV), 1=all raised, 2=all recessed
//   "DS"  double scroll / S-scroll — param = [sp_r, turns, gr, mode, gap]
//                                   spiral in → 180° U-turn at r_in → spiral back out
//                                   alternating mirror tiles as S and reverse-S
//   "GK"  greek key / meander    — param = [unit_s, lw, gr, n_turns, mode, double]
//                                   rectangular spirals, alternating mirror → connected [][][] pattern
//                                   unit_s: cell size, lw: lane spacing (center-to-center),
//                                   gr: groove radius, n_turns: spiral depth, mode 0/1 sub/add
//                                   double=1: U-turn at center, path spirals back out (double scroll)
//                                   constraint: unit_s > (2·n_turns − 1)·lw
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

    // ── DS: double scroll / S-scroll ───────────────────────────
    ["DS", 22, [8, 1.5, 1.8, 0, 2]],  // subtractive S-scroll
    ["V",  2,  0],
    ["DS", 22, [8, 1.5, 1.8, 1, 2]],  // additive S-scroll
    ["V",  2,  0],

    // ── GK: greek key — single inward, then double-scroll variants ─
    ["GK", 22, [20, 5, 2, 2, 0, 0]],  // 2-turn inward only (classic meander)
    ["V",  2,  0],
    ["GK", 22, [20, 5, 2, 2, 0, 1]],  // 2-turn double-scroll (in→U-turn→out)
    ["V",  2,  0],
    ["GK", 32, [30, 5, 2, 3, 1, 1]],  // 3-turn double-scroll additive
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

    // ── SP: spiral shells — subtractive + leaf, additive + flower
    ["V",  2,  0],
    ["SP", 20, [7, 1.5, 1.5, 0, 1.5, 5, 1, 0]], // subtractive shells + leaf between back pairs
    ["V",  2,  0],
    ["SP", 18, [6, 2.0, 1.5, 1, 2,   7, 2, 0]], // additive shells + flower between back pairs

    // ── RV: triangular pyramid rivets — one entry per mode ────
    ["V",  2,  0],
    ["RV", 14, [10, 4, 0]],       // mode 0: ▲ raised / ▽ recessed (AVAV)
    ["V",  2,  0],
    ["RV", 12, [ 8, 5, 1]],       // mode 1: all raised — stud/rivet field
    ["V",  2,  0],
    ["RV", 12, [ 8, 4, 2]],       // mode 2: all recessed — dimple field

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
        else if (t == "SP") layer_sp (w, h, z, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
        else if (t == "RV") layer_rv (w, h, z, p[0], p[1], p[2]);
        else if (t == "DS") layer_ds (w, h, z, p[0], p[1], p[2], p[3], p[4]);
        else if (t == "GK") layer_gk (w, h, z, p[0], p[1], p[2], p[3], p[4], p[5]==1);
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

module layer_ds(w, h, z, sp_r, turns, gr, mode=0, gap=2) {
    // S-scroll: each cell spirals in → 180° arc at r_in → spirals back out.
    // Alternating mirror gives S and reverse-S side by side.
    stride = sp_r * 2 + gap;
    rows   = max(1, floor((h - sp_r) / stride));
    cols   = max(1, floor((w - sp_r) / stride));

    module _all() {
        for (face=[0:3]) rotate([0,0,face*90])
            for (row=[0:rows-1]) for (col=[0:cols-1]) {
                cx = -w/2 + sp_r + col * stride;
                cz = z   + sp_r + row * stride;
                if (cx < w/2 - sp_r && cz < z + h - gr)
                    _double_spiral(cx, cz, w, sp_r, turns, gr,
                                   mirror = (col + row) % 2 == 1);
            }
    }

    if (mode==0) difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _all(); }
    else         union()      { translate([-w/2,-w/2,z]) cube([w,w,h]); _all(); }
}

module _double_spiral(cx, cz, face_w, r_out, turns, gr, mirror=false, segs=52) {
    // Phase 1: inward (r_out → r_in, over turns·360°)
    // Phase 2: 180° arc at r_in (the U-turn)
    // Phase 3: outward (r_in → r_out, starting 180° offset — creates the S)
    r_in  = gr * 1.2;
    dir   = mirror ? -1 : 1;
    start = mirror ? -45 : -135;  // entry angle: opens toward bottom

    // Inward
    for (i = [0:segs-1]) {
        t0=i/segs; t1=(i+1)/segs;
        a0 = start + dir*t0*turns*360;
        a1 = start + dir*t1*turns*360;
        rr0 = r_out*(1-t0) + r_in*t0;
        rr1 = r_out*(1-t1) + r_in*t1;
        hull() {
            translate([cx+rr0*cos(a0), face_w/2, cz+rr0*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+rr1*cos(a1), face_w/2, cz+rr1*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }

    // 180° U-turn arc at r_in
    a_mid = start + dir * turns * 360;
    for (i = [0:11]) {
        t0=i/12; t1=(i+1)/12;
        a0 = a_mid + dir*t0*180;
        a1 = a_mid + dir*t1*180;
        hull() {
            translate([cx+r_in*cos(a0), face_w/2, cz+r_in*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+r_in*cos(a1), face_w/2, cz+r_in*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }

    // Outward (r_in → r_out, 180° offset from inward start)
    a_out = a_mid + dir * 180;
    for (i = [0:segs-1]) {
        t0=i/segs; t1=(i+1)/segs;
        a0 = a_out + dir*t0*turns*360;
        a1 = a_out + dir*t1*turns*360;
        rr0 = r_in*(1-t0) + r_out*t0;
        rr1 = r_in*(1-t1) + r_out*t1;
        hull() {
            translate([cx+rr0*cos(a0), face_w/2, cz+rr0*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+rr1*cos(a1), face_w/2, cz+rr1*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }
}

module layer_gk(w, h, z, unit_s, lw, gr, n_turns=2, mode=0, double=false) {
    // Rectangular spiral tiled on all 4 faces. Alternating mirror → connected [][][] pattern.
    // double=true: after n_turns inward, horizontal 180° U-turn, n_turns back outward.
    //   Path returns to entry point — creates the double-scroll / in-and-out volute.
    //   Sizing: unit_s > (2·n_turns − 1)·lw
    s      = unit_s / 2;
    n_cols = max(1, floor(w / unit_s));
    n_rows = max(1, floor(h / unit_s));
    ox     = -w/2 + s + (w - n_cols*unit_s) / 2;
    oz     = z + s  + (h - n_rows*unit_s) / 2;

    module _unit(cx, cz, fy, mirror) {
        dir = mirror ? -1 : 1;

        // ── Inward turns ───────────────────────────────────────
        for (k = [0:n_turns-1]) {
            t   = k * lw;
            px0 = cx + dir*(-s + t);
            px1 = cx + dir*( s - t);
            pz0 = cz - s + t;
            pz1 = cz + s - t;
            pxn = cx + dir*(-s + t + lw);
            pzn = cz - s + t + lw;
            hull() { translate([px0,fy,pz0]) sphere(r=gr,$fn=6); translate([px1,fy,pz0]) sphere(r=gr,$fn=6); }
            hull() { translate([px1,fy,pz0]) sphere(r=gr,$fn=6); translate([px1,fy,pz1]) sphere(r=gr,$fn=6); }
            hull() { translate([px1,fy,pz1]) sphere(r=gr,$fn=6); translate([pxn,fy,pz1]) sphere(r=gr,$fn=6); }
            hull() { translate([pxn,fy,pz1]) sphere(r=gr,$fn=6); translate([pxn,fy,pzn]) sphere(r=gr,$fn=6); }
        }

        // ── 180° U-turn + outward turns (double-scroll mode) ───
        if (double) {
            n  = n_turns;
            // U-turn: single segment across the innermost bottom
            hull() {
                translate([cx+dir*(-s+n*lw), fy, cz-s+n*lw]) sphere(r=gr,$fn=6);
                translate([cx+dir*( s-n*lw), fy, cz-s+n*lw]) sphere(r=gr,$fn=6);
            }
            // Outward turns: kk=0 is innermost, kk=n-1 is outermost
            // After kk=n-1 the path returns to (cx-s, cz-s) = the entry point
            for (kk = [0:n-1]) {
                pfx = cx + dir*(s  - (n-kk)*lw);    // far-side X
                pex = cx + dir*(-s + (n-1-kk)*lw);  // entry-side X
                pzb = cz - s + (n-kk)*lw;           // bottom Z for this step
                pzt = cz + s - (n-1-kk)*lw;         // top Z for this step
                hull() { translate([pfx,fy,pzb]) sphere(r=gr,$fn=6); translate([pfx,fy,pzt]) sphere(r=gr,$fn=6); }
                hull() { translate([pfx,fy,pzt]) sphere(r=gr,$fn=6); translate([pex,fy,pzt]) sphere(r=gr,$fn=6); }
                hull() { translate([pex,fy,pzt]) sphere(r=gr,$fn=6); translate([pex,fy,pzb-lw]) sphere(r=gr,$fn=6); }
            }
        }
    }

    module _all() {
        for (face=[0:3]) rotate([0,0,face*90])
            for (row=[0:n_rows-1]) for (col=[0:n_cols-1]) {
                cx = ox + col * unit_s;
                cz = oz + row * unit_s;
                _unit(cx, cz, w/2, mirror=col%2==1);
            }
    }

    if (mode==0) difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _all(); }
    else         union()      { translate([-w/2,-w/2,z]) cube([w,w,h]); _all(); }
}

module layer_sp(w, h, z, sp_r, turns, groove_r, mode=0, face_gap=2, back_gap=5, orn=0, orn_r=0) {
    // Alternating <face_gap> between facing shells, <back_gap> between back-to-back shells.
    // Horizontal: <> face_gap >< back_gap <> face_gap >< ...
    // Rows use average gap for uniform vertical spacing.
    // orn: 0=none 1=leaf 2=flower — placed at back_gap centers (always additive/raised)
    pair_stride = 4*sp_r + face_gap + back_gap;
    row_stride  = sp_r*2 + (face_gap + back_gap)/2;
    rows        = max(1, floor((h - 2*(sp_r + groove_r)) / row_stride) + 1);
    max_cols    = ceil(w / (sp_r*2 + face_gap)) + 2;
    max_pairs   = ceil(w / pair_stride) + 1;
    _orn        = is_undef(orn) ? 0 : orn;
    _orn_r      = (is_undef(orn_r) || orn_r == 0) ? sp_r * 0.45 : orn_r;

    module _spirals() {
        for (face = [0:3])
            rotate([0, 0, face*90])
                for (row = [0:rows-1])
                    for (col = [0:max_cols-1]) {
                        cx = -w/2 + sp_r
                           + floor(col/2) * pair_stride
                           + (col % 2) * (2*sp_r + face_gap);
                        cz = z + sp_r + groove_r + row * row_stride;
                        if (cx < w/2 - sp_r && cz < z + h - sp_r - groove_r)
                            _spiral(cx, cz, w, sp_r, turns, groove_r,
                                    mirror = (col + row) % 2 == 1);
                    }
    }

    // ornament center: right edge of col(2p+1) + back_gap/2 = -w/2 + 4·sp_r + fg + bg/2 + p·stride
    module _ornaments() {
        for (face = [0:3])
            rotate([0, 0, face*90])
                for (row = [0:rows-1])
                    for (pair = [0:max_pairs-1]) {
                        ox = -w/2 + 4*sp_r + face_gap + back_gap/2 + pair * pair_stride;
                        oz = z + sp_r + groove_r + row * row_stride;
                        if (ox > -w/2 + _orn_r && ox < w/2 - _orn_r && oz < z + h - sp_r - groove_r)
                            if (_orn == 1) _leaf_orn(ox, oz, w/2, _orn_r);
                            else if (_orn == 2) _flower_orn(ox, oz, w/2, _orn_r);
                    }
    }

    module _base_with_spirals() {
        if (mode == 0) difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _spirals(); }
        else           union()      { translate([-w/2,-w/2,z]) cube([w,w,h]); _spirals(); }
    }

    if (_orn > 0) union() { _base_with_spirals(); _ornaments(); }
    else          _base_with_spirals();
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

// Leaf: pointed almond (vesica piscis), vertical on face, bulging outward
module _leaf_orn(cx, cz, fy, r) {
    lh = r * 2;     // leaf height (along Z)
    lw = r * 0.45;  // half-width at belly
    ld = r * 0.55;  // depth sticking out from face
    translate([cx, fy, cz]) hull() {
        translate([0, 0,   lh/2]) sphere(r=lw*0.18, $fn=6);  // top tip
        translate([0, 0,  -lh/2]) sphere(r=lw*0.18, $fn=6);  // bottom tip
        translate([0, ld,  0   ]) sphere(r=lw,      $fn=8);  // belly
    }
}

// Flower: N petals radiating in XZ plane, each a small teardrop, with center dome
module _flower_orn(cx, cz, fy, r, np=6) {
    pl = r * 1.15;   // petal length
    pw = r * 0.38;   // petal max width
    pd = r * 0.45;   // petal depth out from face
    translate([cx, fy, cz]) {
        for (i = [0:np-1])
            rotate([0, i * 360/np, 0])  // spread petals in XZ plane
                hull() {
                    sphere(r=r*0.18, $fn=6);                       // base at center
                    translate([0, pd,       pl*0.55]) sphere(r=pw,      $fn=6);  // belly
                    translate([0, pd*0.35,  pl     ]) sphere(r=pw*0.12, $fn=6);  // tip
                }
        sphere(r=r*0.28, $fn=10);  // center dome
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

module layer_rv(w, h, z, tri_s, pyr_h, mode=0) {
    // Equilateral-triangle tiling on all 4 faces. Triangles are tetrahedra.
    // ▲ at column c, row r: base vertices at (c·s, r·ht), (c·s+s, r·ht), (c·s+s/2, (r+1)·ht)
    // ▽ between ▲ at c and c+1: apex (cx+s, r·ht), top edge from (cx+s/2,(r+1)·ht) to (cx+3s/2,(r+1)·ht)
    // mode 0 = ▲ raised + ▽ recessed  (AVAV)
    // mode 1 = all raised
    // mode 2 = all recessed
    h_t   = tri_s * sin(60);
    n_col = ceil(w / tri_s) + 1;
    n_row = ceil(h / h_t)  + 1;

    // ▲ centroid: X = cx + s/2,  Z = cz + ht/3
    // ▽ centroid: X = cx + s,   Z = cz + 2·ht/3

    // ▲ raised — base on face, apex out at centroid
    module _up_out(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx,         0,     cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,   0,     cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, 0,     cz+h_t  ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, pyr_h, cz+h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
    // ▲ recessed — base on face, apex into solid at centroid
    module _up_in(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx,          0.01,  cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,    0.01,  cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,  0.01,  cz+h_t  ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, -pyr_h, cz+h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
    // ▽ raised — base on face, apex out at centroid
    module _dn_out(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx+tri_s,       0,     cz        ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,     0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+3*tri_s/2,   0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,       pyr_h, cz+2*h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
    // ▽ recessed — base on face, apex into solid at centroid
    module _dn_in(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx+tri_s,       0.01,  cz        ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,     0.01,  cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+3*tri_s/2,   0.01,  cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,      -pyr_h, cz+2*h_t/3]) sphere(r=0.01,$fn=4);
        }
    }

    module _raised() {
        for (face=[0:3]) rotate([0,0,face*90])
            for (r=[0:n_row-1]) for (c=[0:n_col-1]) {
                cx = -w/2 + c * tri_s;
                cz = z   + r * h_t;
                // ▲: bounds = [cx, cx+s] × [cz, cz+ht]
                if ((mode==1 || mode==0) && cx+tri_s <= w/2 && cz+h_t <= z+h)
                    _up_out(cx, cz, w/2);
                // ▽: bounds = [cx+s/2, cx+3s/2] × [cz, cz+ht]
                if (mode==1 && cx+3*tri_s/2 <= w/2 && cx+tri_s/2 >= -w/2 && cz+h_t <= z+h)
                    _dn_out(cx, cz, w/2);
            }
    }

    module _recessed() {
        for (face=[0:3]) rotate([0,0,face*90])
            for (r=[0:n_row-1]) for (c=[0:n_col-1]) {
                cx = -w/2 + c * tri_s;
                cz = z   + r * h_t;
                if (mode==2 && cx+tri_s <= w/2 && cz+h_t <= z+h)
                    _up_in(cx, cz, w/2);
                if ((mode==0 || mode==2) && cx+3*tri_s/2 <= w/2 && cx+tri_s/2 >= -w/2 && cz+h_t <= z+h)
                    _dn_in(cx, cz, w/2);
            }
    }

    union() {
        difference() {
            translate([-w/2,-w/2,z]) cube([w,w,h]);
            _recessed();
        }
        _raised();
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
