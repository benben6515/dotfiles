-- hello world
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
  hs.alert.show("Hello World!")
end)

-- fix the issue: opencode in warp terminal doesn't work
local keyMap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  local keycode = event:getKeyCode()
  local flags = event:getFlags()

  if keycode == 36 and flags.shift then
    local win = hs.window.focusedWindow()
    if win then
      local title = win:title()
      local app = win:application():name()

      if app:lower() == "warp" or (title and title:lower():find("warp")) then
        hs.eventtap.event.newKeyEvent({ "ctrl" }, "j", true):post()
        hs.eventtap.event.newKeyEvent({ "ctrl" }, "j", false):post()
        return true
      end
    end
  end
  return false
end)
keyMap:start()
