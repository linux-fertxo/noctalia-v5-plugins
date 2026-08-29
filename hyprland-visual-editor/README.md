# Hyprland Visual Editor

Visually edit Hyprland animations, borders, shaders and geometry from a Noctalia
panel, without ever touching your `hyprland.lua`. A Luau port of XimoCP's v4
plugin for Noctalia v5.

## Plugin

| Field | Value |
| --- | --- |
| ID | `linux-fertxo/hyprland-visual-editor` |
| Entries | Bar widget: `hve-trigger` · panel: `hve-panel` · service: `hve-scanner` |

## Requirements

- **Hyprland** running a Lua config (`hyprland.lua`).
- **bash** and **python3** on `PATH` (the preset converter and assembler are
  shell scripts that call `python3`).

## Usage

1. Add the **Hyprland Visual Editor** widget to your bar.
2. Add this line at the very end of `~/.config/hypr/hyprland.lua`:
   ```lua
   pcall(function() dofile(os.getenv("HOME") .. "/.cache/noctalia/HVE/overlay.lua") end)
   ```
3. Click the bar widget to open the panel. Pick a preset (Animations, Borders or
   Effects), press **Select**, then click the bar widget again to apply. HVE
   regenerates the overlay and reloads Hyprland for you.

The panel can also be toggled directly:

```sh
noctalia msg panel-toggle linux-fertxo/hyprland-visual-editor:hve-panel
```

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `is_system_active` | `bool` | `false` | Master switch that enables effects. |
| `active_anim_file` | `string` | `""` | Currently active animation preset. |
| `active_border_file` | `string` | `""` | Currently active border preset. |
| `active_shader_file` | `string` | `""` | Currently active shader preset. |

## IPC

```sh
noctalia msg panel-toggle linux-fertxo/hyprland-visual-editor:hve-panel
```

## Notes

- HVE writes its generated overlay to `~/.cache/noctalia/HVE/overlay.lua` and
  reloads Hyprland with `hyprctl reload` after every apply. Your `hyprland.lua`
  is never modified.
- Ships 18 animation presets, 13 border presets and 9 GLSL shaders. Add your own
  by dropping a `.conf`/`.frag` into the matching `assets/` folder with the
  `@Title` / `@Desc` / `@Icon` / `@Color` / `@Tag` metadata header.
- Shaders are applied as absolute-path `screen_shader` entries; re-apply the
  shader after moving the plugin directory.

## Credits

- **Architecture & core:** XimoCP (Noctalia v4, QML)
- **Luau port (v5):** [fertxo](https://github.com/linux-fertxo)
