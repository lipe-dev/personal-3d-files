// Pipe adapter: small end -> 52.76mm OD (pipe - cone - pipe)
// The extension hose's flat end slips loosely over the small end.

small_od    = 17;      // MEASURE: a bit under the inside of the hose's flat end
large_od    = 52.76;   // large end outer diameter
wall        = 2.4;     // wall thickness
small_len   = 25;      // length of small straight section
large_len   = 25;      // length of large straight section
cone_len    = 25;      // length of the diagonal transition
// barbs on the small end (off: the hose's flat end is a loose slip fit)
barbs       = false;
barb_count  = 3;
barb_height = 1.0;     // how far each barb sticks out (radius)
barb_len    = 5;       // length of each barb ramp
$fn = 128;

total = large_len + cone_len + small_len;

difference() {
    // outer shell
    union() {
        cylinder(d = large_od, h = large_len);
        translate([0, 0, large_len])
            cylinder(d1 = large_od, d2 = small_od, h = cone_len);
        translate([0, 0, large_len + cone_len])
            cylinder(d = small_od, h = small_len);
        // sawtooth barbs: ramp down toward the tip so the hose slides on easily
        // and the sharp edge resists pulling off
        if (barbs)
            for (i = [0 : barb_count - 1])
                translate([0, 0, total - 2 - (i + 1) * barb_len])
                    cylinder(d1 = small_od + 2*barb_height, d2 = small_od, h = barb_len);
    }
    // bore
    union() {
        translate([0, 0, -0.01])
            cylinder(d = large_od - 2*wall, h = large_len + 0.02);
        translate([0, 0, large_len])
            cylinder(d1 = large_od - 2*wall, d2 = small_od - 2*wall, h = cone_len);
        translate([0, 0, large_len + cone_len - 0.01])
            cylinder(d = small_od - 2*wall, h = small_len + 0.02);
    }
}
