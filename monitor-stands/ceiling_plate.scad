// Monitor stand ceiling plate — decorative cap / monitor shelf
// Profile system identical to base_plate.scad.
// Piece is rendered wide-at-bottom then FLIPPED so 160mm face is physical top (monitor surface).
// Profile reads top→bottom physically = bottom→top in code.
//
// Physical top → bottom:
//   flat monitor surface (160mm)
//   SP  snails + flowers  (160mm — widest decorative band)
//   V   straight
//   DT  dentils
//   GK  connected double-scroll spirals
//   V   straight
//   D   diagonal (narrows)
//   V   straight
//   D   smaller diagonal (narrows to column connection)

// ── Dimensions ───────────────────────────────────────────────
base_w = 161;   // top monitor surface width (widest point)

//  Layer   h     param                       width   notes
//  V       1     —                            160     flat monitor surface
//  SP      8     [3,1.5,0.7, 0,1.5,3, 2,0]   160     snails + flowers (widest band)
//  D       2.5   45°                          155     step down
//  V       1     —                            155     straight
//  DT      6     [4, 3, 1.5]                 155     dentils
//  D       2.5   45°                          150     step down
//  V       1     —                            150     straight
//  GK      10    [10,2.5,1.0, 2, 0, 1]        150     connected double-scroll
//  V       1     —                            150     straight
//  D       2     45°                          146     step down
//  V       1     —                            146     straight
//  D       1.5   30°                          144.3   smaller closing step
//                                             total: ~41.5mm
profile = [
    ["V",  0.5, 0],
    ["SP", 5,   [1.9, 1.5, 0.5, 1, 0.6, 2.5, 2, 1.2]],
    ["D",  1.0, 45],
    ["V",  0.5, 0],
    ["CC", 1.0, 0.7],
    ["DT", 3,   [1.0, 1.2, 0.7]],
    ["D",  1.0, 45],
    ["V",  0.5, 0],
    ["CC", 1.0, 0.7],
    ["GK", 3,   [3.0, 0.6, 0.35, 2, 1, 0]],
    ["V",  0.5, 0],
    ["D",  1.5, 45],
    ["V",  0.5, 0],
    ["D",  1,   30],
];

$fn = 60;

// ── Width/height tracking (recursive) ────────────────────────
function _dw(i) =
    (profile[i][0] == "D")  ? 2 * profile[i][1] * tan(profile[i][2]) :
    (profile[i][0] == "CC") ? 2 * profile[i][2] :
    (profile[i][0] == "CV") ? 2 * profile[i][2] :
    0;

function w_at(i) = (i == 0) ? base_w : w_at(i-1) - _dw(i-1);
function z_at(i) = (i == 0) ? 0      : z_at(i-1) + profile[i-1][1];

total_h  = z_at(len(profile));
bottom_w = w_at(len(profile));

echo("total_h =",  total_h);
echo("bottom_w (column connection) =", bottom_w);

peg_d     = 8;
peg_hole  = 8;
peg_r_tri = 15;
ped_cy    = bottom_w/2 - 79/2;

// ── Main — flip so wide face is on top ───────────────────────
difference() {
    translate([0, 0, total_h]) mirror([0, 0, 1]) profile_stack();
    for (a = [90, 210, 330])
        translate([peg_r_tri*cos(a), ped_cy + peg_r_tri*sin(a), -0.1])
            cylinder(d=peg_d, h=peg_hole + 0.1, $fn=24);
}

