--!nonstrict
-- HVE v5 — Background Service (genera cachés JSON al iniciar)
local home = noctalia.getenv("HOME") or "/home/fertxo"
local pdir = noctalia.pluginDir() or (home .. "/.config/noctalia/plugins/hyprland-visual-editor")
local cachedir = (noctalia.getenv("XDG_CACHE_HOME") or (home .. "/.cache")) .. "/noctalia/HVE"

-- Generar cachés (fire-and-forget)
noctalia.runAsync("mkdir -p " .. cachedir, nil, 5000)
for _, cat in ipairs({"animations", "borders", "shaders"}) do
  noctalia.runAsync("bash " .. pdir .. "/assets/scripts/scan.sh " .. cat .. " > " .. cachedir .. "/" .. cat .. ".json", nil, 30000)
end
