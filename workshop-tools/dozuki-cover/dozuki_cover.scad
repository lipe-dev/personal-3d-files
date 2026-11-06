// Dozuki saw tooth cover: U-channel that presses onto the toothed edge from the side,
// capped at both ends. Inside: a wider channel at the bottom for the set teeth,
// and a thin slot above it that grips the blade body.
// The end caps lean to match the blade's end edges (/__/).
// Print on its closed bottom edge, opening up - no supports or bridges.

edge_len    = 241.5;   // blade's full bottom length, including the end diagonals
end_rise    = 1.5;     // the diagonals at each end of the edge rise this much
heel_lean   = 2.5;     // lean of the heel end edge, degrees from vertical - smaller is steeper
toe_lean    = 1;       // lean of the toe end edge, steeper than the heel (both lean the same way, /__/)
end_clear   = 0.5;     // gap between each blade end and its end cap
cover_h     = 18;      // MEASURE: how far up the blade it reaches (less than tooth tips to spine)
blade_t     = 0.3;     // blade body thickness
kerf        = 0.9;     // MEASURE: thickness across the set teeth
tooth_h     = 2;       // MEASURE: tooth height

body_gap    = 0.15;    // slot clearance on the blade body (small = more friction)
teeth_gap   = 0.6;     // clearance on the teeth
floor_t     = 2;       // wall under the tooth tips
wall        = 1.6;     // side wall thickness
end_wall    = 2.5;     // end caps at the heel and toe
end_caps    = true;    // false to see the profile from the end - set true before printing
tall_cap    = "toe";   // which end cap reaches further up the blade: "toe" or "heel"
tall_cap_h  = 21.5;    // how far up the blade the tall cap covers, from the cutting edge
hook_nub_r  = 1.5;     // MEASURE: rounded nub on top of the tall cap (above tall_cap_h), hooks
                       // into the notch in the blade's end edge - this is how far it sticks in
cutaway     = false;   // view only: one side wall removed - set false before printing

// blade mockup (view only - set show_blade false before exporting)
show_blade  = false;
heel_run    = 8;       // diagonal length at the heel end (x = 0 side), part of edge_len
toe_run     = 3;       // diagonal length at the toe end, part of edge_len
mock_h      = 45;      // MEASURE: blade height to draw

lead_in     = 0.8;     // chamfer on the slot lips so it pushes on easier
pinch_gap   = 0.2;     // gap between the pinch nubs: about the smallest a 0.4mm nozzle keeps
                       // open, and still under the blade so they grip it
pinch_h     = 1.2;     // height of the pinch nubs
pinch_land  = 0.4;     // flat on the nub tips - a sharp point is thinner than the nozzle
                       // line, so the slicer would drop it and leave a bigger gap

blade_len  = edge_len + 2*end_clear;   // inside length, measured where the blade's corners are
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

// blade side view: x along the blade from its heel corner, y up from the cutting edge
module blade_outline() {
    rise = mock_h - end_rise;
    polygon([[heel_run, 0], [edge_len - toe_run, 0],
             [edge_len, end_rise], [edge_len + rise * tan(toe_lean), mock_h],
             [rise * tan(heel_lean), mock_h], [0, end_rise]]);
}

// blade standing in the slot, tooth edge on the floor, centred along the cover
if (show_blade)
    color("silver", 0.6)
        translate([(blade_len - edge_len) / 2, 0, floor_t])
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

module floor_band() { translate([-width, -1]) square([2*width, floor_t + 1]); }

// length along x, opening facing up
rotate([90, 0, 90]) {
    // walls, then the floor under the teeth (red, preview only)
    run(0, heel_lean, blade_len, toe_lean) difference() { profile(); floor_band(); }
    run(0, heel_lean, blade_len, toe_lean) intersection() { profile(); floor_band(); }
    // end caps: full solid section, each leaning with its blade end edge
    tall = floor_t + tall_cap_h;
    tall_top = tall + 2*hook_nub_r;             // the tall cap carries on up to the nub's top
    if (end_caps) {
        run(-end_wall, heel_lean, 0, heel_lean)
            translate([-width/2, 0]) square([width, tall_cap == "heel" ? tall_top : height]);
        run(blade_len, toe_lean, blade_len + end_wall, toe_lean)
            translate([-width/2, 0]) square([width, tall_cap == "toe" ? tall_top : height]);
        // hook nub sitting on top of the tall cap (above tall_cap_h), on its inner face,
        // pointing at the blade
        y_n = tall + hook_nub_r;
        y_ref = floor_t + end_rise;
        z_n = tall_cap == "toe" ? blade_len + tan(toe_lean) * (y_n - y_ref)
                                : tan(heel_lean) * (y_n - y_ref);
        translate([0, y_n, z_n]) rotate([0, 90, 0])
            cylinder(r = hook_nub_r, h = width, center = true, $fn = 48);
    }
}
