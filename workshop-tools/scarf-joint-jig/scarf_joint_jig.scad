// Gabarito AJUSTÁVEL de riscar para emenda "scarf com cunha" (keyed scarf),
// para qualquer altura de viga (~15 a ~36 cm).
//
// Peças: 1 quadro da janela da cunha + 2 blocos iguais (imprima 2x), todos
// impressos; 2 barras chatas de alumínio 1" x 1/8" (25,4 x 3,2 mm) de
// serralheria, que são o trilho. Ferragem: 4 parafusos M4 x 16 cabeça
// chata (escareados) + 4 porcas M4 para prender as barras no quadro; 2
// parafusos borboleta M6 x 50 + 2 porcas M6 para travar os blocos.
// As barras assentam direto na madeira, rentes ao quadro: sem degrau.
//
// Geometria: o quadro segura as duas barras desencontradas pelo degrau da
// janela (5 x 5 cm, cunhas iguais em qualquer viga: 2 de 2,5 x 5). Cada bloco
// desliza numa barra; a face dele é perpendicular à barra (topo de encosto) e
// tem um pino redondo que toca a viga num ponto só.
//
// Uso:
// 1. Paquímetro: segure o gabarito em pé, atravessado na viga (ou na ponta
//    dela), com a viga entre a face do bloco e a aleta do quadro (abaixo da
//    barra). Feche, aperte a borboleta. A rampa fica = H. Faça o mesmo com o
//    outro bloco.
// 2. Deite o gabarito na face da viga, centro do quadro no eixo do apoio, e
//    gire até os dois pinos encostarem: um no topo, outro no fundo da viga.
//    O ângulo da rampa se acerta sozinho para aquela viga.
// 3. Risque pela borda das barras (rampas), pelas faces dos blocos (topos de
//    encosto, a 90 graus da rampa) e por dentro da janela. Mesma coisa na
//    outra peça da viga. Na face de trás, use o jogo espelhado.

/* [Viga para a vista montada] */
H      = 150;    // altura da viga (mm)
/* [Faixa de uso] */
H_max  = 360;    // maior viga que o gabarito alcança (define o corte das barras)
/* [Saída] */
parte  = "montado"; // [montado, quadro, bloco, tudo]
espelhado = false;  // jogo para a face de trás da viga
teste_H = false;     // mostra uma peça de comprimento H na boca do paquímetro

/* [Modo do cálculo] */
modo   = "X=kw";   // [X=kw, angulo fixo, X fixo]
kw_ref = 50;       // janela de referência para o modo "angulo fixo"
X_fixo = 50;       // topo de encosto para o modo "X fixo" (mm)

/* [Janela da cunha] */
kw  = H / 6;          // lado da janela quadrada = espessura das duas cunhas juntas (mm)

/* [Hidden] */
s   = kw / 2;      // meia altura da janela (quadrada)
fw  = 20;          // largura do quadro
bw  = 30;        // largura da barra
bt  = 3.2;         // espessura da barra
tg  = 0.3;         // folga do túnel
T   = 10;          // espessura dos blocos e da garra do quadro
bl  = 44;          // comprimento do bloco ao longo da barra
jaw = 40;          // quanto a mandíbula desce abaixo da barra
pr  = 10;          // raio do pino
pg  = 2;           // folga entre o pino e a face do bloco
H_ref = 250;       // viga em que o "na lata" é exato (nas outras o erro é ~1 mm, ver echo)
// pv (altura do centro do pino acima da linha da rampa) sai do modo escolhido,
// exato na viga H_ref. Rampa = H obriga H = 2·X·cos α + 2·H·sen α +
// kw·(sen α + cos α): com X, kw e α amarrados, o modo diz o que fica fixo.
//   "X=kw"        topo de encosto = janela (o ângulo muda com a janela)
//   "angulo fixo" ângulo da janela de referência kw_ref (X muda com a janela)
//   "X fixo"      topo de encosto = X_fixo (o ângulo muda pouco)
function theta_for_X(kwv, X0) = let(A = X0 - kwv / 2, B = -(kwv / 2 + H_ref), C = H_ref / 2,
    R = norm([A, B]), ph = atan2(B, A), t1 = ph + acos(C / R), t2 = ph - acos(C / R))
    (t1 < 0 && t1 > -80) ? t1 : t2;
