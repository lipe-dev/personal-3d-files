// Monitor stand base plate — Greek stepped plinth
// Profile system: define layers bottom→top, width auto-accumulates via D/CC/CV layers.
//
// Layer types  [type, height, param]
//   "V"   vertical face          — no width change
//   "D"   diagonal taper         — param = angle from horizontal (45=chamfer, ~84=near-step)
//   "CC"  concave quarter-circle — param = curve radius (narrows by 2·r)
//   "CV"  convex quarter-circle  — param = curve radius, may overhang
//   "DT"  dentils                — param = [tooth_w, gap_w, cut_depth]
//   "SW"  wave/swirl groove      — param = [amplitude, n_waves, groove_r, n_grooves, mode]
//   "SP"  spiral shells          — param = [sp_r, turns, groove_r, mode, face_gap, back_gap, orn, orn_r]
//   "RV"  pyramid rivets         — param = [tri_s, pyr_h, mode]  (triangular tetrahedra ▲▽)
//   "DS"  double scroll/S-scroll — param = [sp_r, turns, gr, mode, gap]
//   "GK"  greek key/meander      — param = [unit_s, lw, gr, n_turns, mode, double]

// ── Dimensions ───────────────────────────────────────────────
// 3-step staircase with classical Attic moulding at each step.
// D@70° = near-vertical riser (only 20° from vertical) → clear step silhouette.
// base_w=179 → top=150mm (29mm total flare)
// Total height: 20mm
base_w  = 179;

