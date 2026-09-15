-- Hammerspoon init (macos)

-- Center mouse cursor on focused window
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    local frame = win:frame()
    hs.mouse.setAbsolutePosition(hs.geometry.point(
        frame.x + frame.w / 2,
        frame.y + frame.h / 2
    ))
end)

-- App launchers / focus
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
    hs.application.launchOrFocus("kitty")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    hs.application.launchOrFocus("Slack")
end)
