// Makeup Organizer — Puffed Tray
// Sine-bulge body: D-profile linear-extruded along straight walls,
// rotate-extruded around corners.

include <params.scad>
use <shared.scad>
use <decor-columns.scad>
use <decor-bricks.scad>
use <decor-honeycomb.scad>
use <decor-fluting.scad>
use <decor-weave.scad>
use <decor-fins.scad>

module tray_puffed() {
    dx = tray_w/2 - end_r;
    dy = tray_d/2 - end_r;
    n  = puff_slices;

    // D cross-section: sine bulge (x = outward, y = height)
    d_pts = [for (i = [0:n]) [puff_max * sin(i/n * 180), i/n * tray_h]];

    difference() {
        union() {
            // Base ledge for stacking
            stack_base_ledge(tray_w, tray_d, end_r);

            translate([0, 0, stack_ledge_h]) {
                // Base stadium (no bulge)
                linear_extrude(tray_h)
                    stadium(tray_w, tray_d, end_r);

                // --- D-profile bulge: straight walls ---

                // Right wall (+X)
                translate([tray_w/2, dy, 0])
                    rotate([90, 0, 0])
                        linear_extrude(2*dy)
                            polygon(d_pts);

                // Left wall (-X)
                mirror([1, 0, 0])
                    translate([tray_w/2, dy, 0])
                        rotate([90, 0, 0])
                            linear_extrude(2*dy)
                                polygon(d_pts);

                // Top wall (+Y)
                rotate([0, 0, 90])
                    translate([tray_d/2, dx, 0])
                        rotate([90, 0, 0])
                            linear_extrude(2*dx)
                                polygon(d_pts);

                // Bottom wall (-Y)
                mirror([0, 1, 0])
                    rotate([0, 0, 90])
                        translate([tray_d/2, dx, 0])
                            rotate([90, 0, 0])
                                linear_extrude(2*dx)
                                    polygon(d_pts);

                // --- D-profile bulge: corners (quarter-circle each) ---

                // Top-right
                translate([dx, dy, 0])
                    rotate_extrude(angle=90)
                        translate([end_r, 0])
                            polygon(d_pts);

                // Top-left
                translate([-dx, dy, 0])
                    rotate([0, 0, 90])
                        rotate_extrude(angle=90)
                            translate([end_r, 0])
                                polygon(d_pts);

                // Bottom-left
                translate([-dx, -dy, 0])
                    rotate([0, 0, 180])
                        rotate_extrude(angle=90)
                            translate([end_r, 0])
                                polygon(d_pts);

                // Bottom-right
                translate([dx, -dy, 0])
                    rotate([0, 0, 270])
                        rotate_extrude(angle=90)
                            translate([end_r, 0])
                                polygon(d_pts);

                // Decorations
                if (decoration == "columns")   columns(tray_w, tray_d, end_r, tray_h, "puffed");
                if (decoration == "bricks")    bricks_puffed(tray_w, tray_d, end_r, tray_h);
                if (decoration == "fluting")   fluting_puffed(tray_w, tray_d, end_r, tray_h);
                if (decoration == "honeycomb") honeycomb_puffed(tray_w, tray_d, end_r, tray_h, puff_max + hex_margin);
                if (decoration == "weave")     weave_puffed(tray_w, tray_d, end_r, tray_h);
                if (decoration == "fins")      fins_puffed(tray_w, tray_d, end_r, tray_h);
            }
        }
        // Interior cut
        translate([0, 0, stack_ledge_h])
            tray_interior_cut();
        // Top lip channel
        translate([0, 0, stack_ledge_h])
            stack_top_lip(tray_w + 2*puff_max, tray_d + 2*puff_max, end_r + puff_max);
    }
    translate([0, 0, stack_ledge_h])
        tray_interior_add();
}

// Standalone render
tray_puffed();
