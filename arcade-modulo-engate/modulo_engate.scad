// Engate do modulo trocavel (alavanca <-> stickless) do controle final.
// Berco fica parafusado embaixo do tampo do controle. 4 pinos de aco de 10 mm
// sobem do berco; o modulo desce neles de cima pra baixo e os imas seguram no fundo.
// Pra tirar: dedo pelo furo no fundo do stick, empurra o ressalto embaixo do modulo.
// So 2 furos (na diagonal) sao justos; os outros 2 tem folga pra 4 pinos nao travarem.
// O pogo de 12 pinos fica pre-carregado quando o modulo encosta no apoio.
// z = 0 e a face de cima do tampo; tudo desce a partir dai.
// Pra imprimir: escolha a peca em `part` (ja sai virada pra mesa).

part = "explodida";   // "montagem", "explodida", "berco", "modulo_stickless", "modulo_alavanca"

// --- modulo ---
mod_w     = 210;    // largura (x)
mod_d     = 160;    // profundidade (y)
corner_r  = 8;
tp        = 4;      // espessura do tampo do modulo (= tampo do controle, fica faceado)
skirt_h   = 16;     // saia que desce dentro do berco
rim_w     = 18;     // largura da borda que apoia no berco (pinos, imas, pogo)
lead      = 1.5;    // chanfro de entrada (modulo e berco)
fit       = 0.4;    // folga lateral na cavidade: quem centraliza sao os pinos

// --- berco ---
case_tp   = tp;     // espessura do tampo do controle
ledge_t   = 12;     // apoio onde o modulo senta (segura o pino prensado)
wall      = 4;      // parede do berco em volta da cavidade
flange    = 12;     // aba que parafusa embaixo do tampo
flange_t  = 5;
mount_d   = 3.4;    // parafusos M3 de baixo pro tampo
mount_cb  = 6.5;

// --- pinos-guia ---
pin_d       = 10;    // pino de aco retificado 10x30
pin_len     = 30;
pin_press   = 0.1;   // interferencia no berco (furo = d - isso)
pin_tight   = 0.1;   // furo justo no modulo (d + isso); ajuste com alargador
pin_loose   = 0.5;   // furo com folga no modulo (d + isso)
pin_up      = pin_len - ledge_t;   // quanto sobe acima do apoio

// --- imas ---
mag_d     = 12;      // neodimio 12x3; teste a forca antes (ver echo)
mag_t     = 3;

// --- pogo 12 pinos (2,54 mm) ---
pogo_n       = 12;
pogo_pitch   = 2.54;
pogo_w       = 5;    // largura do corpo da barra
pogo_free    = 1.5;  // quanto a ponta do pino sobe acima do apoio, solto
pogo_travel  = 1.2;  // curso total da mola
pad_t        = 1.6;  // placa com os pads, colada no modulo
pogo_len     = pogo_n * pogo_pitch + 3;
pad_recess   = pogo_free - pogo_travel / 2;   // pads ficam aqui acima do apoio -> mola na metade

// --- extracao ---
push_at     = [10, -22];   // ponto de empurrar: perto do centro, entre os botoes
push_d      = 16;          // ressalto embaixo do modulo stickless
case_depth  = 70;          // altura interna do stick (tampo ate o fundo) - so pra visualizar
finger_hole = 24;          // furo no fundo do stick

// --- botoes ---
btn_hole  = 30.2;   // Sanwa OBSC-30 snap-in
btn_cb    = 36;     // rebaixo por baixo: lugar pro anel de LED 32 mm
btn_lip   = 1.8;    // espessura que sobra pro snap-in travar
// cluster stickless (centro do modulo = 0,0). Ajuste pra sua mao.
btn_pos = [
    [-66, -24],   // mindinho
    [-34,   4],   // esquerda
    [  2,   8],   // baixo
    [ 37,   0],   // direita
    [ 20,  41],   // extra de cima
    [-16, -32],   // extra de baixo
    [ 40, -36],   // cima (polegar)
];

// --- alavanca JLF ---
lever_pos   = [0, 0];
lever_hole  = 24;               // o guarda-po JLF-CD cobre
// MEDIR NA SUA JLF antes de imprimir: furacao da base (4x M4 escareado)
lever_screws = [[-41.5, -20], [41.5, -20], [-41.5, 20], [41.5, 20]];

