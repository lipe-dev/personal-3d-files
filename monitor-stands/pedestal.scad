// Atlas pedestal — Greek plinth
// 89mm base → 77mm top, 14mm tall
// Print two: one normal (peg into base plate), one flipped — pair = 28mm
// Atlas (192mm) + 28mm pedestals + 40mm plates = 260mm total
// Atlas sinks 1mm into top pedestal in slicer

base_w   = 79;
peg_d    = 25;
peg_h    = 12;

//  Layer     h      param    width   notes
//  V         0.5    —        80      base fillet
//  CV        1.5    r=1.0    78      lower torus
//  D         2.0    45°      74      lower chamfer
//  V         6.0    —        74      dado body
//  D         2.0    45°      70      upper chamfer
//  CV        1.5    r=1.0    68      upper torus
//  V         0.5    —        68      top flat
//                             total: 14mm

profile = [
    ["V",  2.0, 0  ],
    ["CC", 2.0, 1.0],
    ["D",  2.5, 45 ],
    ["GK", 6.5, [5, 0.9, 0.4, 3, 1, 0]],
    ["D",  2.5, 45 ],
    ["CV", 2.0, 1.0],
    ["V",  2.5, 0  ],
];

$fn = 60;

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
peg_hole  = 8;
peg_r_tri = 15;

difference() {
    profile_stack();
    for (a = [90, 210, 330])
        translate([peg_r_tri*cos(a), peg_r_tri*sin(a), 0])
            cylinder(d=peg_d, h=peg_hole, $fn=24);
}

module profile_stack() {
    for (i = [0 : len(profile)-1]) {
        t = profile[i][0];
        h = profile[i][1];
        p = profile[i][2];
        w = w_at(i);
        z = z_at(i);

        if      (t == "V")  layer_v (w, h, z);
        else if (t == "D")  layer_d (w, h, z, p);
        else if (t == "CC") layer_cc(w, h, z, p);
        else if (t == "CV") layer_cv(w, h, z, p);
        else if (t == "GK") layer_gk(w, h, z, p[0], p[1], p[2], p[3], p[4], p[5]==1);
    }
}

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
