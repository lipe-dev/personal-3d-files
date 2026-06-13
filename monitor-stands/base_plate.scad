// Base plate — Atlas monitor stand
// All dimensions in mm

// Overall geometry
plate_d         = 240;   // outer diameter, bottom step
plate_h         = 15;    // total plate thickness

// Triangle socket positions (relative to plate center = triangle centroid)
rear_span       = 160;   // center-to-center between rear two column sockets
atlas_y_offset  = 66.7;  // Atlas socket forward of centroid
rear_y_offset   = -33.3; // rear column sockets behind centroid

// Sockets
socket_depth    = 12;    // how deep the peg sits
col_socket_d    = 25;    // column peg diameter — adjust after measuring sourced STL
atlas_socket_d  = 20;    // Atlas peg diameter — adjust after measuring sourced STL
socket_tol      = 0.3;   // friction-fit tolerance (added to socket diameter)

// Stepped edge
step_count      = 3;
step_h          = plate_h / step_count;  // 5mm per step
step_inset      = 5;     // each step narrows by this much in radius

// Meander border
meander_clearance = 10;  // gap between stepped edge outer rim and meander band
meander_r       = plate_d/2 - step_inset * step_count - meander_clearance;
meander_depth   = 1.5;   // how deep meander is engraved
meander_w       = 6;     // width of meander band
meander_seg     = 3;     // size of each meander square cell

$fn = 120;
// F5 = fast preview ($fn=120 still fine)
// F6 = full render before STL export — may take 30-60s

echo("step_h =", step_h);          // expect: 5
echo("top step r =", plate_d/2 - (step_count-1)*step_inset);  // expect: 105

// ── Geometry ──────────────────────────────────────
base_plate();

module base_plate() {
    difference() {
        stepped_disc();
        // socket_holes();   — added in Task 2
        // meander_ring();   — added in Task 3
    }
}

module stepped_disc() {
    for (i = [0 : step_count - 1]) {
        r = plate_d/2 - i * step_inset;
        h = plate_h - i * step_h;
        cylinder(r = r, h = h);
    }
}
