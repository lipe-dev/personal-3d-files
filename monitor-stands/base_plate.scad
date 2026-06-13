// Base plate — Atlas monitor stand
// Greek crepidoma: 3-tier square stepped platform (euthynteria → stereobate → stylobate)
// All dimensions in mm

// Overall geometry
tier_count      = 3;
tier_inset      = 15;    // each tier narrows by this much on each side
tier_h          = 10;    // height of each tier
lip_h           = 4;     // raised fillet ridge at outer edge of each tread
lip_out         = 6;     // width of lip strip
base_w          = 250;   // bottom tier width (square)
base_d          = 250;   // bottom tier depth (square)
total_h         = tier_count * tier_h;  // 30mm total

// Triangle socket positions (relative to plate center = triangle centroid)
rear_span        = 160;   // center-to-center between rear two column sockets
atlas_y_offset   = 66.7;  // Atlas socket forward of centroid
rear_y_offset    = -33.3; // rear column sockets behind centroid

// Sockets
socket_depth     = 12;    // how deep the peg sits
col_socket_d     = 25;    // column peg diameter — adjust after measuring sourced STL
atlas_socket_d   = 20;    // Atlas peg diameter — adjust after measuring sourced STL
socket_tol       = 0.3;   // friction-fit tolerance (added to socket diameter)

$fn = 80;
// F5 = fast preview  |  F6 = full render before STL export

echo("total_h =", total_h);
echo("top tier w =", base_w - 2 * tier_inset * (tier_count - 1));
echo("socket floor =", total_h - socket_depth);

// ── Geometry ──────────────────────────────────────
base_plate();

module base_plate() {
    difference() {
        crepidoma();
        socket_holes();
    }
}

// Stepped tiers + raised lip fillet at outer edge of each exposed tread
module crepidoma() {
    // Main tier bodies
    for (i = [0 : tier_count - 1]) {
        w = base_w - 2 * tier_inset * i;
        d = base_d - 2 * tier_inset * i;
        z = i * tier_h;
        translate([-w/2, -d/2, z])
            cube([w, d, tier_h]);
    }

    // Lip: raised ridge running around outer perimeter of each tread
    // Sits on top surface of tier i, outside the footprint of tier i+1
    for (i = [0 : tier_count - 2]) {
        w = base_w - 2 * tier_inset * i;
        d = base_d - 2 * tier_inset * i;
        z_tread = (i + 1) * tier_h;  // top surface of tier i
        translate([-w/2, -d/2, z_tread])
        difference() {
            cube([w, d, lip_h]);
            // hollow out interior, leaving only the outer lip_out strip
            translate([lip_out, lip_out, -1])
                cube([w - 2*lip_out, d - 2*lip_out, lip_h + 2]);
        }
    }
}

module socket_holes() {
    // Rear left column
    translate([-rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    // Rear right column
    translate([rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    // Front Atlas
    translate([0, atlas_y_offset, total_h - socket_depth])
        cylinder(d = atlas_socket_d + socket_tol, h = socket_depth + 1);
}
