# personal-3d-files

One-off 3D printing projects, mostly OpenSCAD. Each folder is a separate project.

| Folder | What it is | Source |
|---|---|---|
| `a4-with-hole/` | A4 template with a circular hole (SVG/PNG/PDF for printing) | SVG |
| `adaptador-27mm-25mm/` | Pipe bushing, 27 mm OD to 25 mm ID | OpenSCAD |
| `arcade-modulo-engate/` | Cradle and latch for the swappable lever/stickless module of an arcade controller | OpenSCAD |
| `bandeirante-parts/` | Toyota Bandeirante parts: turn-signal lamp holder, grommets, base disc | OpenSCAD |
| `gopro-holder/` | GoPro-to-phone-gimbal adapter with counterweight. **Archived:** the balance revision didn't work out; project abandoned. | OpenSCAD |
| `hotwheels-base/` | Hot Wheels display base | FreeCAD |
| `hotwheels-drift/` | Hot Wheels drift band and cylinder | OpenSCAD |
| `monitor-stands/` | "Atlas" monitor stands: stepped plinth base plate, pedestal, ceiling plate, alignment peg, profile demo. Done: current version printed. | OpenSCAD |
| `pokeball-plus-button-holder/` | Screw clamp that keeps the Pokéball Plus button pressed, with a hollow screw and a straight-step plunger shaft (needs BOSL2) | OpenSCAD |
| `table-supports/` | Table support | OpenSCAD |
| `table-top/` | Table top | OpenSCAD |
| `workshop-tools/` | Saw tooth covers (dozuki, ryoba), dishwasher drain parts, hose coupler, pipe adapter, sink hose clip, toolbox latch, vise screw pad, adjustable scarf joint marking jig | OpenSCAD |
| `docs/` | Design notes and specs (pokeball, gopro) | Markdown |

`makeup-organizer/` moved to [lipe-dev/tray-sure](https://github.com/lipe-dev/tray-sure).

## Conventions

- `<project>/exports/` holds final STL/3MF files and is committed. `<project>/exports/wip/` is local only (ignored).
- `.gcode` / `.gcode.3mf` files are never committed.
- [BOSL2](https://github.com/BelfrySCAD/BOSL2) is not bundled. Install it as an OpenSCAD user library.

## License

Everything here is [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) (see `LICENSE`), **except** `pokeball-plus-button-holder/Screw Generator.scad`. That file is by Jason Koolman ([MakerWorld](https://makerworld.com/en/models/1055250)) and keeps its own license, also CC BY-NC-SA 4.0.
