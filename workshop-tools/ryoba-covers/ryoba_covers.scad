// Ryoba saw tooth covers: one cover per toothed edge, same design as the dozuki cover.
// Each is a U-channel that presses onto its toothed edge from the side, capped at both ends.
// Inside: a wider channel at the bottom for the set teeth, a thin slot above it for the
// blade body, and >< pinch nubs that grip the blade.
// The end caps lean to match the blade's end edges (/__/).
// Print on its closed bottom edge, opening up - no supports or bridges.

part = "rip";          // which cover: "rip" or "crosscut" - export each one separately

blade_t     = 0.6;     // blade body thickness (shared by both edges)

// ---- edge shape, the same on both edges (the blade is symmetrical) ----
edge_len    = 250;     // full bottom length, including the end diagonals
end_rise    = 1.5;     // MEASURE: rise of the diagonals at each end (assumed same as the dozuki)
heel_run    = 6;       // diagonal length at the heel (handle) end, part of edge_len
toe_run     = 8;       // diagonal length at the toe (tip) end, part of edge_len
w_heel      = 61;      // blade width at the handle end, edge to edge
w_tip       = 82;      // blade width at the tip, edge to edge
// each edge splays out from the centreline by this angle; the blade's ends are square
// to the centreline, so seen from each edge they lean back toward the heel by the same angle
taper       = atan(((w_tip - w_heel) / 2) / edge_len);
heel_lean   = -taper;  // lean of the heel end edge, degrees from vertical (+ = toward the toe)
toe_lean    = -taper;  // lean of the toe end edge

// ---- teeth, can differ per edge ----
rip_kerf    = 1.0;     // MEASURE: thickness across the set rip teeth
rip_tooth_h = 4;       // MEASURE: rip tooth height
cc_kerf     = 0.9;     // MEASURE: thickness across the set crosscut teeth
cc_tooth_h  = 2.5;     // MEASURE: crosscut tooth height

kerf    = part == "rip" ? rip_kerf    : cc_kerf;
tooth_h = part == "rip" ? rip_tooth_h : cc_tooth_h;

end_clear   = 0.5;     // gap between each blade end and its end cap
cover_h     = 18;      // how far up the blade it reaches
body_gap    = 0.15;    // slot clearance on the blade body (small = more friction)
teeth_gap   = 0.6;     // clearance on the teeth
floor_t     = 2;       // wall under the tooth tips
wall        = 1.6;     // side wall thickness
end_wall    = 2.5;     // end caps at the heel and toe
end_caps    = true;    // false to see the profile from the end - set true before printing
// heel end: the blade rises straight up from the cutting edge, then has a rounded notch
// cut in toward the tip, then curves away into the neck. The heel end wall only fills
// the straight rise; a rounded lobe on top of it fills the notch; above that the side
// walls carry on to the end with no end wall, around the neck.
notch_bottom = 6.2;    // straight rise from the cutting edge to the bottom of the notch
notch_depth  = 4;      // MEASURE: how far the notch cuts in toward the tip, from the rise
notch_h      = 4.3;    // notch height (lobe comes out 0.8 smaller: 3.5)
notch_clear  = 0.4;    // gap around the lobe inside the notch
mark_depth   = 0.4;    // the lobe's outline is engraved this deep on both outside faces
tip_slit     = 0.5;    // blade slit through the top part of the tip end wall, as a fraction
                       // of its height, so the blade can start sliding in from that end
cutaway     = false;   // view only: one side wall removed - set false before printing

// blade mockup (view only - set show_blade false before exporting)
show_blade  = false;

lead_in     = 0.8;     // chamfer on the slot lips so it pushes on easier
pinch_gap   = blade_t - 0.2;   // gap between the pinch nubs: 0.2 under the blade
                               // (the dozuki cover used 0.1 under: 0.3 blade, 0.2 gap)
pinch_h     = 1.2;     // height of the pinch nubs
pinch_land  = 0.4;     // flat on the nub tips - a sharp point is thinner than the nozzle
                       // line, so the slicer would drop it and leave a bigger gap

tip_extra  = 2.5;                      // extra room at the tip end (first print was too short)
blade_len  = edge_len + 2*end_clear + tip_extra;   // inside length, at the blade's corners
body_slot  = blade_t + body_gap;
teeth_slot = kerf + teeth_gap;
width      = teeth_slot + 2*wall;
height     = floor_t + cover_h;

// cross-section: x across the blade, y up from the bottom edge
module profile() {
    difference() {
        translate([-width/2, 0]) square([width, height]);
        translate([-teeth_slot/2, floor_t]) square([teeth_slot, tooth_h + 1]);
        translate([-body_slot/2, floor_t]) square([body_slot, cover_h + 1]);
        polygon([[-body_slot/2, height - 2], [-body_slot/2 - lead_in, height + 0.01],
                 [ body_slot/2 + lead_in, height + 0.01], [ body_slot/2, height - 2]]);
        // view only: drop the +x side wall to look inside
        if (cutaway) translate([body_slot/2 + 0.01, -1]) square([width, height + 2]);
    }
    // >< pinch nubs just under the chamfer, pointing in from both walls
    y0 = height - 2;
    for (s = [-1, 1])
        polygon([[s * (body_slot/2 + 0.01), y0],
                 [s * pinch_gap/2, y0 - (pinch_h - pinch_land)/2],
                 [s * pinch_gap/2, y0 - (pinch_h + pinch_land)/2],
                 [s * (body_slot/2 + 0.01), y0 - pinch_h]]);
}

