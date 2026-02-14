// Makeup Organizer — Straight Tray
// Flat-walled tray with optional decorations.

include <params.scad>
use <shared.scad>
use <decor-columns.scad>
use <decor-bricks.scad>
use <decor-honeycomb.scad>
use <decor-fluting.scad>
use <decor-weave.scad>
use <decor-fins.scad>

module tray_straight() {
    tw = tray_w + 2*puff_max;
    td = tray_d + 2*puff_max;
    tr = end_r + puff_max;

    difference() {
        union() {
            // Base ledge (narrower bottom for stacking)
            stack_base_ledge(tw, td, tr);
            // Main body raised by ledge height
            translate([0, 0, stack_ledge_h])
                linear_extrude(tray_h)
                    stadium(tw, td, tr);
            // Decorations
            translate([0, 0, stack_ledge_h]) {
                if (decoration == "columns")   columns(tw, td, tr, tray_h, "straight");
                if (decoration == "bricks")    bricks_straight(tw, td, tr, tray_h);
                if (decoration == "fluting")   fluting_straight(tw, td, tr, tray_h);
                if (decoration == "honeycomb") honeycomb_straight(tw, td, tr, tray_h);
                if (decoration == "weave")     weave_straight(tw, td, tr, tray_h);
                if (decoration == "fins")      fins_straight(tw, td, tr, tray_h);
            }
        }
        // Interior cut raised by ledge height
        translate([0, 0, stack_ledge_h])
            tray_interior_cut();
        // Top lip channel
        translate([0, 0, stack_ledge_h])
            stack_top_lip(tw, td, tr);
    }
    // Cup sleeves
    translate([0, 0, stack_ledge_h])
        tray_interior_add();
}

// Standalone render
tray_straight();
