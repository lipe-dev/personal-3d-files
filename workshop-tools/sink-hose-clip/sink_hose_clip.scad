// Sink hose clip: C clamp that hooks over the sink edge,
// with snap-in hose rings on the outside leg.
// One solid model - cut it in the slicer (with connectors) for printing.

sink_thickness = 97;    // outer lip to inside of the bowl
squeeze        = 0;     // gap is this much smaller than the edge (negative = looser)
clip_width     = 20;    // width of the clamp
wall           = 7;     // clamp wall thickness (legs and bridge)
inner_leg      = 40;    // leg that goes into the bowl
outer_leg      = 80;    // leg on the outside, carries the rings

hose_d         = 29;    // MEASURE: hose outer diameter (+0.5 clearance)
ring_wall      = 3;     // ring wall thickness
ring_h         = 12;    // ring height
ring_count     = 2;
ring_opening   = 0.8;   // snap opening as a fraction of hose_d (smaller = tighter snap)
plate_t        = 4;     // backing plate joining the rings into one piece
$fn = 96;

gap      = sink_thickness - squeeze;
ring_od  = hose_d + 2*ring_wall;
leg_face = gap + wall;                         // outer face of the outside leg
ring_cx  = leg_face + plate_t + ring_od/2 - 1; // ring centre, slightly merged into the plate
block_w  = min(clip_width, ring_od * 0.6);

// bottom of each ring along the outer leg (sink edge top at z = 0)
z_lo = -outer_leg;
z_hi = -ring_h;
function ring_z(i) = ring_count == 1 ? z_hi
                   : z_lo + i * (z_hi - z_lo) / (ring_count - 1);

module clip() {
    // C profile drawn in XZ, extruded along Y
    rotate([90, 0, 0])
        linear_extrude(height = clip_width, center = true)
            difference() {
                union() {
                    translate([-wall, -inner_leg]) square([wall, inner_leg + wall]); // inner leg
                    translate([gap, -outer_leg])   square([wall, outer_leg + wall]); // outer leg
                    translate([-wall, 0])          square([gap + 2*wall, wall]);     // bridge
                }
                // lead-in chamfers on the leg tips so it slides on easier
                translate([0, -inner_leg])
                    polygon([[0.01, -0.01], [0.01, 3], [-1.5, -0.01]]);
                translate([gap, -outer_leg])
                    polygon([[-0.01, -0.01], [-0.01, 3], [1.5, -0.01]]);
            }
}

module ring() {
    difference() {
        union() {
            translate([leg_face + plate_t - 0.01, -block_w/2, 0])
                cube([ring_cx - leg_face - plate_t, block_w, ring_h]);
            translate([ring_cx, 0, 0]) cylinder(d = ring_od, h = ring_h);
        }
        translate([ring_cx, 0, -1]) cylinder(d = hose_d, h = ring_h + 2);
        // snap opening facing away from the sink
        translate([ring_cx, -hose_d*ring_opening/2, -1])
            cube([ring_od, hose_d*ring_opening, ring_h + 2]);
    }
}

module rings() {
    // backing plate on the outer leg; cut at the leg face to split the rings off as one piece
    translate([leg_face - 0.01, -clip_width/2, ring_z(0)])
        cube([plate_t + 0.01, clip_width, ring_z(ring_count - 1) + ring_h - ring_z(0)]);
    for (i = [0 : ring_count - 1])
        translate([0, 0, ring_z(i)]) ring();
}

clip();
rings();