// whole blade, side view: x along this cover's edge from its heel corner, y up from it.
// The bottom half is this edge with its end diagonals and leaning ends; the top half is
// its mirror across the blade's centreline, which splays up at the taper angle.
module blade_outline() {
    big = 200;
    up_heel = [sin(heel_lean), cos(heel_lean)];
    up_toe  = [sin(toe_lean),  cos(toe_lean)];
    p0 = [0, end_rise] + (w_heel/2 - end_rise) * up_heel;   // centreline at the heel end
    module half() {
        intersection() {
            polygon([[heel_run, 0], [edge_len - toe_run, 0], [edge_len, end_rise],
                     [edge_len, end_rise] + big * up_toe,
                     [0, end_rise] + big * up_heel, [0, end_rise]]);
            translate(p0) rotate(taper) translate([-big, -big]) square([4*big, big]);
        }
    }
    half();
    translate(p0) rotate(taper) mirror([0, 1]) rotate(-taper) translate(-p0) half();
}

// blade standing in the slot, tooth edge on the floor, end_clear from the heel end wall
if (show_blade)
    color("silver", 0.6)
        translate([end_clear, 0, floor_t])
            rotate([90, 0, 0]) linear_extrude(height = blade_t, center = true) blade_outline();

// --- cover, built in its own frame: x across, y up, z along the length ---

// lean a shape along the length by angle a, pivoting at the height of the blade's
// corners so the caps sit end_clear from them
module lean(a) {
    k = tan(a);
    y_ref = floor_t + end_rise;
    multmatrix([[1, 0, 0, 0], [0, 1, 0, 0], [0, k, 1, -k * y_ref]]) children();
}

// slab between a face at z0 leaning a0 and a face at z1 leaning a1,
// oversized across and up so it only trims the length
module span(z0, a0, z1, a1) {
    big = 1000;
    intersection() {
        lean(a0) translate([-width, -1, z0])       cube([2*width, big, big]);
        lean(a1) translate([-width, -1, z1 - big]) cube([2*width, big, big]);
    }
}

// channel profile run well past both ends, trimmed to length by span()
module run(z0, a0, z1, a1) {
    intersection() {
        translate([0, 0, -end_wall - 10]) linear_extrude(height = blade_len + 2*end_wall + 20)
            children();
        span(z0, a0, z1, a1);
    }
}

// rounded lobe that fills the heel notch: flat on the end wall side, round toward the tip
module notch_lobe() {
    y1 = floor_t + notch_bottom + notch_clear;
    lh = notch_h - 2*notch_clear;
    z_tip = end_clear + notch_depth - notch_clear;   // blade's rise sits at z = end_clear
    hull() {
        // flat side sits on the end wall's top, so the lobe grows straight out of it
        translate([-width/2, floor_t + notch_bottom, -end_wall])
            cube([width, lh + notch_clear, 0.01]);
        translate([0, y1 + lh/2, max(z_tip - lh/2, -end_wall)]) rotate([0, 90, 0])
            cylinder(d = lh, h = width, center = true, $fn = 64);
    }
}

// arrow engraved on both outside faces, level with the lobe and pointing along the cover
// toward it (toward the heel), to show where it is
module lobe_marks() {
    z_tip = end_clear + notch_depth - notch_clear + 0.6;                  // just past the lobe's tip
    yc    = floor_t + notch_bottom + notch_h / 2;                         // lobe's mid height
    for (s = [-1, 1])
        // map the 2D arrow's x to the cover's length (z) and its y to up (y), cut in across x
        multmatrix([[0, 0, 1, s > 0 ? width/2 - mark_depth : -width/2 - 1],
                    [0, 1, 0, 0], [1, 0, 0, 0]])
            linear_extrude(height = mark_depth + 1)
                translate([z_tip, yc]) rotate(-90)
                    polygon([[0, 0], [-1.75, 2], [-0.6, 2], [-0.6, 6],
                             [0.6, 6], [0.6, 2], [1.75, 2]]);
}

// length along x, opening facing up
rotate([90, 0, 90]) difference() {
  union() {
    // side walls and floor run on past the heel to the end wall's outer face
    run(end_caps ? -end_wall : 0, heel_lean, blade_len, toe_lean) profile();
    if (end_caps) {
        // heel: end wall only up to the notch, with the lobe on top filling the notch
        run(-end_wall, heel_lean, 0, heel_lean)
            translate([-width/2, 0]) square([width, floor_t + notch_bottom]);
        notch_lobe();
        // tip: full height end wall, with the blade slot cut down through its top part
        run(blade_len, toe_lean, blade_len + end_wall, toe_lean)
            difference() {
                translate([-width/2, 0]) square([width, height]);
                translate([-body_slot/2, height * (1 - tip_slit)]) square([body_slot, height]);
                polygon([[-body_slot/2, height - 2], [-body_slot/2 - lead_in, height + 0.01],
                         [ body_slot/2 + lead_in, height + 0.01], [ body_slot/2, height - 2]]);
            }
    }
  }
  if (end_caps) lobe_marks();
}
