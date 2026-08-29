--!nonstrict
-- Update Count v5 — Bar Widget
-- Port del original de BukoMoon (v4 QML) a Luau para Noctalia v5
-- Muestra icono + número de updates. Click → actualizar.

local updateCount = 0
local loading = false
local currentUpdater = nil

-- ─── Updaters (en orden de preferencia) ──────────────────────────────────
local updaters = {
  { name = "yay",   check = "command -v checkupdates >/dev/null 2>&1 && command -v yay >/dev/null 2>&1",
                     getNum = "(checkupdates 2>/dev/null; yay -Qua 2>/dev/null) | wc -l",
                     doUpdate = "yay -Syu" },
  { name = "paru",  check = "command -v checkupdates >/dev/null 2>&1 && command -v paru >/dev/null 2>&1",
                     getNum = "(checkupdates 2>/dev/null; paru -Qua 2>/dev/null) | wc -l",
                     doUpdate = "paru -Syu" },
  { name = "pacman",check = "command -v pacman >/dev/null 2>&1",
                     getNum = "pacman -Quq 2>/dev/null | wc -l",
                     doUpdate = "sudo pacman -Syu" },
}

-- ─── Helpers ─────────────────────────────────────────────────────────────
local function getCheckCmd()
  local custom = noctalia.getConfig("custom_cmd_get_num_updates")
  if custom ~= "" then return custom end
  if currentUpdater then return currentUpdater.getNum end
  return "echo 0"
end

local function getUpdateCmd()
  local custom = noctalia.getConfig("custom_cmd_do_update")
  if custom ~= "" then return custom end
  if currentUpdater then return currentUpdater.doUpdate end
  return "echo 'No update command configured'"
end

-- ─── Detección automática ────────────────────────────────────────────────
local function detectUpdater(index)
  if index > #updaters then
    refresh()
    return
  end
  local candidate = updaters[index]
  noctalia.runAsync(candidate.check, function(result)
    if result.exitCode == 0 then
      currentUpdater = candidate
      refresh()
    else
      detectUpdater(index + 1)
    end
  end, 10000)
end

-- ─── Refrescar ───────────────────────────────────────────────────────────
function refresh()
  if loading then return end
  loading = true
  barWidget.setGlyph("loader")
  
  noctalia.runAsync(getCheckCmd(), function(result)
    loading = false
    local count = tonumber(result.stdout:match("^%s*(%d+)%s*$")) or 0
    updateCount = count
    
    local icon = noctalia.getConfig("icon_name")
    local hide = noctalia.getConfig("hide_on_zero")
    
    barWidget.setText(tostring(count))
    
    if count == 0 then
      barWidget.setGlyph("check")
      if hide then barWidget.setVisible(false) end
      barWidget.setTooltip("No pending updates")
    else
      barWidget.setGlyph(icon)
      barWidget.setVisible(true)
      barWidget.setTooltip(tostring(count) .. " pending updates")
    end
  end, 60000)
end

-- ─── Timer ───────────────────────────────────────────────────────────────
function update()
  local mins = noctalia.getConfig("update_interval_minutes")
  noctalia.setUpdateInterval(mins * 60000)
  refresh()
end

-- ─── Click izquierdo → lanzar update ───────────────────────────────────────
function onClick()
  if updateCount > 0 then
    local term = noctalia.getConfig("terminal_cmd")
    local cmd = getUpdateCmd()
    local full = term .. " " .. cmd
    noctalia.runAsync(full)
  end
end

-- ─── Click medio → refrescar ─────────────────────────────────────────────
function onMiddleClick()
  refresh()
end

-- ─── IPC ─────────────────────────────────────────────────────────────────
function onIpc(event)
  if event == "check" then refresh() end
end

-- ─── Init ────────────────────────────────────────────────────────────────
barWidget.setText("?")
barWidget.setGlyph("loader")
detectUpdater(1)
