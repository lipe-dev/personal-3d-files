// Grommet for truck body hole - Bandeirante
// Two-piece: inner tube with flange + cap that glues on the other side

/* --- Parameters --- */
hole_d     = 11;    // body hole diameter
panel_t    = 0.5;   // panel thickness
wall_t     = 1.5;   // tube wall thickness
clearance  = 0.3;   // fit clearance
wire_d     = hole_d - clearance - wall_t * 2;  // maximize wire passage
flange_d   = 15;    // flange (stop) diameter
flange_t   = 1.5;   // flange thickness
tube_h     = 5;     // tube height beyond flange

tube_od = hole_d - clearance;

// Cap parameters
cap_d  = flange_d;
cap_t  = 1.5;       // cap thickness
cap_lip = 4.3;  // socket depth matches panel thickness

/* --- Part 1: Inner tube with flange --- */
module inner_tube() {
    difference() {
        union() {
            // Flange
            cylinder(h=flange_t, d=flange_d, $fn=64);
            // Tube
            translate([0, 0, flange_t])
                cylinder(h=tube_h, d=tube_od, $fn=64);
        }
        // Wire hole
        translate([0, 0, -1])
            cylinder(h=flange_t + tube_h + 2, d=wire_d, $fn=32);
    }
}

/* --- Part 2: Cap (glues on the other side) --- */
module cap() {
    difference() {
        union() {
            // Flat cap
            cylinder(h=cap_t, d=cap_d, $fn=64);
            // Socket that slides over the tube end
            translate([0, 0, cap_t])
                cylinder(h=cap_lip, d=tube_od + wall_t * 2, $fn=64);
        }
        // Socket bore (fits snug over tube)
        translate([0, 0, cap_t])
            cylinder(h=cap_lip + 1, d=tube_od + clearance, $fn=64);
        // Wire hole
        translate([0, 0, -1])
            cylinder(h=cap_t + cap_lip + 2, d=wire_d, $fn=32);
    }
}

/* --- Layout for printing --- */
inner_tube();

translate([flange_d + 5, 0, 0])
    cap();
