// Adaptador de cano - bucha 27mm (externo) / 25mm (interno)

folga_externa = 0;  // quanto reduzir do diametro externo (27mm)
folga_interna = 0;  // quanto aumentar do diametro interno (25.1mm)

diametro_externo = 27 - folga_externa;
diametro_interno = 25.1 + folga_interna;
alturas = [18.64, 34];
chanfro = 1;        // chanfro nas bordas, 0 pra desativar
$fn = 100;

module adaptador(comprimento) {
    difference() {
        cylinder(h = comprimento, d = diametro_externo, center = false);
        translate([0, 0, -0.5])
            cylinder(h = comprimento + 1, d = diametro_interno, center = false);
    }
}

module chanfrado(comprimento) {
    if (chanfro > 0) {
        difference() {
            adaptador(comprimento);
            // chanfro na borda superior
            translate([0, 0, comprimento - chanfro])
                cylinder(h = chanfro + 0.5, d1 = diametro_externo, d2 = diametro_externo + chanfro * 2, center = false);
            // chanfro na borda inferior
            translate([0, 0, -0.5])
                cylinder(h = chanfro + 0.5, d1 = diametro_externo + chanfro * 2, d2 = diametro_externo, center = false);
        }
    } else {
        adaptador(comprimento);
    }
}

espacamento = diametro_externo + 10;

for (i = [0 : len(alturas) - 1]) {
    translate([i * espacamento, 0, 0])
        chanfrado(alturas[i]);
}
