--!nonstrict
-- HVE v5 — Bar Widget
-- Click: aplica lo pendiente + guarda estado + abre panel
local home = noctalia.getenv("HOME") or "/home/fertxo"
local base = noctalia.pluginDir() or (home .. "/.config/noctalia/plugins/hyprland-visual-editor")
local cacheDir = (noctalia.getenv("XDG_CACHE_HOME") or (home .. "/.cache")) .. "/noctalia/HVE"
local stateFile = cacheDir .. "/hve_state.txt"

barWidget.setGlyph("adjustments-horizontal")
barWidget.setTooltip("Hyprland Visual Editor — click to apply and open")

function onClick()
  local anim = noctalia.state.get("hve_do_anim") or ""
  local border = noctalia.state.get("hve_do_border") or ""
  local shader = noctalia.state.get("hve_do_shader") or ""
  local saveData = noctalia.state.get("hve_save") or ""
  
  -- "" = sin cambios; "none" = desactivar; "archivo" = aplicar
  if anim ~= "" then
    noctalia.runAsync("bash " .. base .. "/assets/scripts/apply_animation.sh " .. anim .. " && hyprctl reload 2>/dev/null", nil, 10000)
    noctalia.state.set("hve_do_anim", "")
  end
  if border ~= "" then
    noctalia.runAsync("bash " .. base .. "/assets/scripts/border.sh " .. border .. " && hyprctl reload 2>/dev/null", nil, 10000)
    noctalia.state.set("hve_do_border", "")
  end
  if shader ~= "" then
    noctalia.runAsync("bash " .. base .. "/assets/scripts/shader.sh " .. shader .. " && hyprctl reload 2>/dev/null", nil, 10000)
    noctalia.state.set("hve_do_shader", "")
  end
  
  if saveData ~= "" then
    noctalia.runAsync("mkdir -p " .. cacheDir .. " && printf '%s' '" .. saveData .. "' > " .. stateFile, nil, 5000)
    noctalia.state.set("hve_save", "")
  end
  
  noctalia.togglePanel("linux-fertxo/hyprland-visual-editor:hve-panel")
end
