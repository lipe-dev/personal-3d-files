// Hose coupler: rubber hose end <-> rubber hose end.
// Same barbed 24mm end on both sides, stop collar in the middle.
// Print standing up, either end down - no supports needed.

end_od        = 24;    // both ends go into a rubber connector (24 fit the adapter)
end_len       = 25;    // length of each barbed end
collar_d      = 34;    // stop collar diameter (bigger than the rubber ends' outside)
collar_len    = 4;
wall          = 2.4;
barb_count    = 3;
barb_height   = 1.0;   // how far each barb sticks out (radius)
barb_len      = 5;     // length of each barb ramp
$fn = 128;

bore    = end_od - 2*wall;
cone_h  = (collar_d - end_od) / 2;             // 45° underside on the collar
total   = 2*end_len + cone_h + collar_len;
top_end = end_len + cone_h + collar_len;       // where the top end starts

// barbed end pointing up from z = 0; ramps down toward the tip
module barbed_end() {
    cylinder(d = end_od, h = end_len);
    for (i = [0 : barb_count - 1])
        translate([0, 0, end_len - 2 - (i + 1) * barb_len])
            cylinder(d1 = end_od + 2*barb_height, d2 = end_od, h = barb_len);
}

difference() {
    union() {
        translate([0, 0, end_len]) mirror([0, 0, 1]) barbed_end();
        translate([0, 0, end_len]) cylinder(d1 = end_od, d2 = collar_d, h = cone_h);
        translate([0, 0, end_len + cone_h]) cylinder(d = collar_d, h = collar_len);
        translate([0, 0, top_end]) barbed_end();
    }
    translate([0, 0, -1]) cylinder(d = bore, h = total + 2);
}
