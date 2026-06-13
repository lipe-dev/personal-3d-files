// Base plate — Atlas monitor stand
// Greek crepidoma: 3-tier square stepped platform
// Per-tier profile: base plinth → neck → grooved fascia → crown overhang
// Corners: 45° chamfer on all tiers throughout
// All dimensions in mm

// ── Overall ──────────────────────────────────────
tier_count   = 3;
tier_h       = 20;     // height per tier (total = 60mm)
tier_inset   = 20;     // each tier steps inward this much per side
base_w       = 270;    // bottom tier width
base_d       = 270;    // bottom tier depth
total_h      = tier_count * tier_h;

// ── Per-tier profile ─────────────────────────────
plinth_h     = 4;      // base plinth (wide)
plinth_out   = 7;      // how much plinth protrudes beyond tier body
neck_h       = 3;      // recessed neck — deep shadow at base of fascia
neck_in      = 5;      // neck inset
fascia_h     = tier_h - plinth_h - neck_h - crown_h; // computed below
crown_h      = 5;      // projecting crown lip at top
crown_out    = 6;      // crown protrusion

// ── Corner chamfer ───────────────────────────────
corner_c     = 18;     // 45° cut on all 4 vertical corners of every element

// ── Perimeter groove bands ───────────────────────
groove_h     = 2.0;    // height of each horizontal groove
groove_d     = 2.5;    // depth of groove cut into fascia face
groove_count = 2;      // two grooves dividing fascia into thirds

// ── Sockets ──────────────────────────────────────
rear_span        = 160;
atlas_y_offset   = 66.7;
rear_y_offset    = -33.3;
socket_depth     = 15;
col_socket_d     = 25;    // adjust after measuring sourced column STL
atlas_socket_d   = 20;    // adjust after measuring sourced Atlas STL
socket_tol       = 0.3;

$fn = 80;

echo("total_h =", total_h);
echo("fascia_h =", tier_h - plinth_h - neck_h - crown_h);
echo("top tier w =", base_w - 2 * tier_inset * (tier_count - 1));
echo("socket floor =", total_h - socket_depth);

// ── Geometry ─────────────────────────────────────
base_plate();

module base_plate() {
    difference() {
        union() {
            crepidoma();
        }
        socket_holes();
        groove_cuts();
    }
}

// ─ Chamfered rectangular prism (hull of two cross-rects, centered at origin base) ─
module cbox(w, d, h, c=corner_c) {
    hull() {
        translate([c, 0, 0]) cube([w - 2*c, d, h]);
        translate([0, c, 0]) cube([w, d - 2*c, h]);
    }
}

// ─ Profiled tier: plinth + neck + fascia + crown, all chamfered ─
module profiled_tier(w, d, z) {
    fh = tier_h - plinth_h - neck_h - crown_h;

    pw = w + 2*plinth_out;  pd = d + 2*plinth_out;
    nw = w - 2*neck_in;     nd = d - 2*neck_in;
    cw = w + 2*crown_out;   cd = d + 2*crown_out;

    // Base plinth — wide projecting foot
    translate([-pw/2, -pd/2, z])
        cbox(pw, pd, plinth_h);

    // Neck — recessed band, deep shadow at base of fascia
    translate([-nw/2, -nd/2, z + plinth_h])
        cbox(nw, nd, neck_h);

    // Fascia — main vertical face
    translate([-w/2, -d/2, z + plinth_h + neck_h])
        cbox(w, d, fh);

    // Crown — projecting overhang, throws shadow on tier below
    translate([-cw/2, -cd/2, z + plinth_h + neck_h + fh])
        cbox(cw, cd, crown_h);
}

module crepidoma() {
    for (i = [0 : tier_count - 1]) {
        w = base_w - 2 * tier_inset * i;
        d = base_d - 2 * tier_inset * i;
        profiled_tier(w, d, i * tier_h);
    }
}

// ─ Horizontal groove bands — run full perimeter of each tier's fascia ─
// Two grooves divide each fascia face into thirds, creating banded look
module groove_cuts() {
    for (i = [0 : tier_count - 1]) {
        w = base_w - 2 * tier_inset * i;
        d = base_d - 2 * tier_inset * i;
        fh    = tier_h - plinth_h - neck_h - crown_h;
        z_fas = i * tier_h + plinth_h + neck_h;  // bottom of fascia

        // Two grooves at 1/3 and 2/3 height of fascia
        for (g = [1 : groove_count]) {
            gz = z_fas + fh * g / (groove_count + 1) - groove_h / 2;

            // Frame-shaped cut: outer box minus inner box
            ow = w + 0.2;  od = d + 0.2;
            iw = w - 2*groove_d;  id = d - 2*groove_d;

            translate([-ow/2, -od/2, gz])
            difference() {
                cube([ow, od, groove_h]);
                translate([groove_d, groove_d, -0.1])
                    cube([iw, id, groove_h + 0.2]);
            }
        }
    }
}

module socket_holes() {
    translate([-rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    translate([rear_span/2, rear_y_offset, total_h - socket_depth])
        cylinder(d = col_socket_d + socket_tol, h = socket_depth + 1);

    translate([0, atlas_y_offset, total_h - socket_depth])
        cylinder(d = atlas_socket_d + socket_tol, h = socket_depth + 1);
}
