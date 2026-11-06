# pokeball-plus-button-holder

A screw clamp that keeps the top button of a Pokéball Plus pressed. It has a thumbscrew toggle instead of a snap-fit, so it doesn't creep. Design notes: `../docs/superpowers/specs/2026-04-26-pokeball-plus-button-holder-design.md`.

- `assembly.scad`: full assembly (uses `plunger.scad`)
- `plunger.scad`, `shell.scad`, `ball.scad`: parts and helpers
- `exports/wip/`: local STL/3MF/AMF exports (not committed)

## Dependencies

[BOSL2](https://github.com/BelfrySCAD/BOSL2) 2.0.x, installed as an OpenSCAD user library (on Windows: `Documents\OpenSCAD\libraries\BOSL2`). It is not bundled here.

## Third-party file

`Screw Generator.scad` (v1.5) is by **Jason Koolman** ([@koolm on MakerWorld](https://makerworld.com/en/@koolm)). Source: <https://makerworld.com/en/models/1055250>. It is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) and is included unchanged, with its original header.
