-- Energy Performance Bias widget (Noctalia v5 plugin)

local EPB_PATH = "/sys/devices/system/cpu/cpu0/power/energy_perf_bias"

local PROFILES = {
  [15] = { "leaf",   "POWER SAVE",  "tertiary" },
  [8]  = { "scale",  "BALANCE",     "primary" },
  [4]  = { "rocket", "PERFORMANCE", "secondary" },
  [0]  = { "flame",  "TURBO",       "error" },
}

local MENU_CMD  = "~/.config/rofi/powermenu/powerprofile.sh"
local SHOW_TEXT = true

local last = "unset" -- sentinel, so the first refresh always draws

local function render(epb)
  local key = tostring(epb)
  if key == last then return end
  last = key

  if epb == nil then
    barWidget.setGlyph("question-mark")
    barWidget.setText(SHOW_TEXT and "EPB ?" or "")
    barWidget.setGlyphColor("error")
    barWidget.setColor("error")
    return
  end

  local p = PROFILES[epb] or { "question-mark", "EPB " .. epb, "on_surface" }
  barWidget.setGlyph(p[1])
  barWidget.setText((SHOW_TEXT and not barWidget.isVertical()) and p[2] or "")
  barWidget.setGlyphColor(p[3])
  barWidget.setColor(p[3])
end

local function refresh()
  noctalia.runAsync("cat " .. EPB_PATH .. " 2>&1", function(...)
    local args = { ... }
    noctalia.log("epb-profile: callback got " .. #args .. " args")
    local out
    for i, v in ipairs(args) do
      noctalia.log("epb-profile: arg" .. i .. " type=" .. type(v) .. " value=" .. tostring(v))
      if type(v) == "string" and not out then out = v end
      if type(v) == "table" and not out then
        out = v.stdout or v.output or v.out or v[1]
      end
    end
    local raw = (out or ""):gsub("%s+", "")
    noctalia.log("epb-profile: raw='" .. raw .. "'")
    render(tonumber(raw))
  end)
end
-- No polling: the interval is effectively disabled, refresh comes via IPC.
noctalia.setUpdateInterval(3600000)
barWidget.setVisible(true)
barWidget.setGlyph("question-mark") -- placeholder until the first read
barWidget.setText("...")
refresh()

function update() end
function onClick() noctalia.runAsync(noctalia.expandPath(MENU_CMD)) end
function onRightClick() last = "unset"; refresh() end

function onIpc(event, payload)
  if event == "refresh" then
    last = "unset"
    refresh()
  end
end
