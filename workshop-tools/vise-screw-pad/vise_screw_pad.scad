// Vise screw end pad: disc with a truncated cone on top.
// The screw end goes into the top: a 6mm neck hole, then a wider pocket below it
// that the screw's head sits in.
// Print disc down - the pocket roof is a short bridge, no supports needed.

disc_d      = 50;
disc_h      = 8;
cone_d1     = 30;      // cone base
cone_d2     = 20;      // cone top
cone_h      = 10;

neck_d      = 6.5;       // hole from the top
neck_h      = 5;
pocket_d    = 10;     // wider pocket under the neck hole
pocket_h    = 5;
$fn = 128;

total = disc_h + cone_h;

difference() {
    union() {
        cylinder(d = disc_d, h = disc_h);
        translate([0, 0, disc_h]) cylinder(d1 = cone_d1, d2 = cone_d2, h = cone_h);
    }
    translate([0, 0, total - neck_h]) cylinder(d = neck_d, h = neck_h + 1);
    translate([0, 0, total - neck_h - pocket_h]) cylinder(d = pocket_d, h = pocket_h + 0.01);
}
