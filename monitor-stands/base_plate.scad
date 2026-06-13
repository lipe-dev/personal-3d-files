// Base plate — Atlas monitor stand
// Greek crepidoma: 3-tier square stepped platform
// Each tier has: base plinth → inset neck → main fascia → crown overhang
// All dimensions in mm

// Overall geometry
tier_count   = 3;
tier_h       = 14;    // total height per tier
tier_inset   = 18;    // each tier steps inward by this much on each side
base_w       = 260;   // bottom tier width
base_d       = 260;   // bottom tier depth
total_h      = tier_count * tier_h;  // 42mm total

// Per-tier profile
plinth_out   = 6;     // base plinth protrusion beyond tier width
plinth_h     = 4;     // base plinth height
neck_in      = 4;     // neck inset (narrower than main body)
neck_h       = 3;     // neck height — creates deep shadow line at base of each tier
fascia_h     = tier_h - plinth_h - neck_h - crown_h;  // main vertical face
crown_out    = 5;     // crown overhang beyond tier width
crown_h      = 4;     // crown height — projecting lip at top of each tier

// Triangle socket positions (relative to plate center = triangle centroid)
rear_span        = 160;
atlas_y_offset   = 66.7;
rear_y_offset    = -33.3;

// Sockets
socket_depth     = 12;
col_socket_d     = 25;    // adjust after measuring sourced column STL
atlas_socket_d   = 20;    // adjust after measuring sourced Atlas STL
socket_tol       = 0.3;   // friction-fit tolerance

$fn = 80;

echo("total_h =", total_h);
echo("fascia_h =", tier_h - plinth_h - neck_h - crown_h);
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

module crepidoma() {
    for (i = [0 : tier_count - 1]) {
        w = base_w - 2 * tier_inset * i;
        d = base_d - 2 * tier_inset * i;
        z = i * tier_h;
        profiled_tier(w, d, z);
    }
}

// Each tier: plinth → neck → fascia → crown
// Creates 3 distinct shadow lines per tier for rich classical depth
module profiled_tier(w, d, z) {
    fh = tier_h - plinth_h - neck_h - crown_h;  // fascia height

    // Base plinth — wide projecting foot
    translate([-(w/2 + plinth_out), -(d/2 + plinth_out), z])
        cube([w + 2*plinth_out, d + 2*plinth_out, plinth_h]);

    // Neck — recessed band, creates deep shadow at base of fascia
    translate([-(w/2 - neck_in), -(d/2 - neck_in), z + plinth_h])
        cube([w - 2*neck_in, d - 2*neck_in, neck_h]);

    // Main fascia — vertical face, primary visible surface of tier
    translate([-w/2, -d/2, z + plinth_h + neck_h])
        cube([w, d, fh]);

    // Crown — projecting overhang at top, throws shadow on tier below
    translate([-(w/2 + crown_out), -(d/2 + crown_out), z + plinth_h + neck_h + fh])
        cube([w + 2*crown_out, d + 2*crown_out, crown_h]);
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
