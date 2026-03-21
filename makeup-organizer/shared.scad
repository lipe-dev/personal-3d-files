// Makeup Organizer — Shared Modules & Functions
// Geometry primitives used by all tray styles.

include <params.scad>

/* --- Modules --- */

module stadium(w, d, r=0) {
    cr = r > 0 ? min(r, min(w,d)/2) : min(w,d)/2;
    dx = w/2 - cr;
    dy = d/2 - cr;
    hull() {
        translate([-dx, -dy]) circle(r=cr);
        translate([ dx, -dy]) circle(r=cr);
        translate([-dx,  dy]) circle(r=cr);
        translate([ dx,  dy]) circle(r=cr);
    }
}

module cup(floors=1) {
    h = floors * F;
    difference() {
        linear_extrude(h)
            stadium(cup_w, cup_d);
        translate([0, 0, cup_base_t])
            linear_extrude(h)
                stadium(cup_w - 2*cup_wall, cup_d - 2*cup_wall);
    }
}

// Slot center X position
function cup_cx(i) =
    let(total = cups_wide * cup_w + (cups_wide - 1) * divider_t)
    -total/2 + cup_w/2 + i * (cup_w + divider_t);

// Full cavity — hollows out the entire tray interior
module tray_cavity() {
    translate([0, 0, tray_base_t])
        linear_extrude(tray_h + 10)
            stadium(tray_w - 2*wall_t, tray_d - 2*wall_t, max(1, end_r - wall_t));
}

// Through-hole cuts for floor=0 slots
module floor_holes() {
    for (i = [0:cups_wide-1])
        if (slot_floors[i] == 0)
            translate([cup_cx(i), 0, -1])
                linear_extrude(tray_base_t + 2)
                    stadium(cup_w, cup_d);
}

// Thin sleeves added inside cavity for walls=1 slots
sleeve_t = 1.2;  // sleeve wall thickness
module cup_sleeves() {
    for (i = [0:cups_wide-1])
        if (slot_walls[i] == 1)
            translate([cup_cx(i), 0, slot_floors[i] == 1 ? tray_base_t : 0]) {
                sh = (slot_floors[i] == 1 ? tray_h - tray_base_t : tray_h) - stack_ledge_h;
                difference() {
                    linear_extrude(sh)
                        stadium(cup_w + 2*sleeve_t, cup_d + 2*sleeve_t);
                    translate([0, 0, slot_floors[i] == 1 ? sleeve_t : -1])
                        linear_extrude(sh + 2)
                            stadium(cup_w, cup_d);
                }
            }
}

// Combined tray interior: hollow + sleeves + floor holes
module tray_interior_cut() {
    tray_cavity();
    floor_holes();
}

module tray_interior_add() {
    cup_sleeves();
}

/* --- Stacking: base ledge & top lip --- */

// Base ledge: narrower section at bottom that nests into tray below
module stack_base_ledge(w, d, r) {
    linear_extrude(stack_ledge_h)
        stadium(w - 2*stack_inset, d - 2*stack_inset, max(1, r - stack_inset));
}

// Top lip: channel cut from top rim so the ledge of the tray above can sit in
module stack_top_lip(w, d, r) {
    gap = stack_inset - stack_tol;  // lip is slightly wider than ledge
    translate([0, 0, tray_h])
        linear_extrude(stack_ledge_h + 0.01)
            difference() {
                stadium(w, d, r);
                stadium(w - 2*gap, d - 2*gap, max(1, r - gap));
            }
}

/* --- Wall profile: rounded trapezoid cross-section --- */
// X = outward from body edge, Y = vertical (0 at base, bottom-aligned)
module wall_profile(
    reach   = wall_reach,
    h_inner = wall_h_inner,
    h_outer = wall_h_outer,
    r_ib    = wall_r_inner_bot,
    r_it    = wall_r_inner_top,
    r_ob    = wall_r_outer_bot,
    r_ot    = wall_r_outer_top
) {
    hull() {
        if (r_ib > 0) translate([r_ib, r_ib])               circle(r=r_ib, $fn=16);
        else          translate([0, 0])                       square([0.01, 0.01]);
        if (r_it > 0) translate([r_it, h_inner - r_it])      circle(r=r_it, $fn=16);
        else          translate([0, h_inner])                 square([0.01, 0.01]);
        if (r_ot > 0) translate([reach-r_ot, h_outer - r_ot]) circle(r=r_ot, $fn=16);
        else          translate([reach, h_outer])             square([0.01, 0.01]);
        if (r_ob > 0) translate([reach-r_ob, r_ob])          circle(r=r_ob, $fn=16);
        else          translate([reach, 0])                   square([0.01, 0.01]);
    }
}

/* --- Stadium perimeter functions --- */

// Get XY position on stadium perimeter
function stad_pos(s, w, d, r) =
    let(cr = r > 0 ? min(r, min(w,d)/2) : min(w,d)/2,
        dx = w/2 - cr, dy = d/2 - cr,
        corner = PI/2 * cr,
        straight_r = 2*dy,
        straight_t = 2*dx,
        sr = corner,
        s1 = sr + straight_r,
        s2 = s1 + corner,
        s3 = s2 + straight_t,
        s4 = s3 + corner,
        s5 = s4 + straight_r,
        s6 = s5 + corner,
        s7 = s6 + straight_t)
    // Bottom-right corner arc
    s < sr ? let(a = -PI/2 + s/cr)
        [dx + cr*cos(a*180/PI), -dy + cr*sin(a*180/PI)]
    // Right side (going up)
    : s < s1 ? let(t = s - sr)
        [dx + cr, -dy + t]
    // Top-right corner arc
    : s < s2 ? let(a = (s - s1)/cr)
        [dx + cr*cos(a*180/PI), dy + cr*sin(a*180/PI)]
    // Top side (going left)
    : s < s3 ? let(t = s - s2)
        [dx - t, dy + cr]
    // Top-left corner arc
    : s < s4 ? let(a = PI/2 + (s - s3)/cr)
        [-dx + cr*cos(a*180/PI), dy + cr*sin(a*180/PI)]
    // Left side (going down)
    : s < s5 ? let(t = s - s4)
        [-dx - cr, dy - t]
    // Bottom-left corner arc
    : s < s6 ? let(a = PI + (s - s5)/cr)
        [-dx + cr*cos(a*180/PI), -dy + cr*sin(a*180/PI)]
    // Bottom side (going right)
    : let(t = s - s6)
        [-dx + t, -dy - cr];

function stad_perim(w, d, r) =
    let(cr = r > 0 ? min(r, min(w,d)/2) : min(w,d)/2,
        dx = w/2 - cr, dy = d/2 - cr)
    2*PI*cr + 4*dx + 4*dy;

// Tangent direction at perimeter position s
function stad_tangent(s, w, d, r) =
    let(perim = stad_perim(w, d, r),
        ds = 0.1,
        p0 = stad_pos(s, w, d, r),
        p1 = stad_pos((s + ds) % perim, w, d, r),
        tx = p1[0] - p0[0], ty = p1[1] - p0[1],
        tlen = sqrt(tx*tx + ty*ty))
    tlen > 0 ? [tx/tlen, ty/tlen] : [1, 0];
