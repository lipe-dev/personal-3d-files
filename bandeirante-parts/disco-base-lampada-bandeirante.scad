// Disco base da lampada - Bandeirante

disc_d = 14;
disc_t = 0.8;
tab_w  = 2.5;
tab_l  = 2;
tab_t  = disc_t;
pin_d  = 1;
pin_h  = 1.5;
pin_spacing = 8;
hole_d = 3;
hole_spacing = 7;

difference() {
    union() {
        // Disc
        cylinder(h=disc_t, d=disc_d, $fn=64);

        // Side tabs (opposite sides)
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([disc_d/2 - 1.2, -tab_w/2, 0])
                    cube([tab_l, tab_w, tab_t]);
        }

        // Pins on top
        for (dy = [-pin_spacing/2, pin_spacing/2]) {
            translate([0, dy, disc_t])
                cylinder(h=pin_h, d=pin_d, $fn=32);
        }

        // Center pin
        translate([0, 0, disc_t])
            cylinder(h=pin_h, d=1.5, $fn=32);
    }

    // 2mm holes through disc, perpendicular to pins (along X axis)
    for (dx = [-hole_spacing/2, hole_spacing/2]) {
        translate([dx, 0, -1])
            cylinder(h=disc_t + 2, d=hole_d, $fn=32);
    }
}
