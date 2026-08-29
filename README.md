# noctalia-v5-plugins

Plugins for **Noctalia v5** (Luau) — ports from the v4 (QML) ecosystem and
original work.

## Plugins

| Plugin | Description | Status |
|--------|-------------|--------|
| [hyprland-visual-editor](./hyprland-visual-editor/) | Visually edit Hyprland animations, borders, shaders and geometry | ✅ v5 Luau port |
| [update-count](./update-count/) | Show pending Arch package updates in the bar | ✅ v5 Luau port |

## Install

Add this repo as a source, then enable a plugin:

```sh
noctalia msg plugins source add linux-fertxo git https://github.com/linux-fertxo/noctalia-v5-plugins
noctalia msg plugins enable linux-fertxo/hyprland-visual-editor
```

## Credits

Based on the original work of [XimoCP](https://github.com/noctalia-dev)
(Hyprland Visual Editor) and BukoMoon (Update Count), ported to Luau for
Noctalia v5 by [fertxo](https://github.com/linux-fertxo).
