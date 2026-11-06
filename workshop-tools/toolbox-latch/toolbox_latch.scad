// Toolbox latch: strap with a snap hook on the lid bar and a J hook on the box bar.
// The lid hook snaps onto the lid bar and stays there as the pivot;
// the J hook's lip springs over the box bar to close the lid.
// Print lying flat (as shown) - the layers follow the hooks, so they flex without cracking.

bars_outside = 39.42;  // across both bars, outside edge to outside edge, lid shut
lid_bar_d    = 4.62;   // diameter of the lid bar
box_bar_d    = 3.3;    // diameter of the box bar
bar_spacing  = bars_outside - lid_bar_d/2 - box_bar_d/2;   // centre to centre
clearance    = 0.3;    // hook bore is this much bigger than the bar
wall         = 3;      // hook and strap thickness
width        = 70;     // latch width, side to side (along the bars)

pivot_open   = 0.75;   // lid hook opening as a fraction of the bar (tight, stays on)
j_wrap       = 50;     // how far the J's lip curls behind the box bar, in degrees past
                       // straight down (more = holds tighter, harder to open)
lead_in      = 1.0;    // chamfer on the lid hook mouth so it pushes on easier
// notches in the lid hook for the two mounts that hold the lid bar
notch_gap      = 23;    // between the notches, inner edge to inner edge
notch_w        = 3;     // width of each notch

// pull lip past the box hook, angled away from the toolbox so a finger fits under it
lip_len      = 15;     // how far the lip reaches past the box hook
lip_angle    = 25;     // tilt away from the toolbox
lip_t        = 3.5;    // lip thickness
grip_bumps   = 4;      // ridges along the top of the lip
grip_bump_d  = 1.6;
$fn = 96;

function r_in(d)  = (d + clearance) / 2;
function r_out(d) = r_in(d) + wall;

c1 = r_out(lid_bar_d);                  // lid hook centre
c2 = c1 + bar_spacing;                  // box hook centre
strap_top = max(r_out(lid_bar_d), r_out(box_bar_d));

// bore and mouth of a hook around a bar centred at x = cx, opening facing -y (toward the toolbox)
module hook_cut(cx, d, open_frac) {
    w = d * open_frac;
    ri = r_in(d);
    ro = r_out(d);
    translate([cx, 0]) circle(r = ri);
    translate([cx - w/2, -ro - 1]) square([w, ro + 1]);
    // lead-in chamfer at the mouth
    polygon([[cx - w/2, -ri + 0.5], [cx - w/2 - lead_in, -ro - 0.01],
             [cx + w/2 + lead_in, -ro - 0.01], [cx + w/2, -ri + 0.5]]);
}

// J hook around the box bar: wraps from the strap, round the far side of the bar,
// and ends in a lip behind it; the side toward the lid hook is open
module j_hook() {
    ri = r_in(box_bar_d);
    ro = r_out(box_bar_d);
    rm = (ri + ro) / 2;
    R  = 2 * ro;
    difference() {
        translate([c2, 0]) circle(r = ro);
        translate([c2, 0]) circle(r = ri);
        // remove everything outside the arc from straight up (strap) round to the lip
        translate([c2, 0])
            polygon(concat([[0, 0]],
                           [for (a = [90 : 10 : 360 - j_wrap]) [R * cos(a), R * sin(a)]],
                           [[R * cos(-j_wrap), R * sin(-j_wrap)]]));
    }
    // rounded lip tip so the bar slides over it
    translate([c2 + rm * cos(-j_wrap), rm * sin(-j_wrap)]) circle(d = wall);
}

module pull_lip() {
    p0  = [c2, strap_top - lip_t/2];
    dir = [cos(lip_angle), sin(lip_angle)];
    p1  = p0 + (r_out(box_bar_d) + lip_len) * dir;
    up  = [-dir[1], dir[0]];               // normal pointing away from the toolbox
    hull() {
        translate(p0) circle(d = lip_t);
        translate(p1) circle(d = lip_t);
    }
    // grip ridges spread along the outer half of the lip
    for (i = [0 : grip_bumps - 1])
        translate(p0 + (r_out(box_bar_d) + lip_len * (0.3 + 0.6 * i / max(grip_bumps - 1, 1))) * dir
                     + lip_t/2 * up)
            circle(d = grip_bump_d);
}

module profile() {
    difference() {
        union() {
            translate([c1, 0]) circle(r = r_out(lid_bar_d));
            // strap joining the outer sides of the hooks
            translate([c1, strap_top - wall]) square([c2 - c1, wall]);
            pull_lip();
        }
        hook_cut(c1, lid_bar_d, pivot_open);
    }
    j_hook();
}

difference() {
    linear_extrude(height = width) profile();
    // cut the lid hook right through at each mount, centred across the width
    for (s = [-1, 1])
        translate([c1 - r_out(lid_bar_d) - 1,
                   -r_out(lid_bar_d) - 1,
                   width/2 + s * (notch_gap/2 + notch_w/2) - notch_w/2])
            cube([2*r_out(lid_bar_d) + 1.5, strap_top + r_out(lid_bar_d) + 2, notch_w]);
}
