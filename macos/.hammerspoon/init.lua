-- Hammerspoon init (macos)

-- Center mouse cursor on the focused window
local function centerMouseOnFocusedWindow()
    local win = hs.window.focusedWindow()
    if not win then return end
    local frame = win:frame()
    hs.mouse.setAbsolutePosition(hs.geometry.point(
        frame.x + frame.w / 2,
        frame.y + frame.h / 2
    ))
end

-- Focus an app, then center the mouse on its window once it's focused
local function focusAppAndCenterMouse(appName)
    hs.application.launchOrFocus(appName)
    local attempts = 0
    hs.timer.waitUntil(function()
        attempts = attempts + 1
        local win = hs.window.focusedWindow()
        if win then
            local app = win:application()
            if app and app:name() == appName then
                return true
            end
        end
        return attempts > 40
    end, centerMouseOnFocusedWindow, 0.05)
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", centerMouseOnFocusedWindow)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
    focusAppAndCenterMouse("kitty")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function()
    focusAppAndCenterMouse("Google Chrome")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    focusAppAndCenterMouse("Slack")
end)
