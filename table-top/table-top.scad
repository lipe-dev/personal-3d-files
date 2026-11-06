// Table top — 200x70cm
// Border: 10cm wide, 5cm thick
// Center plank: 2cm thick
// Base: 1700mm wide, centered — arms at 150mm from each edge

width          = 2000;  // 200cm
depth          =  700;  // 70cm
border_width   =  100;  // 10cm
border_thick   =   50;  // 5cm
plank_thick    =   20;  // 2cm

base_width     = 1700;  // base at max stretch
arm_width      =   60;  // arm contact width (X)
gap_fill       = border_thick - plank_thick;  // 30mm
arm_overhang   = (width - base_width) / 2;    // 150mm each side

// Border frame — dark walnut
color([0.36, 0.20, 0.09])
difference() {
    cube([width, depth, border_thick]);
    translate([border_width, border_width, 0])
        cube([width - 2*border_width, depth - 2*border_width, border_thick]);
}

// Center plank — lighter oak
color([0.65, 0.40, 0.18])
translate([border_width, border_width, 0])
    cube([width - 2*border_width, depth - 2*border_width, plank_thick]);

// Arm support planks — fill gap where base arms sit
// Centered at arm_overhang from each edge, spanning full inner depth
color([0.45, 0.26, 0.10])
for (arm_x = [arm_overhang - arm_width/2, width - arm_overhang - arm_width/2])
    translate([arm_x, border_width, plank_thick])
        cube([arm_width, depth - 2*border_width, gap_fill]);
