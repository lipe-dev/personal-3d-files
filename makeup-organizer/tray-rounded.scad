// Makeup Organizer — Rounded Tray
// Chamfered wall profile approximating the original Minkowski-sphere rounding.
// Cross-section: inner face full height, outer face trimmed by round_r top and
// bottom, with the outer corners softened to radius round_r/2.

include <params.scad>
use <shared.scad>
use <tray-trapezoid.scad>

module tray_rounded() {
    tray_trapezoid(
        reach   = round_r,
        h_inner = tray_h,
        h_outer = tray_h - 2*round_r,
        r_ob    = round_r / 2,
        r_ot    = round_r / 2
    );
}

// Standalone render
tray_rounded();