function pv_for_theta(kwv, t) = let(u = -(kwv / 2 + H_ref) - pr - pg) (H_ref / 2 + pr - u * sin(t)) / cos(t);
th_alvo = modo == "angulo fixo" ? theta_for_X(kw_ref, kw_ref)
        : modo == "X fixo"      ? theta_for_X(kw, X_fixo)
        :                         theta_for_X(kw, kw);
pv  = pv_for_theta(kw, th_alvo);
function th_of(Hh, pvv) = let(u = -(kw / 2 + Hh) - pr - pg, R = norm([u, pvv]))
    180 - asin((Hh / 2 + pr) / R) - atan2(pvv, u);
ph  = 22;          // quanto o pino passa da face da madeira
clamp = 50;        // comprimento da garra do quadro em cada barra (vigas a partir de ~10 cm)
nutW = 10.2; nutT = 5.4; scr = 6.6;

// eixo da barra A (esquerda/cima): v de -s-bw a -s; barra B = A girada 180 graus
vA0 = -s - bw; vA1 = -s;
bin = fw / 2;      // quanto a barra entra por baixo do quadro (encaixe de alinhamento)
lip = 4;           // aba de alinhamento só no lado que não se risca
notch = 2;         // largura do rasgo do lápis no quadro, na continuação da régua
lip_len = 25;      // quanto a aba do bloco passa da face dele
bar_len = (kw / 2 + H_max + bl + 5) - (kw / 2 + fw) + bin;

// --- 2D ----------------------------------------------------------------------
module ring2d() difference() {
    translate([-kw / 2 - fw, -s - fw]) square([kw + 2 * fw, 2 * s + 2 * fw]);
    translate([-kw / 2, -s]) square([kw, 2 * s]);
}
// garra do quadro na barra A (a da barra B vem da simetria)
module clamp2d() translate([-kw / 2 - fw - clamp, vA0 - lip]) square([clamp + fw, bw + lip]);   // rente à barra no lado de riscar (v = vA1); aba de 4 mm no outro lado
module fin2d() translate([-kw / 2, vA0 - jaw]) square([10, (-s - fw) - (vA0 - jaw) + 1]);   // aleta, abaixo da barra: face esquerda alinhada com a face da janela (mandíbula do paquímetro)
// reforço triangular da aleta, no lado oposto à face de morder
module gusset2d() polygon([[-kw / 2 + 9, vA0 - jaw], [-kw / 2 + 9, -s - fw + 0.5], [kw / 2 + fw, -s - fw + 0.5]]);
module frame2d() {
    ring2d();
    for (k = [0, 1]) rotate(k * 180) { clamp2d(); fin2d(); gusset2d(); }
}
// bloco com a face (direita) em u = 0
module block2d() {
    translate([-bl, vA0 - jaw]) square([bl, (pv + pr + pg) - (vA0 - jaw)]);
    translate([-1, vA0 - lip]) square([lip_len + 1, lip]);   // aba de 4 mm na borda da barra que não se risca, passando da face: guia a barra e encosta a viga na hora de morder
}

