// Suporte da lampada da seta - Bandeirante (lado motorista)

difference() {
    union() {
        // Base plate
        cube([60, 30, 5]);

        // Raised block with lamp hole (17mm diameter)
        translate([30, 15, 5])
            translate([-12.5, -12.5, 0])
                cube([25, 25, 10]);
    }

    // 18mm diameter lamp hole (driver side)
    translate([30, 15, 5])
        cylinder(h=35, d=18, $fn=64);

    // Wire channels: cylinder 1.5mm wider than hole, trimmed to 11mm middle
    translate([30, 15, 5])
        intersection() {
            cylinder(h=35, d=18 + 1.5, $fn=64);
            translate([-5.5, -20, 0])
                cube([11, 40, 35]);
        }

    // Perpendicular wire channels: same cylinder, trimmed to 5mm middle
    translate([30, 15, 5])
        intersection() {
            cylinder(h=35, d=18 + 1.5, $fn=64);
            translate([-20, -2.5, 0])
                cube([40, 5, 35]);
        }

    // 3x 6mm mounting holes, spaced 18mm apart
    for (dx = [-18, 0, 18]) {
        translate([30 + dx, 15, -2])
            cylinder(h=45, d=6, $fn=32);
    }
}