module profile_stack() {
    for (i = [0 : len(profile)-1]) {
        t = profile[i][0];
        h = profile[i][1];
        p = profile[i][2];
        w = w_at(i);
        z = z_at(i);

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
    w2 = w - 2 * h * tan(angle);
    hull() {
        translate([-w/2,  -w/2,  z])   cube([w,  w,  0.01]);
        translate([-w2/2, -w2/2, z+h]) cube([w2, w2, 0.01]);
    }
}

module layer_cc(w, h, z, r, n=10) {
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
    period = tw + gw;
    margin = tw;
    difference() {
        translate([-w/2, -w/2, z]) cube([w, w, h]);
        for (face = [0:3]) {
            rotate([0, 0, face * 90]) {
                flat  = w - 2*margin;
                count = round(flat / period);
                start = margin + (flat - count*period) / 2;
                for (i = [0:count-1]) {
                    x = -w/2 + start + i*period + tw;
                    if (x + gw <= w/2 - margin)
                        translate([x, w/2 - depth, z - 0.1])
                            cube([gw, depth + 0.1, h + 0.2]);
                }
            }
        }
    }
}

module layer_sw(w, h, z, amplitude, n_waves, groove_r, n_grooves, mode=0) {
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

module layer_sp(w, h, z, sp_r, turns, groove_r, mode=0, face_gap=2, back_gap=5, orn=0, orn_r=0) {
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
    r_in  = gr * 1.2;
    dir   = mirror ? 1 : -1;
    start = mirror ? 45 : 135;
    for (i = [0:segs-1]) {
        t0 = i/segs;  t1 = (i+1)/segs;
        a0 = start + dir * t0 * turns * 360;
        a1 = start + dir * t1 * turns * 360;
        rr0 = r_out*(1-t0) + r_in*t0;
        rr1 = r_out*(1-t1) + r_in*t1;
        hull() {
            translate([cx + rr0*cos(a0), face_w/2, cz + rr0*sin(a0)]) sphere(r=gr, $fn=6);
            translate([cx + rr1*cos(a1), face_w/2, cz + rr1*sin(a1)]) sphere(r=gr, $fn=6);
        }
    }
}

module _leaf_orn(cx, cz, fy, r) {
    lh = r*2;  lw = r*0.45;  ld = r*0.55;
    translate([cx, fy, cz]) hull() {
        translate([0, 0,   lh/2]) sphere(r=lw*0.18, $fn=6);
        translate([0, 0,  -lh/2]) sphere(r=lw*0.18, $fn=6);
        translate([0, ld,  0   ]) sphere(r=lw,      $fn=8);
    }
}

module _flower_orn(cx, cz, fy, r, np=6) {
    pl = r*1.15;  pw = r*0.38;  pd = r*0.45;
    translate([cx, fy, cz]) {
        for (i = [0:np-1])
            rotate([0, i*360/np, 0])
                hull() {
                    sphere(r=r*0.18, $fn=6);
                    translate([0, pd,      pl*0.55]) sphere(r=pw,      $fn=6);
                    translate([0, pd*0.35, pl     ]) sphere(r=pw*0.12, $fn=6);
                }
        sphere(r=r*0.28, $fn=10);
    }
}

module layer_ds(w, h, z, sp_r, turns, gr, mode=0, gap=2) {
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
    r_in  = gr * 1.2;
    dir   = mirror ? -1 : 1;
    start = mirror ? -45 : -135;

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