$fn = 64;

// posicoes na linha de centro da borda
xr = mod_w / 2 - rim_w / 2;
yr = mod_d / 2 - rim_w / 2;
// um pino deslocado: o modulo so entra de um jeito (o pogo nao inverte)
pins_tight = [[-xr, yr], [xr, -yr]];
pins_loose = [[xr, yr], [-xr + 20, -yr]];
pins   = concat(pins_tight, pins_loose);
mags   = [[-50, yr], [50, yr], [-50, -yr], [50, -yr]];
pogo_at = [0, -yr];

H  = tp + skirt_h;         // altura do modulo
zl = -H;                   // topo do apoio do berco = base do modulo
zb = zl - ledge_t;         // fundo do berco
zt = -case_tp;             // topo do berco (encosta embaixo do tampo)

echo(str("Compressao do pogo: ", pogo_free - pad_recess, " mm de ", pogo_travel, " mm"));
echo(str("Pino sobe ", pin_up, " mm; topo fica ", H - pin_up, " mm abaixo do tampo"));
echo("Imas: 4x 12x3 N35 da ~8 kg somados no contato. Se o dedo nao vencer, troque por 10x3.");

assert(pin_up < H, "pino passaria do tampo do modulo");

module rrect(w, d, r) offset(r = r) square([w - 2*r, d - 2*r], center = true);

module slab(w, d, r, z, h = 0.01) translate([0, 0, z]) linear_extrude(h) rrect(w, d, r);

module at(list) for (p = list) translate([p[0], p[1], 0]) children();

// furo do pino no modulo: passante, com boca chanfrada embaixo
module pin_hole(d) {
    translate([0, 0, -H - 1]) cylinder(d = d, h = H + 2);
    translate([0, 0, -H - 0.01]) cylinder(d1 = d + 2.5, d2 = d, h = 1.25);
}

module modulo(layout) {
    inner_w = mod_w - 2*rim_w;
    inner_d = mod_d - 2*rim_w;
    difference() {
        union() {
            difference() {
                // casca externa com chanfro de entrada embaixo
                hull() {
                    slab(mod_w - 2*lead, mod_d - 2*lead, corner_r - lead, -H);
                    slab(mod_w, mod_d, corner_r, -H + lead);
                    slab(mod_w, mod_d, corner_r, -0.01);
                }
                // oco por baixo do tampo
                translate([0, 0, -H - 1]) linear_extrude(skirt_h + 1) rrect(inner_w, inner_d, 3);
            }
            // ressalto pra empurrar com o dedo (a alavanca sai puxando a bola)
            if (layout == "stickless")
                translate([push_at[0], push_at[1], -H]) cylinder(d = push_d, h = skirt_h + 0.01);
        }
        at(pins_tight) pin_hole(pin_d + pin_tight);
        at(pins_loose) pin_hole(pin_d + pin_loose);
        at(mags) translate([0, 0, -H - 0.01]) cylinder(d = mag_d + 0.2, h = mag_t + 0.2);
        // placa dos pads do pogo
        translate([pogo_at[0], pogo_at[1], -H - 0.01])
            linear_extrude(pad_recess + pad_t)
                square([pogo_len + 0.4, pogo_w + 4], center = true);

        if (layout == "stickless")
            at(btn_pos) {
                translate([0, 0, -tp - 1]) cylinder(d = btn_hole, h = tp + 2);
                translate([0, 0, -tp - 1]) cylinder(d = btn_cb, h = tp - btn_lip + 1);
            }
        if (layout == "alavanca")
            translate([lever_pos[0], lever_pos[1], 0]) {
                translate([0, 0, -tp - 1]) cylinder(d = lever_hole, h = tp + 2);
                at(lever_screws) {
                    translate([0, 0, -tp - 1]) cylinder(d = 4.3, h = tp + 2);
                    translate([0, 0, -2.2]) cylinder(d1 = 4.3, d2 = 8.6, h = 2.21);
                }
            }
    }
}

