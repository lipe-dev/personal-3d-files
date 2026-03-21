// Makeup Organizer — Shared Parameters
// All configurable values live here.

/* --- Gridfinity --- */
grid_pitch    = 42;
grid_clear    = 0.5;
grid_h        = 7;
function grid_size(n) = n * grid_pitch - grid_clear;

/* --- Our height unit --- */
F             = 49;    // 1F = 7 × 7mm gridfinity heights

/* --- Slot Configuration --- */
// Each element = one cup slot. Array length = number of cups.
// walls: 1 = individual pocket with divider walls, 0 = open (part of cavity)
// floors: 1 = solid floor, 0 = through hole
slot_walls    = [0, 0];
slot_floors   = [1, 1];

cups_wide     = len(slot_walls);
cup_grid_w    = 2;     // gridfinity units per cup width
cup_grid_d    = 4;     // gridfinity units per tray depth

/* --- Layout --- */
decor_budget  = 5;
wall_t        = 1.2;

/* --- Cup Parameters --- */
cup_w         = grid_size(cup_grid_w) - 2*decor_budget - 2*wall_t;
cup_d         = grid_size(cup_grid_d) - 2*decor_budget - 2*wall_t;
cup_wall      = 2.5;
cup_base_t    = 1.5;

/* --- Tray Parameters --- */
tray_base_t   = 2;
tray_h        = 1 * F;

tray_grid_w   = cups_wide * cup_grid_w;
tray_w        = grid_size(tray_grid_w) - 2*decor_budget;
tray_d        = grid_size(cup_grid_d) - 2*decor_budget;

divider_t     = cups_wide > 1
    ? (tray_w - cups_wide*cup_w - 2*wall_t) / (cups_wide - 1)
    : 0;

/* --- Stacking --- */
stack_ledge_h  = 3;      // height of the base ledge that nests into tray below
stack_inset    = 1.5;    // how much narrower the ledge is (per side)
stack_tol      = 0.3;    // clearance between ledge and lip

/* --- Shape Parameters --- */
puff_max      = 2;
puff_slices   = 30;
round_r       = puff_max + 1;
end_r         = cup_w / 2;

/* --- Wall Profile (Trapezoid) --- */
wall_reach       = puff_max; // how far the wall extends outward from the body edge
wall_h_inner     = tray_h;  // height at inner face (connects to body)
wall_h_outer     = tray_h;  // height at outer edge
wall_r_inner_bot = 0;       // inner face, bottom corner radius
wall_r_inner_top = 0;       // inner face, top corner radius
wall_r_outer_bot = 0;       // outer face, bottom corner radius
wall_r_outer_top = 0;       // outer face, top corner radius

/* --- Decoration Selection --- */
// "none", "columns", "bricks", "honeycomb", "fluting", "weave", "fins"
decoration    = "none";

/* --- Decoration: Columns --- */
col_r         = decor_budget - puff_max; // column radius (max = decor_budget - puff_max)
col_spacing   = 20;     // center-to-center distance between columns
col_margin    = 5;      // top/bottom inset from tray edge

/* --- Decoration: Bricks --- */
brick_h       = 7;      // brick height
brick_len     = 16;     // brick length along perimeter
brick_depth   = 1.2;    // how far bricks protrude outward
brick_gap     = 1.2;    // mortar gap between bricks (3 nozzle widths)
brick_bevel   = 0.8;    // chamfer size on brick edges
brick_margin  = 5;      // top/bottom inset from tray edge

/* --- Decoration: Honeycomb --- */
hex_size      = 8;      // hex cell spacing radius
hex_wall      = 1.2;    // wall thickness between hex cells
hex_depth     = 3;      // how far honeycomb protrudes outside tray wall
hex_margin    = 5;      // top/bottom inset from tray edge
hex_r         = hex_size - hex_wall/2;  // actual hex cut radius
hex_p_sp      = hex_size * 1.8;         // perimeter spacing
hex_h_sp      = hex_size * 1.6;         // vertical row spacing

/* --- Decoration: Fluting --- */
flute_depth   = 3;      // thickness of outer band / groove depth
flute_r       = 3;      // radius of each groove (half-round channel)
flute_spacing = 5;     // center-to-center distance between grooves
flute_margin  = 3;      // top/bottom inset from tray edge

/* --- Decoration: Weave --- */
weave_brick_w = 4;      // brick width (along perimeter)
weave_brick_h = 4;      // brick height (vertical)
weave_depth   = 0.8;    // how far bricks protrude outward
weave_margin  = 3;      // top/bottom inset from tray edge

/* --- Decoration: Fins --- */
fin_margin    = 1;      // top/bottom inset from tray edge
fin_w_outer   = tray_h - 2*fin_margin; // vertical width at wall (wide base of /-\)
fin_w_inner   = fin_w_outer; // vertical width at tip (same as base)
fin_reach     = 5;      // how far the fin sticks out from the wall
fin_t         = 1.6;    // blade thickness along tangent
fin_r_inner_top = 0;    // inner edge (wall) top corner radius
fin_r_inner_bot = 0;    // inner edge (wall) bottom corner radius
fin_r_outer_top = 6;    // outer edge (tip) top corner radius
fin_r_outer_bot = 6;    // outer edge (tip) bottom corner radius
fin_spacing   = fin_t + 2; // center-to-center distance between fins

$fn = 64;