    a_mid = start + dir * turns * 360;
    for (i = [0:11]) {
        t0=i/12; t1=(i+1)/12;
        a0 = a_mid + dir*t0*180;  a1 = a_mid + dir*t1*180;
        hull() {
            translate([cx+r_in*cos(a0), face_w/2, cz+r_in*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+r_in*cos(a1), face_w/2, cz+r_in*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }

    a_out = a_mid + dir * 180;
    for (i = [0:segs-1]) {
        t0=i/segs; t1=(i+1)/segs;
        a0 = a_out + dir*t0*turns*360;  a1 = a_out + dir*t1*turns*360;
        rr0 = r_in*(1-t0) + r_out*t0;  rr1 = r_in*(1-t1) + r_out*t1;
        hull() {
            translate([cx+rr0*cos(a0), face_w/2, cz+rr0*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+rr1*cos(a1), face_w/2, cz+rr1*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }
}

module layer_gk(w, h, z, unit_s, lw, gr, n_turns=2, mode=0, double=false) {
    s      = unit_s / 2;
    n_cols = max(1, floor(w / unit_s));
    n_rows = max(1, floor(h / unit_s));
    ox     = -w/2 + s + (w - n_cols*unit_s) / 2;
    oz     = z + s  + (h - n_rows*unit_s) / 2;

    module _unit(cx, cz, fy, mirror) {
        dir = mirror ? -1 : 1;
        for (k = [0:n_turns-1]) {
            t   = k * lw;
            px0 = cx + dir*(-s + t);   px1 = cx + dir*(s - t);
            pz0 = cz - s + t;          pz1 = cz + s - t;
            pxn = cx + dir*(-s+t+lw);  pzn = cz - s + t + lw;
            hull() { translate([px0,fy,pz0]) sphere(r=gr,$fn=6); translate([px1,fy,pz0]) sphere(r=gr,$fn=6); }
            hull() { translate([px1,fy,pz0]) sphere(r=gr,$fn=6); translate([px1,fy,pz1]) sphere(r=gr,$fn=6); }
            hull() { translate([px1,fy,pz1]) sphere(r=gr,$fn=6); translate([pxn,fy,pz1]) sphere(r=gr,$fn=6); }
            hull() { translate([pxn,fy,pz1]) sphere(r=gr,$fn=6); translate([pxn,fy,pzn]) sphere(r=gr,$fn=6); }
        }
        if (double) {
            n = n_turns;
            hull() {
                translate([cx+dir*(-s+n*lw), fy, cz-s+n*lw]) sphere(r=gr,$fn=6);
                translate([cx+dir*( s-n*lw), fy, cz-s+n*lw]) sphere(r=gr,$fn=6);
            }
            for (kk = [0:n-1]) {
                pfx = cx + dir*(s  - (n-kk)*lw);
                pex = cx + dir*(-s + (n-1-kk)*lw);
                pzb = cz - s + (n-kk)*lw;
                pzt = cz + s - (n-1-kk)*lw;
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

module layer_rv(w, h, z, tri_s, pyr_h, mode=0) {
    h_t   = tri_s * sin(60);
    n_col = ceil(w / tri_s) + 1;
    n_row = ceil(h / h_t)  + 1;

    module _up_out(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx,         0,     cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,   0,     cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, 0,     cz+h_t  ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, pyr_h, cz+h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
    module _up_in(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx,          0.01,  cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,    0.01,  cz      ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,  0.01,  cz+h_t  ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2, -pyr_h, cz+h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
    module _dn_out(cx, cz, fy) {
        translate([0, fy, 0]) hull() {
            translate([cx+tri_s,     0,     cz        ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,   0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+3*tri_s/2, 0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,     pyr_h, cz+2*h_t/3]) sphere(r=0.01,$fn=4);
        }
    }
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
                cx = -w/2 + c * tri_s;  cz = z + r * h_t;
                if ((mode==1 || mode==0) && cx+tri_s <= w/2 && cz+h_t <= z+h)
                    _up_out(cx, cz, w/2);
                if (mode==1 && cx+3*tri_s/2 <= w/2 && cx+tri_s/2 >= -w/2 && cz+h_t <= z+h)
                    _dn_out(cx, cz, w/2);
            }
    }

    module _recessed() {
        for (face=[0:3]) rotate([0,0,face*90])
            for (r=[0:n_row-1]) for (c=[0:n_col-1]) {
                cx = -w/2 + c * tri_s;  cz = z + r * h_t;
                if (mode==2 && cx+tri_s <= w/2 && cz+h_t <= z+h)
                    _up_in(cx, cz, w/2);
                if ((mode==0 || mode==2) && cx+3*tri_s/2 <= w/2 && cx+tri_s/2 >= -w/2 && cz+h_t <= z+h)
                    _dn_in(cx, cz, w/2);
            }
    }

    union() {
        difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _recessed(); }
        _raised();
    }
}
