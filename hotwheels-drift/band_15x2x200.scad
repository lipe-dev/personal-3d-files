// Dashboard wrap band
// Section 1: 17cm straight
// Section 2: 180° curve
// Cross-section: 2mm thick x 15mm tall

$fn = 100;

curve_radius = 6; // 6mm radius for the curve
curve_angle = 160; // degrees
start_angle = -90; // starting angle of curve

union() {
    // Section 1: Straight part (170mm)
    cube([170, 2, 15]);

    // Section 2: 160-degree curve
    translate([170, 2 + curve_radius, 0])
        rotate([0, 0, -90])
            rotate_extrude(angle = 160)
                translate([curve_radius, 0, 0])
                    square([2, 15]);

    // Section 3: Continue backwards for 30mm
    // Calculate end position and angle after curve
    translate([
        170 + (curve_radius + 2) * cos(start_angle + curve_angle),
        2 + curve_radius + (curve_radius + 2) * sin(start_angle + curve_angle),
        0
    ])
        rotate([0, 0, 160])
            cube([30, 2, 15]);
}