// --- 3D ----------------------------------------------------------------------
// A barra assenta direto na madeira (rente ao quadro e aos blocos).
// Quadro: a garra é uma tampa por cima da barra, da mesma largura dela, presa
// por 2 parafusos M4 escareados que entram por baixo da barra (escarear a
// barra) e roscam em porcas presas na tampa. Use a própria garra como guia
// para furar a barra: os furos também alinham a barra com a janela.
m4 = 4.4; m4nut = 7.2; m4nutT = 3.4;
module frame3d() difference() {
    linear_extrude(T) frame2d();
    for (k = [0, 1]) rotate(k * 180) {
        // rasgo para o lápis entrar seguindo a reta da régua, até metade da largura do quadro
        translate([-kw / 2 - fw - 1, vA1, -1]) cube([fw / 2 + 1, notch, T + 2]);
        translate([-kw / 2 - fw - clamp - 1, vA0 - 0.01, -1]) cube([clamp + 1 + bin, bw + 0.02, bt + 1 + tg]);   // a barra entra por baixo e avança bin mm para dentro do quadro
        for (u = [-kw / 2 - fw - clamp * 0.25, -kw / 2 - fw - clamp * 0.75]) translate([u, vA0 + bw / 2, 0]) {
            cylinder(d = m4, h = T + 1, $fn = 24);
            translate([0, 0, T - m4nutT]) cylinder(d = m4nut / cos(30), h = m4nutT + 1, $fn = 6);
        }
    }
}
// Bloco: túnel aberto para o lado da madeira, com paredes dos dois lados da
// barra; a borboleta M6 entra pela ponta de baixo (mandíbula) e aperta a
// borda de baixo da barra contra a parede de cima: trava fora da viga também.
module block3d() difference() {
    union() {
        linear_extrude(T) block2d();
        translate([-pr - pg, pv, -ph]) cylinder(r = pr, h = ph + T, $fn = 64);   // pino de contato (passa da face da madeira)
    }
    translate([-bl - 1, vA0 - tg, -1]) cube([bl + 2, bw + 2 * tg, bt + tg + 1]);
    translate([-bl / 2, vA0 - jaw - 1, bt / 2 + 1.4]) rotate([-90, 0, 0]) cylinder(d = scr, h = jaw + 2, $fn = 24);
    translate([-bl / 2 - nutW / 2, vA0 - jaw / 2 - nutT / 2, -1]) cube([nutW, nutT, bt / 2 + 1.4 + nutW / 2 + 1]);   // porca M6 entra por baixo
}
module mir() if (espelhado) mirror([1, 0, 0]) children(); else children();

// --- montagem na viga: resolve o ângulo pelos pinos ------------------------------
uf = -(kw / 2 + H);                 // face do bloco A: rampa = H
Pt = [uf - pr - pg, pv];             // centro do pino A (o do bloco B é -Pt)
R  = norm(Pt);
be = atan2(Pt[1], Pt[0]);
th = 180 - asin((H / 2 + pr) / R) - be;   // ângulo da barra (negativo: desce para a direita)
// topo de encosto: onde a face do bloco (u = uf) cruza o topo da viga
Xb = ((H / 2) - (uf * sin(th) + (-s) * cos(th))) / cos(th);
Lt = 2 * ((H / 2) * 0 + abs(uf) * cos(th) + Xb * abs(sin(th)));   // comprimento aproximado da emenda no topo

module montado() {
    rotate([90, 0, 0]) {   // plano x-z = face da viga
        %translate([-700, -H / 2, -80]) cube([1400, H, 80]);   // viga (centro do quadro na meia altura, no eixo do apoio x = 0)
        rotate(th) mir() {
            color("Gold") frame3d();
            color("SteelBlue") translate([uf, 0, 0]) block3d();
            color("SteelBlue") rotate(180) translate([uf, 0, 0]) block3d();
            // peça de teste de comprimento H na boca do paquímetro (entre a face do bloco e a aleta do quadro)
            if (teste_H) for (k = [0, 1]) rotate(k * 180) color("Red", 0.8) translate([uf, vA0 - jaw + 2, T]) cube([H, jaw - 6, 6]);
            for (k = [0, 1]) rotate(k * 180) color("Silver") translate([-kw / 2 - fw + bin - bar_len, vA0, 0]) cube([bar_len, bw, bt]);
        }
    }
}

if (parte == "montado") montado();
if (parte == "quadro" || parte == "tudo") mir() rotate([180, 0, 0]) translate([0, 0, -T]) frame3d();   // imprime de cabeça para baixo
if (parte == "bloco" || parte == "tudo") mir() translate([0, parte == "tudo" ? 150 : 0, 0]) rotate([180, 0, 0]) translate([0, 0, -T]) block3d();

echo(str("pv calculado = ", round(pv * 100) / 100, " mm; viga H = ", H, ": rampa ", round(-th * 10) / 10, " graus, topo de encosto ~", round(Xb), " mm, janela ", kw, " x ", 2 * s, "; barras de alumínio 1\" x 1/8\" cortadas com ", round(bar_len), " mm (2 peças)"));
