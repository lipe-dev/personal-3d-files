// Makeup Organizer — Puffed Tray
// Closest trapezoid approximation of the original sine-bulge walls.
// The original used a varying-radius D-profile (thicker in the middle, zero at
// top/bottom), which can't be captured in a single static cross-section.
// This version uses the same outer footprint (reach = puff_max) with a mild
// taper and soft outer corners to suggest the puffed silhouette.

include <params.scad>
use <shared.scad>
use <tray-trapezoid.scad>

module tray_puffed() {
    tray_trapezoid(
        reach   = puff_max,
        h_inner = tray_h,
        h_outer = tray_h - 2*puff_max,
        r_ob    = puff_max / 2,
        r_ot    = puff_max / 2
    );
}

// Standalone render
tray_puffed();
