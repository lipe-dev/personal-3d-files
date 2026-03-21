// Makeup Organizer — Straight Tray
// Flat vertical walls: rectangular wall profile, same outer footprint as before.

include <params.scad>
use <shared.scad>
use <tray-trapezoid.scad>

module tray_straight() {
    tray_trapezoid(
        reach   = puff_max,
        h_inner = tray_h,
        h_outer = tray_h
    );
}

// Standalone render
tray_straight();
