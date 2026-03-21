// Makeup Organizer — Trapezoid Tray
// Rounded trapezoid cross-section extruded continuously around the stadium
// perimeter. All style files (straight, rounded, puffed) are wrappers around
// this module with style-specific parameters.

include <params.scad>
use <shared.scad>

module tray_trapezoid(
    reach   = wall_reach,
    h_inner = wall_h_inner,
    h_outer = wall_h_outer,
    r_ib    = wall_r_inner_bot,
    r_it    = wall_r_inner_top,
    r_ob    = wall_r_outer_bot,
    r_ot    = wall_r_outer_top
) {
    dx = tray_w/2 - end_r;
    dy = tray_d/2 - end_r;
    ow = tray_w + 2*reach;
    od = tray_d + 2*reach;
    or_ = end_r + reach;
    clip_r = end_r + reach + 1;
    clip_h = max(h_inner, h_outer) + 1;

    difference() {
        union() {
            stack_base_ledge(ow, od, or_);

            translate([0, 0, stack_ledge_h]) {
                // Inner wall mass — the body the profile attaches to
                linear_extrude(tray_h)
                    stadium(tray_w, tray_d, end_r);

                // --- Wall profile: straight segments ---

                // Right wall (+X)
                translate([tray_w/2, dy, 0])
                    rotate([90, 0, 0])
                        linear_extrude(2*dy)
                            wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);

                // Left wall (-X)
                mirror([1, 0, 0])
                    translate([tray_w/2, dy, 0])
                        rotate([90, 0, 0])
                            linear_extrude(2*dy)
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);

                // Top wall (+Y)
                rotate([0, 0, 90])
                    translate([tray_d/2, dx, 0])
                        rotate([90, 0, 0])
                            linear_extrude(2*dx)
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);

                // Bottom wall (-Y)
                mirror([0, 1, 0])
                    rotate([0, 0, 90])
                        translate([tray_d/2, dx, 0])
                            rotate([90, 0, 0])
                                linear_extrude(2*dx)
                                    wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);

                // --- Wall profile: corners (rotate_extrude clipped to quadrant) ---

                // Top-right (+X, +Y)
                translate([dx, dy, 0])
                    intersection() {
                        rotate_extrude(angle=360)
                            translate([end_r, 0])
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);
                        cube([clip_r, clip_r, clip_h]);
                    }

                // Top-left (-X, +Y)
                translate([-dx, dy, 0])
                    intersection() {
                        rotate_extrude(angle=360)
                            translate([end_r, 0])
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);
                        translate([-clip_r, 0, 0]) cube([clip_r, clip_r, clip_h]);
                    }

                // Bottom-left (-X, -Y)
                translate([-dx, -dy, 0])
                    intersection() {
                        rotate_extrude(angle=360)
                            translate([end_r, 0])
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);
                        translate([-clip_r, -clip_r, 0]) cube([clip_r, clip_r, clip_h]);
                    }

                // Bottom-right (+X, -Y)
                translate([dx, -dy, 0])
                    intersection() {
                        rotate_extrude(angle=360)
                            translate([end_r, 0])
                                wall_profile(reach, h_inner, h_outer, r_ib, r_it, r_ob, r_ot);
                        translate([0, -clip_r, 0]) cube([clip_r, clip_r, clip_h]);
                    }
            }
        }

        translate([0, 0, stack_ledge_h])
            tray_interior_cut();

        translate([0, 0, stack_ledge_h])
            stack_top_lip(ow, od, or_);
    }

    translate([0, 0, stack_ledge_h])
        tray_interior_add();
}

// Standalone render
tray_trapezoid();
