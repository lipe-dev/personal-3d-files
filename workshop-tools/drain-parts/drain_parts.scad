// Dishwasher drain parts: sink adapter + rubber-to-rubber hose coupler.
// Both print standing up with no supports, laid out side by side on the bed.

part = "both";          // "both" / "adapter" / "coupler"
spacing = 10;           // gap between the parts on the bed
$fn = 128;

// ---- sink adapter: small end -> 52.76mm OD (pipe - cone - pipe) ----
// The extension hose's flat end slips loosely over the small end.
a_small_od  = 17;      // MEASURE: a bit under the inside of the hose's flat end
a_large_od  = 52.76;   // large end outer diameter
a_wall      = 2.4;     // wall thickness
a_small_len = 25;      // length of small straight section
a_large_len = 25;      // length of large straight section
a_cone_len  = 25;      // length of the diagonal transition

// ---- coupler: rubber hose end <-> rubber hose end ----
c_end_od      = 24;    // both ends go into a rubber connector (24 fit the adapter)
c_end_len     = 25;    // length of each barbed end
c_collar_d    = 34;    // stop collar diameter (bigger than the rubber ends' outside)
c_collar_len  = 4;
c_wall        = 2.4;
c_barb_count  = 3;
c_barb_height = 1.0;   // how far each barb sticks out (radius)
c_barb_len    = 5;     // length of each barb ramp

// printed with the large end on the bed
module adapter() {
    difference() {
        union() {
            cylinder(d = a_large_od, h = a_large_len);
            translate([0, 0, a_large_len])
                cylinder(d1 = a_large_od, d2 = a_small_od, h = a_cone_len);
            translate([0, 0, a_large_len + a_cone_len])
                cylinder(d = a_small_od, h = a_small_len);
        }
        union() {
            translate([0, 0, -0.01])
                cylinder(d = a_large_od - 2*a_wall, h = a_large_len + 0.02);
            translate([0, 0, a_large_len])
                cylinder(d1 = a_large_od - 2*a_wall, d2 = a_small_od - 2*a_wall, h = a_cone_len);
            translate([0, 0, a_large_len + a_cone_len - 0.01])
                cylinder(d = a_small_od - 2*a_wall, h = a_small_len + 0.02);
        }
    }
}

// barbed end pointing up from z = 0; ramps down toward the tip
module c_barbed_end() {
    cylinder(d = c_end_od, h = c_end_len);
    for (i = [0 : c_barb_count - 1])
        translate([0, 0, c_end_len - 2 - (i + 1) * c_barb_len])
            cylinder(d1 = c_end_od + 2*c_barb_height, d2 = c_end_od, h = c_barb_len);
}

// printed standing up, either end down
module coupler() {
    cone_h  = (c_collar_d - c_end_od) / 2;     // 45° underside on the collar
    top_end = c_end_len + cone_h + c_collar_len;
    difference() {
        union() {
            translate([0, 0, c_end_len]) mirror([0, 0, 1]) c_barbed_end();
            translate([0, 0, c_end_len]) cylinder(d1 = c_end_od, d2 = c_collar_d, h = cone_h);
            translate([0, 0, c_end_len + cone_h]) cylinder(d = c_collar_d, h = c_collar_len);
            translate([0, 0, top_end]) c_barbed_end();
        }
        translate([0, 0, -1])
            cylinder(d = c_end_od - 2*c_wall, h = top_end + c_end_len + 2);
    }
}

if (part == "adapter") adapter();
else if (part == "coupler") coupler();
else {
    adapter();
    translate([a_large_od/2 + spacing + c_collar_d/2, 0, 0]) coupler();
}
