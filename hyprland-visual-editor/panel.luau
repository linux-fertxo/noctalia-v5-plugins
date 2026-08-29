--!nonstrict
-- HVE v5 — Panel Principal

local cacheDir = (noctalia.getenv("XDG_CACHE_HOME") or (noctalia.getenv("HOME") .. "/.cache")) .. "/noctalia/HVE"
local stateFile = cacheDir .. "/hve_state.txt"

local function parseItems(text)
  if not text or text == "" then return {} end
  local items = {}
  for obj in text:gmatch("%{[^}]+%}") do
    local file = obj:match('"file"%s*:%s*"([^"]*)') or ""
    local title = obj:match('"rawTitle"%s*:%s*"([^"]*)') or file
    if file ~= "" then
      table.insert(items, { file = file, title = title,
        desc = obj:match('"rawDesc"%s*:%s*"([^"]*)') or "",
        icon = obj:match('"icon"%s*:%s*"([^"]*)') or "help",
        color = obj:match('"color"%s*:%s*"([^"]*)') or "#888",
        tag = obj:match('"tag"%s*:%s*"([^"]*)') or "USER",
      })
    end
  end
  return items
end

local function loadItems(category)
  local content = noctalia.readFile(cacheDir .. "/" .. category .. ".json")
  if content then return parseItems(content) end
  return {}
end

local function loadState()
  local nativeActive = noctalia.getConfig("is_system_active")
  local isActive = (nativeActive == "true" or nativeActive == true)
  local anim = noctalia.getConfig("active_anim_file") or ""
  local border = noctalia.getConfig("active_border_file") or ""
  local shader = noctalia.getConfig("active_shader_file") or ""
  
  local content = noctalia.readFile(stateFile)
  if content then
    for line in content:gmatch("[^\n]+") do
      local key, val = line:match("^(%w+)=(.*)$")
      if key == "isActive" then isActive = (val == "true") or isActive
      elseif key == "activeAnim" and anim == "" then anim = val
      elseif key == "activeBorder" and border == "" then border = val
      elseif key == "activeShader" and shader == "" then shader = val
      end
    end
  end
  return isActive, anim, border, shader
end

local activeTab = 0
local isActive, activeAnim, activeBorder, activeShader = loadState()
local selAnim, selBorder, selShader = 0, 0, 0
local animItems = loadItems("animations")
local borderItems = loadItems("borders")
local shaderItems = loadItems("shaders")
local tabNames = { "Home", "Animations", "Borders", "Effects" }
local tabIcons = { "home", "movie", "border-all", "wand" }

-- Resuelve el destino: "archivo" si hay preset seleccionado y HVE activo, "none" si no
local function resolveTarget(isOn, file)
  if isOn and file ~= "" then
    return file
  end
  return "none"
end

local function requestSave()
  local state = "isActive=" .. tostring(isActive) .. "\n"
    .. "activeAnim=" .. activeAnim .. "\n"
    .. "activeBorder=" .. activeBorder .. "\n"
    .. "activeShader=" .. activeShader
  noctalia.state.set("hve_save", state)
end

local function syncIPC()
  noctalia.state.set("is_system_active", isActive)
  noctalia.state.set("active_anim_file", activeAnim)
  noctalia.state.set("active_border_file", activeBorder)
  noctalia.state.set("active_shader_file", activeShader)
end

local function tabBar()
  local btns = {}
  for i = 1, 4 do
    table.insert(btns, ui.button({
      text = tabNames[i], glyph = tabIcons[i],
      onClick = "onTab" .. (i - 1), flexGrow = 1,
    }))
  end
  return ui.row({ gap = 4, align = "stretch" }, btns)
end

