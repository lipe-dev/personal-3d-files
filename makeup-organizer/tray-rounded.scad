// Makeup Organizer — Rounded Tray
// Minkowski-rounded body with decorations clipped to match.

include <params.scad>
use <shared.scad>
use <decor-columns.scad>
use <decor-bricks.scad>
use <decor-honeycomb.scad>
use <decor-fluting.scad>
use <decor-weave.scad>
use <decor-fins.scad>

module tray_rounded() {
    cr = min(round_r, tray_h/2);
    rw = tray_w + 2*round_r;
    rd = tray_d + 2*round_r;
    rr = end_r + round_r;

    difference() {
        union() {
            // Base ledge
            stack_base_ledge(rw, rd, rr);
            // Rounded body raised by ledge height
            translate([0, 0, stack_ledge_h]) {
                translate([0, 0, cr])
                    minkowski() {
                        linear_extrude(tray_h - 2*cr)
                            stadium(tray_w, tray_d, end_r);
                        sphere(r=cr, $fn=32);
                    }
                if (decoration == "columns")   columns(rw, rd, rr, tray_h, "straight");
                if (decoration == "bricks")    bricks_straight(rw, rd, rr, tray_h);
                if (decoration == "fluting") {
                    cr2 = min(round_r, tray_h/2);
                    intersection() {
                        fluting_straight(rw, rd, rr, tray_h);
                        translate([0, 0, cr2])
                            minkowski() {
                                linear_extrude(tray_h - 2*cr2)
                                    stadium(tray_w + 2*flute_depth, tray_d + 2*flute_depth, end_r + flute_depth);
                                sphere(r=cr2, $fn=32);
                            }
                    }
                }
                if (decoration == "weave")     weave_straight(rw, rd, rr, tray_h);
                if (decoration == "fins")      fins_straight(rw, rd, rr, tray_h);
                if (decoration == "honeycomb") {
                    rounded_hex_h = tray_h - 2*cr;
                    translate([0, 0, cr])
                        honeycomb_straight(rw, rd, rr, rounded_hex_h);
                }
            }
        }
        // Interior cut raised
        translate([0, 0, stack_ledge_h])
            tray_interior_cut();
        // Top lip channel
        translate([0, 0, stack_ledge_h])
            stack_top_lip(rw, rd, rr);
    }
    translate([0, 0, stack_ledge_h])
        tray_interior_add();
}

// Standalone render
tray_rounded();
