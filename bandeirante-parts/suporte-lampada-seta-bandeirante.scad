// Suporte da lampada da seta - Bandeirante

difference() {
    union() {
        // Base plate
        cube([60, 30, 5]);

        // Raised block with lamp hole (17mm diameter)
        translate([30, 15, 5])
            translate([-12.5, -12.5, 0])
                cube([25, 25, 10]);
    }

    // 17mm diameter lamp hole
    translate([30, 15, 5])
        cylinder(h=35, d=17, $fn=64);

    // 5mm wide, 2.5mm deep cable channel on the front side of the lamp hole
    translate([30 - 2.5, 15 + 8.5 - 1, 0])
        cube([5, 2.5, 35]);

    // 3x 6mm mounting holes, spaced 18mm apart
    for (dx = [-18, 0, 18]) {
        translate([30 + dx, 15, -2])
            cylinder(h=45, d=6, $fn=32);
    }
}