local function buildCategory(items, activeFile, category)
  if #items == 0 then
    return ui.label({ text = "No presets found — run scan.sh", color = "on_surface_variant" })
  end
  local opts = { "None" }
  for i, item in ipairs(items) do
    local mark = (item.file == activeFile) and " ★" or ""
    table.insert(opts, item.title .. mark)
  end
  local selVal = 0
  if category == "Anim" then selVal = selAnim
  elseif category == "Border" then selVal = selBorder
  elseif category == "Shader" then selVal = selShader end
  return ui.scroll({ flexGrow = 1, gap = 8 }, {
    ui.label({ text = #items .. " presets available", fontSize = 12, color = "on_surface_variant" }),
    ui.select({ options = opts, selectedIndex = selVal, onChange = "onSel" .. category }),
    ui.button({ text = "Select", onClick = "onApply" .. category, flexGrow = 1 }),
    ui.label({ text = "ℹ️ Then click the bar widget to apply", fontSize = 10, color = "on_surface_variant" }),
    activeFile ~= "" and ui.label({ text = "✓ " .. activeFile, fontSize = 11, color = "primary" }) or nil,
  })
end

function render()
  local content
  if activeTab == 0 then
    content = ui.scroll({ flexGrow = 1, gap = 12 }, {
      ui.label({ text = "🏠 HOME", fontSize = 16, color = "primary" }),
      ui.row({ gap = 8, align = "center" }, {
        ui.toggle({ checked = isActive, onChange = "onToggleActive" }),
        ui.label({ text = isActive and "HVE enabled" or "HVE disabled", flexGrow = 1 }),
      }),
      ui.label({ text = "✦ " .. #animItems .. " animations | " .. #borderItems .. " borders | " .. #shaderItems .. " shaders", fontSize = 12, color = "on_surface_variant" }),
      not isActive and ui.label({ text = "⚠️ Enable the toggle to apply changes", fontSize = 11, color = "error" }) or nil,
      ui.label({ text = "ℹ️ Changes apply when you click the bar widget", fontSize = 11, color = "on_surface_variant" }),
      ui.label({ text = "v4: XimoCP · v5: fertxo", fontSize = 11, color = "on_surface_variant" }),
    })
  elseif activeTab == 1 then
    content = ui.scroll({ flexGrow = 1, gap = 8 }, {
      ui.label({ text = "🎬 ANIMATIONS", fontSize = 16, color = "primary" }),
      buildCategory(animItems, activeAnim, "Anim"),
    })
  elseif activeTab == 2 then
    content = ui.scroll({ flexGrow = 1, gap = 8 }, {
      ui.label({ text = "🔲 BORDERS", fontSize = 16, color = "primary" }),
      buildCategory(borderItems, activeBorder, "Border"),
    })
  elseif activeTab == 3 then
    content = ui.scroll({ flexGrow = 1, gap = 8 }, {
      ui.label({ text = "✨ EFFECTS", fontSize = 16, color = "primary" }),
      buildCategory(shaderItems, activeShader, "Shader"),
    })
  end

  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "🦉 Hyprland Visual Editor", fontSize = 16, fontWeight = "bold", color = "primary" }),
      ui.button({ glyph = "close", onClick = "onClose" }),
    }),
    tabBar(),
    content,
  }))
end

function onToggleActive(value)
  isActive = (value == "true")
  noctalia.state.set("is_system_active", isActive)
  requestSave()
  syncIPC()
  render()
end
function onTab0() activeTab = 0; render() end
function onTab1() activeTab = 1; render() end
function onTab2() activeTab = 2; render() end
function onTab3() activeTab = 3; render() end
function onSelAnim(idx) selAnim = tonumber(idx) or 0; render() end
function onSelBorder(idx) selBorder = tonumber(idx) or 0; render() end
function onSelShader(idx) selShader = tonumber(idx) or 0; render() end

function onApplyAnim()
  if selAnim > 0 and selAnim <= #animItems then
    activeAnim = animItems[selAnim].file
  else
    activeAnim = ""
  end
  noctalia.state.set("hve_do_anim", resolveTarget(isActive, activeAnim))
  noctalia.state.set("hve_do_border", "")
  noctalia.state.set("hve_do_shader", "")
  requestSave()
  syncIPC()
  render()
end
function onApplyBorder()
  if selBorder > 0 and selBorder <= #borderItems then
    activeBorder = borderItems[selBorder].file
  else
    activeBorder = ""
  end
  noctalia.state.set("hve_do_anim", "")
  noctalia.state.set("hve_do_border", resolveTarget(isActive, activeBorder))
  noctalia.state.set("hve_do_shader", "")
  requestSave()
  syncIPC()
  render()
end
function onApplyShader()
  if selShader > 0 and selShader <= #shaderItems then
    activeShader = shaderItems[selShader].file
  else
    activeShader = ""
  end
  noctalia.state.set("hve_do_anim", "")
  noctalia.state.set("hve_do_border", "")
  noctalia.state.set("hve_do_shader", resolveTarget(isActive, activeShader))
  requestSave()
  syncIPC()
  render()
end
function onClose() panel.close() end
function onOpen(_context) render() end
