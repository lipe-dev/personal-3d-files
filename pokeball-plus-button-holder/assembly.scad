// Pokeball Plus button-holder assembly preview
// Ball at origin, top button pole on +Z axis.

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
use <plunger.scad>

$fn = 96;

ball_d    = 48;
ball_slop = 0.7;                  // extra cavity diameter for fit
cavity_d  = ball_d + ball_slop;   // 48.8
wall      = 4;
shell_d   = ball_d + 2 * wall;
strip_w   = 24;

// Big M12 nut pocket at the top center of the strap
big_nut_acf = 19;                       // M12 nut across-flats
big_nut_acr = big_nut_acf / cos(30);    // across-corners + dia for $fn=6
big_nut_h   = 5;                        // matches plunger_nut sliced thickness

module big_nut_pocket() {
    // Hex hole through the top of the shell, extended in +Z and -Z
    pocket_extend = 4;
    translate([0, 0, ball_d/2 - pocket_extend])
        rotate([0, 0, 30])
            cylinder(d = big_nut_acr - 1.5, h = wall + 2 * pocket_extend, $fn = 6);
}

module main_assembly() {
    // Pokeball Plus reference
    %sphere(d = ball_d);

    // Strap shell (hollow, sliced to a strip on Y axis) — colored by caller
    difference() {
        intersection() {
            difference() {
                sphere(d = shell_d);
                sphere(d = cavity_d);
            }
            cube([60, strip_w, 60], center = true);
        }
        translate([ boss_x, 0, 0])               screw_cutouts();
        translate([-boss_x, 0, 0]) mirror([1,0,0]) screw_cutouts();
        big_nut_pocket();
    }

    // M12 nut seated in the top hex pocket
    translate([0, 0, shell_d/2 - big_nut_h + 1.2])
        rotate([0, 0, 30])
            plunger_nut();

    // M3 side-screw bosses
    translate([ boss_x, 0, 0])               boss_with_gussets();
    translate([-boss_x, 0, 0]) mirror([1,0,0]) boss_with_gussets();
}

// Render mode: change PART to export individual STL pieces.
// "preview" -> all 3 sliced copies side-by-side
// "top"     -> upper strap half (flat face on bed)
// "middle"  -> middle 3mm band slice (separate-color piece)
// "bottom"  -> lower strap half (flat face on bed)
// "screw"   -> plunger screw, knob on bed
// "pad"     -> swivel pad
PART = "preview";

if (PART == "preview") {
    // Bottom half — on its side (curved face down)
    color("SteelBlue")
    translate([0, 0, strip_w/2])
        rotate([90, 0, 0])
            intersection() {
                main_assembly();
                translate([0, 0, -2.1 - 100])
                    cube([200, 200, 200], center = true);
            }
    // Middle band — flat on bed
    color("Crimson")
    translate([70, 0, 1.4])
        intersection() {
            main_assembly();
            cube([200, 200, 2.8], center = true);
        }
    // Top half — on its side (curved face down)
    color("SteelBlue")
    translate([140, 0, strip_w/2])
        rotate([90, 0, 0])
            intersection() {
                main_assembly();
                translate([0, 0, 2.1 + 100])
                    cube([200, 200, 200], center = true);
            }
    // Screw — knob on bed
    color("DimGray")
    translate([0, 70, 14])
        rotate([180, 0, 0])
            plunger_screw();
    // Plunger shaft with cone
    color("White")
    translate([35, 70, 0])
        plunger_inner_shaft();
    // Plunger shaft without cone
    color("White")
    translate([55, 70, 0])
        plunger_inner_shaft_no_cone();
    // Pad — flat on bed
    color("White")
    translate([90, 70, 0])
        swivel_pad();
}
else if (PART == "top") {
    // Upper strap half, flipped so cut face is on the bed
    rotate([180, 0, 0])
        intersection() {
            main_assembly();
            translate([0, 0, 2 + 100])
                cube([200, 200, 200], center = true);
        }
}
else if (PART == "middle") {
    // Middle 3mm band slice
    intersection() {
        main_assembly();
        cube([200, 200, 3], center = true);
    }
}
else if (PART == "bottom") {
    // Lower strap half, cut face on the bed
    intersection() {
        main_assembly();
        translate([0, 0, -2 - 100])
            cube([200, 200, 200], center = true);
    }
}
else if (PART == "screw") {
    // Hollow screw + inner shaft side-by-side for printing
    translate([-15, 0, 14])
        rotate([180, 0, 0])
            plunger_screw();
    translate([15, 0, 0])
        plunger_inner_shaft();
}
else if (PART == "pad") {
    swivel_pad();
}

// --- M3 side-screw bosses (one per side, hugging the strap ends) ---
m3_clearance = 3.4;
boss_od      = 7.5;
boss_h       = 22;
boss_x       = shell_d / 2 + 0.5;

bore_extend = 5;   // bore overshoot beyond top + bottom of boss

module boss_solid() {
    cylinder(d = boss_od, h = boss_h, center = true);
}

module bore() {
    cylinder(d = m3_clearance, h = boss_h + 2 * bore_extend, center = true);
}

// Round counterbore at the top for an M3 socket-head screw
head_d = 6.0;
head_h = 5;

module head_counterbore() {
    translate([0, 0, boss_h/2 - head_h])
        cylinder(d = head_d, h = head_h + 0.1);
}

nut_acf  = 5.8;        // M3 nut across-flats + clearance
nut_acr  = nut_acf / cos(30);   // across corners
nut_h    = 5;          // pocket depth

module nut_pocket() {
    // Open at bottom, hex recess for M3 nut
    translate([0, 0, -boss_h/2 - bore_extend])
        rotate([0, 0, 30])
            cylinder(d = nut_acr, h = nut_h + bore_extend, $fn = 6);
}

gusset_y      = 6;
gusset_inset  = 3;
gusset_x      = sqrt(pow(shell_d/2, 2) - pow(gusset_y, 2)) - gusset_inset;
gusset_anchor = 0.5;

cap_d        = 12;
cap_l        = 18;
cap_offset_z = 4;
cap_offset_x = 0.5;

module cap_cylinders() {
    for (sz = [-1, 1]) {
        translate([cap_offset_x, -cap_l/2, sz * (boss_h/2 + cap_offset_z)])
            rotate([-90, 0, 0])
                cylinder(d = cap_d, h = cap_l);
        // Cube cutout flush with the cap, same length, extends outward
        cube_inset_z  = 6;
        cube_offset_x = 6;
        translate([cap_offset_x - cap_d/2 + cube_offset_x, -cap_l/2,
                   sz > 0
                     ? boss_h/2 + cap_offset_z - cube_inset_z
                     : -(boss_h/2 + cap_offset_z + cap_d - cube_inset_z)])
            cube([cap_d, cap_l, cap_d]);
    }
}

// Cuts that pass through everything (boss + shell)
module screw_cutouts() {
    bore();
    head_counterbore();
    nut_pocket();
}

module boss_with_gussets() {
    difference() {
        union() {
            boss_solid();
            for (sy = [-1, 1])
                hull() {
                    boss_solid();
                    translate([-(boss_x - gusset_x), sy * gusset_y, 0])
                        cylinder(d = gusset_anchor, h = boss_h, center = true);
                }
        }
        screw_cutouts();
        cap_cylinders();   // caps only sculpt the boss, not the shell
    }
}


