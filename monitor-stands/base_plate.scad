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
echo("socket floor =", plate_h - socket_depth);  // expect: 3
echo("atlas dist from center =", atlas_y_offset);       // 66.7
echo("rear col dist from center =", abs(rear_y_offset)); // 33.3
echo("atlas + rear =", atlas_y_offset + abs(rear_y_offset)); // 100

// ── Geometry ──────────────────────────────────────
base_plate();

module base_plate() {
    difference() {
        stepped_disc();
        socket_holes();
        meander_ring();
    }
}

module stepped_disc() {
    for (i = [0 : step_count - 1]) {
        r = plate_d/2 - i * step_inset;
        h = plate_h - i * step_h;
        cylinder(r = r, h = h);
    }
}

module socket_holes() {
    // Rear left column
    translate([-rear_span/2, rear_y_offset, plate_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    // Rear right column
    translate([rear_span/2, rear_y_offset, plate_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    // Front Atlas
    translate([0, atlas_y_offset, plate_h - socket_depth])
        cylinder(d = atlas_socket_d + socket_tol, h = socket_depth + 1);
}

module meander_ring() {
    // Greek key approximation: alternating radial and tangential notches
    // arranged in a ring on the top face at radius meander_r
    seg_angle = 360 / round(2 * PI * meander_r / (meander_seg * 2));
    count     = round(360 / seg_angle);

    for (i = [0 : count - 1]) {
        angle = i * seg_angle;
        // Tangential slot
        rotate([0, 0, angle])
        translate([meander_r, 0, plate_h - meander_depth])
            cube([meander_seg, meander_seg * 0.4, meander_depth + 1], center = true);
        // Radial slot (offset half step)
        rotate([0, 0, angle + seg_angle/2])
        translate([meander_r, 0, plate_h - meander_depth])
            cube([meander_seg * 0.4, meander_seg, meander_depth + 1], center = true);
    }
}
