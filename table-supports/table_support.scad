// Table support blocks — 3 variants
// Fits under table edge, prints along Bambu Lab A1 bed

length     = 150;  // 15cm
width      = 40;   // 4cm
hole_d     = 3;    // pilot hole for ~4mm wood screw — threads grip plastic
hole_gap   = 35;   // center-to-center spacing
hole_count = 3;

module support(h) {
    difference() {
        cube([length, width, h]);
        for (i = [0 : hole_count - 1]) {
            x = length/2 + (i - (hole_count-1)/2) * hole_gap;
            translate([x, width/2, -1])
                cylinder(h = h + 2, d = hole_d, $fn = 32);
        }
    }
}

// two identical 21.5mm pieces, spaced apart in Y
support(21.5);
translate([0, width + 10, 0]) support(21.5);

// two beams: 30x15mm cross-section, 40mm long, 110mm apart center-to-center
beam_w      = 30;
beam_h      = 15;
beam_len    = 40;
beam_gap    = 130;  // 115mm face-to-face + 15mm beam width

module beam() {
    cube([beam_h, beam_len, beam_w]);
}

channel_floor = 2;                                    // floor under beams
channel_top   = 3;                                    // wall above beams
channel_ext   = 40;                                   // end flap length for screwing down
channel_x     = beam_gap + beam_h + channel_ext * 2; // 185mm
channel_y     = 30;                                   // 3cm deep
channel_z     = channel_floor + beam_w + channel_top; // 35mm — fully enclosed

module channel_piece() {
    difference() {
        cube([channel_x, channel_y, channel_z]);

        // beam tunnels — enclosed, open front/back
        translate([channel_ext, -1, channel_floor])
            cube([beam_h, channel_y + 2, beam_w]);
        translate([channel_ext + beam_gap, -1, channel_floor])
            cube([beam_h, channel_y + 2, beam_w]);

        channel_wall = 5; // wall thickness around each beam tunnel

        // cut down left flat (_)
        translate([-1, -1, channel_floor])
            cube([channel_ext - channel_wall + 1, channel_y + 2, channel_z]);
        // cut down middle flat (___)
        translate([channel_ext + beam_h + channel_wall, -1, channel_floor])
            cube([beam_gap - beam_h - channel_wall * 2, channel_y + 2, channel_z]);
        // cut down right flat (_)
        translate([channel_ext + beam_gap + beam_h + channel_wall, -1, channel_floor])
            cube([channel_ext - channel_wall + 1, channel_y + 2, channel_z]);

        // screw holes through each platform floor
        translate([channel_ext / 2, channel_y / 2, -1])
            cylinder(h = channel_floor + 2, d = hole_d, $fn = 32);
        translate([channel_ext + beam_h + (beam_gap - beam_h) / 2, channel_y / 2, -1])
            cylinder(h = channel_floor + 2, d = hole_d, $fn = 32);
        translate([channel_ext + beam_gap + beam_h + channel_ext / 2, channel_y / 2, -1])
            cylinder(h = channel_floor + 2, d = hole_d, $fn = 32);
    }
}

channel_y_offset = (width + 10) * 2 + 20;
translate([0, channel_y_offset, 0]) channel_piece();
