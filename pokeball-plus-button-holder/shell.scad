// Hollow shell around Pokeball Plus, sliced to a 26mm-wide strip
// Outer: 56mm dia, Inner cavity: 48mm dia (4mm wall)
// Strip width (Y axis): 26mm centered on origin

$fn = 128;

intersection() {
    difference() {
        sphere(d = 56);
        sphere(d = 48);
    }
    cube([60, 26, 60], center = true);
}