module berco() {
    difference() {
        union() {
            translate([0, 0, zt - flange_t])
                linear_extrude(flange_t) rrect(mod_w + 2*flange, mod_d + 2*flange, corner_r + flange);
            translate([0, 0, zb])
                linear_extrude(zt - zb) rrect(mod_w + 2*(fit + wall), mod_d + 2*(fit + wall), corner_r + wall);
        }
        // cavidade, com chanfro na boca
        translate([0, 0, zl]) linear_extrude(zt - zl + 1) rrect(mod_w + 2*fit, mod_d + 2*fit, corner_r + fit);
        hull() {
            slab(mod_w + 2*fit, mod_d + 2*fit, corner_r + fit, zt - lead);
            slab(mod_w + 2*(fit + lead), mod_d + 2*(fit + lead), corner_r + fit + lead, zt);
        }
        // vao central: botoes, alavanca e o dedo passam
        translate([0, 0, zb - 1]) linear_extrude(ledge_t + 2) rrect(mod_w - 2*rim_w, mod_d - 2*rim_w, 3);
        // pinos prensados (passante pra poder sacar com punção)
        at(pins) translate([0, 0, zb - 1]) cylinder(d = pin_d - pin_press, h = ledge_t + 2);
        at(mags) translate([0, 0, zl - mag_t - 0.2]) cylinder(d = mag_d + 0.2, h = mag_t + 0.21);
        // janela da barra de pogo (cola/parafusa por baixo)
        translate([pogo_at[0], pogo_at[1], zb - 1])
            linear_extrude(ledge_t + 2) square([pogo_len + 0.4, pogo_w + 0.4], center = true);
        // fixacao no tampo: M3 de baixo, cabeca rebaixada
        fx = mod_w / 2 + fit + wall + (flange - wall) / 2;
        fy = mod_d / 2 + fit + wall + (flange - wall) / 2;
        at([[-fx, -fy], [fx, -fy], [-fx, fy], [fx, fy], [0, -fy], [0, fy], [-fx, 0], [fx, 0]]) {
            translate([0, 0, zb - 1]) cylinder(d = mount_d, h = zt - zb + 2);
            translate([0, 0, zb - 1]) cylinder(d = mount_cb, h = zt - flange_t - zb + 1);
        }
    }
}

// pecas compradas, so pra visualizar
module ferragens() {
    color("silver") at(pins) translate([0, 0, zb]) {
        cylinder(d = pin_d, h = pin_len - 1);
        translate([0, 0, pin_len - 1]) cylinder(d1 = pin_d, d2 = pin_d - 2, h = 1);
    }
    color("dimgray") at(mags) translate([0, 0, zl - mag_t]) cylinder(d = mag_d, h = mag_t);
    color("gold") translate([pogo_at[0], pogo_at[1], 0])
        for (i = [0 : pogo_n - 1])
            translate([(i - (pogo_n - 1) / 2) * pogo_pitch, 0, zl - 4])
                cylinder(d = 1.2, h = 4 + pogo_free);
    color("darkgreen") translate([pogo_at[0], pogo_at[1], zb])
        linear_extrude(ledge_t - 4 + 0.01) square([pogo_len, pogo_w], center = true);
}

module tampo_fantasma() {
    %translate([0, 0, -case_tp]) linear_extrude(case_tp) difference() {
        rrect(mod_w + 120, mod_d + 100, 12);
        rrect(mod_w + 2*fit, mod_d + 2*fit, corner_r + fit);
    }
    // fundo do stick com o furo do dedo
    %translate([0, 0, -case_depth - 3]) linear_extrude(3) difference() {
        rrect(mod_w + 120, mod_d + 100, 12);
        translate(push_at) circle(d = finger_hole);
    }
}

if (part == "montagem") {
    tampo_fantasma();
    color("orange") berco();
    color("dimgray", 0.9) modulo("stickless");
    ferragens();
}
if (part == "explodida") {
    lift = 70;
    tampo_fantasma();
    color("orange") berco();
    ferragens();
    color("dimgray", 0.9) translate([0, 0, lift]) modulo("stickless");
    color("steelblue", 0.9) translate([0, mod_d + 60, lift]) modulo("alavanca");
}
if (part == "berco")            rotate([180, 0, 0]) translate([0, 0, -zt]) berco();
if (part == "modulo_stickless") rotate([180, 0, 0]) modulo("stickless");
if (part == "modulo_alavanca")  rotate([180, 0, 0]) modulo("alavanca");
