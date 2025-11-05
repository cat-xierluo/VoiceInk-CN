tell application id "ru.yandex.desktop.yandex-browser"
    tell front window
        tell active tab
            return URL
        end tell
    end tell
end tell 