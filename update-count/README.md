# Update Count

Show the number of pending Arch package updates in the bar. Click to run the
update in a terminal. A Luau port of BukoMoon's v4 plugin for Noctalia v5.

## Plugin

| Field | Value |
| --- | --- |
| ID | `linux-fertxo/update-count` |
| Entries | Bar widget: `updates` |

## Requirements

- **pacman-contrib** for `checkupdates`, or a custom command via settings.
- A terminal emulator (set via the `terminal_cmd` setting; default `foot`).

## Usage

1. Add the **Update Count** widget to your bar.
2. It auto-detects `yay` / `paru` / `pacman` and refreshes on the configured
   interval.
3. Click the widget to run the update in a terminal; middle-click to refresh.

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `update_interval_minutes` | `int` | `30` | Refresh interval in minutes. |
| `terminal_cmd` | `string` | `foot` | Terminal used to run updates. |
| `hide_on_zero` | `bool` | `false` | Hide the widget when there are no updates. |
| `icon_name` | `string` | `world-download` | Widget glyph when updates are pending. |
| `custom_cmd_get_num_updates` | `string` | `""` | Command to count updates (empty = auto-detect). |
| `custom_cmd_do_update` | `string` | `""` | Command to update (empty = auto-detect). |

## IPC

```sh
noctalia msg plugin linux-fertxo/update-count:updates all check
```

## Notes

- Detects `yay`, `paru`, then `pacman`, or uses the custom commands when set.

## Credits

- **Original v4:** BukoMoon (GPLv3)
- **Luau port (v5):** [fertxo](https://github.com/linux-fertxo)
