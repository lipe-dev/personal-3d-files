// Plunger screw + matching nut (M12 coarse)
// Uses BOSL2

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = 96;

screw_length = 30;

// Screw: M12 socket head, full thread
translate([-15, 0, 0])
    screw("M12", head = "socket", drive = "hex",
          length = screw_length, thread = "coarse",
          anchor = BOTTOM);

// Matching M12 hex nut
translate([15, 0, 0])
    nut("M12", thickness = "DIN", thread = "coarse",
        anchor = BOTTOM);