//  Layer   h     param    width    notes
//  V       3.0   —        179      base plinth (wide table foot)
//  CV      2.0   r=1.0    177      lower torus (convex bead)
//  CC      2.5   r=1.5    174      lower scotia (concave hollow)
//  D       2.0   70°      163      STEP RISER 1 → near-vertical step face
//  V       2.0   —        163      step 2 plinth
//  CV      1.5   r=0.5    162      step 2 torus (small bead)
//  D       2.0   70°      151      STEP RISER 2 → near-vertical step face
//  V       0.5   —        151      fillet
//  CV      1.0   r=0.5    150      top transition bead
//  V       3.5   —        150      flat body top
//                          total: 20mm  top=150mm
profile = [
    ["V",  3.5, 0  ],
    ["CV", 1.5, 1.0],
    ["CC", 1.5, 1.5],
    ["D",  2.0, 70 ],
    ["V",  3.5, 0  ],
    ["CC", 1.5, 0.5],
    ["D",  2.0, 70 ],
    ["V",  0.5, 0  ],
    ["CV", 1.0, 0.5],
    ["V",  3.0, 0  ],
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

total_h = z_at(len(profile));
top_w   = w_at(len(profile));

echo("total_h =", total_h);
echo("top_w =",   top_w);

peg_d     = 8;
peg_hole  = 8;   // depth
peg_r_tri = 15;  // triangle radius

// ── Main ─────────────────────────────────────────────────────
col_offset = top_w/2 - 24.6;  // 50.4mm from center — columns flush at corners
col_mark_d = 35.6;
col_mark_h = 0.3;

col_slab_s     = 49;   // plain solid square under each column (no pattern)
col_groove_w   = 1.5;  // groove width (shared by column and statue grooves)
col_groove_d   = 0.7;  // groove depth
col_groove_ang = 65;   // wall angle from horizontal

band_unit       = 7;    // meander cell size
band_lw         = 1.0;  // line width
band_gr         = 0.5;  // groove radius
band_turns      = 3;    // meander turns per cell
band_w          = 9;    // band width
band_margin     = 14;   // distance from plate edge to band center
band_border_w   = 0.5;  // flanking groove width (top)
band_border_d   = 0.35; // flanking groove depth
band_border_gap = 1.2;  // gap from band edge to groove center

brick_w  = 14;    // brick length
brick_h  = 7;     // brick height (row spacing)
brick_lw = 0.4;   // mortar line width (top)
brick_d  = 0.3;   // mortar line depth

groove_ang = 55;  // trapezoidal groove wall angle from horizontal


tile_sp   = 6.0;   // tile line spacing
tile_lw   = 0.35;  // tile line width (top)
tile_d    = 0.3;   // tile line depth

// trapezoidal groove primitives — wider at top, narrower at bottom
module groove_x(x, y, len, w, d) {
    taper = d / tan(groove_ang);
    wb = max(0.01, w - 2*taper);
    hull() {
        translate([x, y - w/2,  total_h - 0.01]) cube([len, w,  0.01]);
        translate([x, y - wb/2, total_h - d])     cube([len, wb, 0.01]);
    }
}
module groove_y(x, y, len, w, d) {
    taper = d / tan(groove_ang);
    wb = max(0.01, w - 2*taper);
    hull() {
        translate([x - w/2,  y, total_h - 0.01]) cube([w,  len, 0.01]);
        translate([x - wb/2, y, total_h - d])     cube([wb, len, 0.01]);
    }
}


difference() {
    profile_stack();
    peg_holes_top();
    column_marks();
    column_slab_grooves();
    pedestal_groove();
    top_face_bands();
    brick_floor();
    margin_tiling();
}

col_line_w = 0.8;


module _flat_gk(cx, cy, mirror, u=band_unit) {  // hooks open along X (for horizontal bands)
    dir = mirror ? -1 : 1;
    s   = u / 2;
    for (k = [0:band_turns-1]) {
        t   = k * band_lw;
        px0 = cx + dir*(-s+t);        px1 = cx + dir*(s-t);
        py0 = cy - s + t;              py1 = cy + s - t;
        pxn = cx + dir*(-s+t+band_lw); pyn = cy - s + t + band_lw;
        hull() { translate([px0,py0,total_h]) sphere(r=band_gr,$fn=6); translate([px1,py0,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([px1,py0,total_h]) sphere(r=band_gr,$fn=6); translate([px1,py1,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([px1,py1,total_h]) sphere(r=band_gr,$fn=6); translate([pxn,py1,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([pxn,py1,total_h]) sphere(r=band_gr,$fn=6); translate([pxn,pyn,total_h]) sphere(r=band_gr,$fn=6); }
    }
}

module _flat_gk_r(cx, cy, mirror) {  // rotated 90° — hooks open along Y (for vertical bands)
    dir = mirror ? -1 : 1;
    s   = band_unit / 2;
    for (k = [0:band_turns-1]) {
        t   = k * band_lw;
        px0 = cx - s + t;              px1 = cx + s - t;
        py0 = cy + dir*(-s+t);        py1 = cy + dir*(s-t);
        pxn = cx - s + t + band_lw;   pyn = cy + dir*(-s+t+band_lw);
        hull() { translate([px0,py0,total_h]) sphere(r=band_gr,$fn=6); translate([px0,py1,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([px0,py1,total_h]) sphere(r=band_gr,$fn=6); translate([px1,py1,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([px1,py1,total_h]) sphere(r=band_gr,$fn=6); translate([px1,pyn,total_h]) sphere(r=band_gr,$fn=6); }
        hull() { translate([px1,pyn,total_h]) sphere(r=band_gr,$fn=6); translate([pxn,pyn,total_h]) sphere(r=band_gr,$fn=6); }
    }
}

module _flat_gk_hband(x0, x1, y_ctr, u=band_unit, flip=false, center=false) {
    span = x1 - x0;
    n  = center ? floor(span / u) : ceil(span / u) + 1;
    ox = center ? x0 + (span - n*u)/2 + u/2 : x0 + u/2;
    intersection() {
        translate([x0, y_ctr-band_w/2, total_h-band_gr-0.1]) cube([span, band_w, band_gr*3]);
        union() for (c=[0:n-1]) _flat_gk(ox+c*u, y_ctr, flip ? c%2==0 : c%2==1, u);
    }
}

module _flat_gk_vband(x_ctr, y0, y1) {
    n = ceil((y1-y0) / band_unit) + 1;
    intersection() {
        translate([x_ctr-band_w/2, y0, total_h-band_gr-0.1]) cube([band_w, y1-y0, band_gr*3]);
        union() for (c=[0:n-1]) _flat_gk_r(x_ctr, y0+band_unit/2+c*band_unit, c%2==1);
    }
}

module _hborders(x0, x1, y_ctr, extend=true) {
    ext = extend ? band_w/2 + band_border_gap + band_border_w : 0;
    off = band_w/2 + band_border_gap;
    for (dy = [-off, off])
        groove_x(x0-ext, y_ctr+dy, x1-x0+2*ext, band_border_w, band_border_d);
}

module _vborders(x_ctr, y0, y1, extend=true) {
    ext = extend ? band_w/2 + band_border_gap + band_border_w : 0;
    off = band_w/2 + band_border_gap;
    for (dx = [-off, off])
        groove_y(x_ctr+dx, y0-ext, y1-y0+2*ext, band_border_w, band_border_d);
}

module top_face_bands() {
    side_x  =  top_w/2 - band_margin;
    back_y  = -(top_w/2 - band_margin);
    front_y =  top_w/2 - band_margin;
    gap     = 2;  // clearance from groove outer edge
    sc      = col_slab_s/2 + col_groove_w + gap;

    cc = band_w/2 + band_border_gap + band_border_w + gap;  // corner clip half-size

    module _clip() {
        difference() {
            translate([-top_w/2, -top_w/2, total_h - band_gr - 1])
                cube([top_w, top_w, (band_gr + 1) * 4]);
            // column slab zones
            for (sx = [-1, 1])
                translate([sx*col_offset - sc, -col_offset - sc, total_h - band_gr - 2])
                    cube([2*sc, 2*sc, (band_gr + 1) * 6]);
            // L corner zones (back + front) — clips vband ends and back hband ends
            for (sx = [-1, 1]) {
                translate([sx*side_x - cc, back_y  - cc, total_h - band_gr - 2])
                    cube([2*cc, 2*cc, (band_gr + 1) * 6]);
                translate([sx*side_x - cc, front_y - cc, total_h - band_gr - 2])
                    cube([2*cc, 2*cc, (band_gr + 1) * 6]);
            }
        }
    }

    // clip without front corner zones — lets front hbands reach side_x
    module _clip_front() {
        difference() {
            translate([-top_w/2, -top_w/2, total_h - band_gr - 1])
                cube([top_w, top_w, (band_gr + 1) * 4]);
            for (sx = [-1, 1])
                translate([sx*col_offset - sc, -col_offset - sc, total_h - band_gr - 2])
                    cube([2*sc, 2*sc, (band_gr + 1) * 6]);
        }
    }

    fi  = 79/2 + 9;     // front border inner bound
    fim = 79/2 + 6;     // front meander inner bound (extends further)
    fo  = top_w/2 - 3;  // front outer bound: near plate edge

    intersection() {
        _clip();
        union() {
            _flat_gk_hband(-side_x, side_x, back_y, center=true);
            _flat_gk_vband(side_x, back_y, front_y - cc);
            mirror([1,0,0]) _flat_gk_vband(side_x, back_y, front_y - cc);
        }
    }

    intersection() {
        _clip_front();
        union() {
            _flat_gk_hband(fim, fo, front_y);
            mirror([1,0,0]) _flat_gk_hband(fim, fo, front_y);
        }
    }

    // border grooves — unclipped so they extend to touch neighbors
    boff   = band_w/2 + band_border_gap;
    slab_x = col_offset - col_slab_s/2 - col_groove_w;  // inner slab groove X edge
    _hborders(-slab_x, slab_x, back_y, extend=false);
    for (sx = [-1, 1]) {
        slab_y = -col_offset + col_slab_s/2 + col_groove_w;
        _vborders(sx*side_x, slab_y, front_y - boff, extend=false);
    }
    _hborders(fi, fo, front_y);
    mirror([1,0,0]) _hborders(fi, fo, front_y);
}

module pedestal_groove() {
    cd    = col_groove_d;
    taper = cd / tan(col_groove_ang);
    ps    = 79 + 2*2;  // pedestal footprint + 2mm gap each side
    otop  = ps + 2*col_groove_w;
    obot  = otop - 2*taper;
    itop  = ps;
    ibot  = ps + 2*taper;
    translate([0, ped_cy, total_h - cd])
        difference() {
            hull() {
                translate([-otop/2, -otop/2,  cd  ]) cube([otop, otop, 0.01]);
                translate([-obot/2, -obot/2, -0.01]) cube([obot, obot, 0.01]);
            }
            hull() {
                translate([-itop/2, -itop/2,  cd  ]) cube([itop, itop, 0.01]);
                translate([-ibot/2, -ibot/2, -0.1 ]) cube([ibot, ibot, 0.01]);
            }
        }
}

module brick_floor() {
    hw  = top_w/2;
    gap = 2;
    sc  = col_slab_s/2 + col_groove_w + gap;
    cc  = band_w/2 + band_border_gap + band_border_w + gap;
    side_x  =  hw - band_margin;
    back_y  = -(hw - band_margin);
    front_y =  hw - band_margin;

    boff = band_w/2 + band_border_gap;
    // visible area for centering
    vx0 = -side_x + boff;  vx1 = side_x - boff;
    vy0 = back_y + boff;   vy1 = front_y - boff;
    vw = vx1 - vx0;  vh = vy1 - vy0;

    n_rows = floor(vh / brick_h);
    n_cols = floor(vw / brick_w);
    oy = vy0 + (vh - n_rows * brick_h) / 2;
    ox = vx0 + (vw - n_cols * brick_w) / 2;

    module _mortar() {
        for (r = [-1:n_rows+1])
            groove_x(vx0, oy + r*brick_h, vw, brick_lw, brick_d);
        for (r = [-1:n_rows])
            for (c = [-1:n_cols+1]) {
                off = (((r % 2) + 2) % 2 == 1) ? brick_w/2 : 0;
                groove_y(ox + c*brick_w + off, oy + r*brick_h, brick_h, brick_lw, brick_d);
            }
    }

    intersection() {
        difference() {
            translate([vx0, vy0, total_h - brick_d - 0.1])
                cube([vw, vh, brick_d + 0.3]);
            // exclude column slab zones
            slab_clip = col_slab_s/2 + col_groove_w;
            for (sx = [-1, 1])
                translate([sx*col_offset - slab_clip, -col_offset - slab_clip, total_h - brick_d - 1])
                    cube([2*slab_clip, 2*slab_clip, brick_d + 3]);
            // exclude pedestal zone
            ped_clip = 79/2 + 2;
            translate([-ped_clip, ped_cy - ped_clip, total_h - brick_d - 1])
                cube([2*ped_clip, 2*ped_clip, brick_d + 3]);
        }
        _mortar();
    }
}

module margin_tiling() {
    hw      = top_w/2;
    bext    = band_w/2 + band_border_gap;
    side_x  = hw - band_margin;
    back_y  = -(hw - band_margin);
    front_y =  hw - band_margin;
    gap     = 2;
    sc      = col_slab_s/2 + col_groove_w + gap;
    ped_s   = 79/2 + gap;

    module _all_lines() {
        // side margins — superficial surface grooves
        slab_top = -col_offset + col_slab_s/2 + col_groove_w + gap;
        for (sx = [-1, 1]) {
            xmin = min(sx*(side_x + bext), sx*hw);
            xmax = max(sx*(side_x + bext), sx*hw);
            w = xmax - xmin;
            sy0 = slab_top;
            sy1 = front_y - bext;
            span = sy1 - sy0;
            n = floor(span / tile_sp);
            oy = sy0 + (span - n*tile_sp) / 2;
            for (i = [0:n])
                groove_x(xmin, oy + i*tile_sp, w, tile_lw, tile_d);
        }
        // back margin
        bw = abs(back_y - bext - (-hw));
        bx0 = -hw;
        bspan = top_w;
        n_back = floor(bspan / tile_sp);
        obx = bx0 + (bspan - n_back*tile_sp) / 2;
        for (i = [0:n_back])
            groove_y(obx + i*tile_sp, -hw, bw, tile_lw, tile_d);
        // front margin
        fw = abs(hw - (front_y + bext));
        fx0 = -(side_x + bext);
        fx1 = side_x + bext;
        fspan = fx1 - fx0;
        n_front = floor(fspan / tile_sp);
        ofx = fx0 + (fspan - n_front*tile_sp) / 2;
        for (i = [0:n_front])
            groove_y(ofx + i*tile_sp, front_y + bext, fw, tile_lw, tile_d);
    }

    difference() {
        _all_lines();
        // exclude column slab zones
        for (sx = [-1, 1])
            translate([sx*col_offset - sc, -col_offset - sc, total_h - tile_d - 1])
                cube([2*sc, 2*sc, tile_d + 3]);
        // exclude pedestal zone
        translate([-ped_s, ped_cy - ped_s, total_h - tile_d - 1])
            cube([2*ped_s, 2*ped_s, tile_d + 3]);
    }
}

module column_marks() {
    for (sx = [-1, 1])
        translate([sx * col_offset, -col_offset, total_h - col_mark_h])
            difference() {
                cylinder(d=col_mark_d,                    h=col_mark_h + 0.1, $fn=48);
                translate([0,0,-0.1])
                    cylinder(d=col_mark_d - 2*col_line_w, h=col_mark_h + 0.3, $fn=48);
            }
}


module column_slab_grooves() {
    cd    = col_groove_d;
    taper = cd / tan(col_groove_ang);   // horizontal reach of chamfer per side
    otop  = col_slab_s + 2*col_groove_w;
    obot  = otop - 2*taper;             // outer wall slopes inward going down
    itop  = col_slab_s;
    ibot  = col_slab_s + 2*taper;       // inner wall slopes outward going down
    for (sx = [-1, 1])
        translate([sx*col_offset, -col_offset, total_h - cd])
            difference() {
                hull() {
                    translate([-otop/2, -otop/2,  cd  ]) cube([otop, otop, 0.01]);
                    translate([-obot/2, -obot/2, -0.01]) cube([obot, obot, 0.01]);
                }
                hull() {
                    translate([-itop/2, -itop/2,  cd  ]) cube([itop, itop, 0.01]);
                    translate([-ibot/2, -ibot/2, -0.1 ]) cube([ibot, ibot, 0.01]);
                }
            }
}



ped_cy = top_w/2 - 79/2;  // pedestal center Y: front edge flush with base top edge

module peg_holes_top() {
    for (a = [90, 210, 330])
        translate([peg_r_tri*cos(a), ped_cy + peg_r_tri*sin(a), total_h - peg_hole])
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
    dir   = mirror ? -1 : 1;
    start = mirror ? -45 : -135;
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
    lh = r * 2;  lw = r * 0.45;  ld = r * 0.55;
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
        a0 = a_mid + dir*t0*180;
        a1 = a_mid + dir*t1*180;
        hull() {
            translate([cx+r_in*cos(a0), face_w/2, cz+r_in*sin(a0)]) sphere(r=gr,$fn=6);
            translate([cx+r_in*cos(a1), face_w/2, cz+r_in*sin(a1)]) sphere(r=gr,$fn=6);
        }
    }

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
    s      = unit_s / 2;
    n_cols = max(1, floor(w / unit_s));
    n_rows = max(1, floor(h / unit_s));
    ox     = -w/2 + s + (w - n_cols*unit_s) / 2;
    oz     = z + s  + (h - n_rows*unit_s) / 2;

    module _unit(cx, cz, fy, mirror) {
        dir = mirror ? -1 : 1;
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
        if (double) {
            n  = n_turns;
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
            translate([cx+tri_s,       0,     cz        ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s/2,     0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+3*tri_s/2,   0,     cz+h_t    ]) sphere(r=0.01,$fn=4);
            translate([cx+tri_s,       pyr_h, cz+2*h_t/3]) sphere(r=0.01,$fn=4);
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
                cx = -w/2 + c * tri_s;
                cz = z   + r * h_t;
                if ((mode==1 || mode==0) && cx+tri_s <= w/2 && cz+h_t <= z+h)
                    _up_out(cx, cz, w/2);
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
        difference() { translate([-w/2,-w/2,z]) cube([w,w,h]); _recessed(); }
        _raised();
    }
}
