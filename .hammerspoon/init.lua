-- hello world
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
  hs.alert.show("Hello World!")
end)

-- Fix the issue: opencode in warp terminal doesn't work
-- Remap "Shift + Enter" to "Ctrl + j" when Warp terminal is focused
local warpFilter = hs.window.filter.new({ "Warp", "dev.warp.Warp-Stable" })
local warpEventTap = nil

warpFilter:subscribe(hs.window.filter.windowFocused, function()
  if warpEventTap then
    warpEventTap:stop()
  end

  warpEventTap = hs.eventtap
    .new({ hs.eventtap.event.types.keyDown }, function(event)
      local keyCode = event:getKeyCode()
      local mods = event:getFlags()

      -- Check for Shift + Enter (Enter key code is 36)
      if keyCode == 36 and mods.shift then
        hs.eventtap.keyStroke({ "ctrl" }, "j", 0)
        return true
      end
      return false
    end)
    :start()
end)

warpFilter:subscribe(hs.window.filter.windowUnfocused, function()
  if warpEventTap then
    warpEventTap:stop()
    warpEventTap = nil
  end
end)
