// Cylinder with 608ZZ bearing recess
// Cylinder: Diameter 26mm, Height 15mm
// Bearing recess: Diameter 22mm, Depth 8mm

$fn = 100; // Set resolution for smooth curves

difference() {
    // Rotated cylinder with bearing recess
    rotate([0, 20, 0]) {
        difference() {
            // Main cylinder (extended to compensate for rotation)
            cylinder(h = 22, d = 26, center = false);

            // Bearing recess (608ZZ)
            translate([0, 0, 14])
                cylinder(h = 8.1, d = 22, center = false);
        }
    }

    // Cut off bottom to make base flush
    translate([-50, -50, -50])
        cube([100, 100, 53]);

    // Channel recess in bottom (15mm wide, 4mm deep)
    translate([-20, -7.5, 1])
        cube([40, 15, 4]);
}
