# AutoHotKey Hotkeys

You can install this script without AutoHotKey with the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases).

## Instant-Search

Press Win+Q and enter a query to open in it in DuckDuckGo.

Modifiers:

- Shift: Use Google Instead

## URL-Opener

Press Win+O to open the URL from clipboard.

Modifiers: (excluding eachother)

- Shift: Open Input-Window to enter own URL.
- Ctrl: Open Input-Window to modify URL before opening.

## URL-Shortcuts

Press Insert and enter a 2-char keycode in 2 seconds to paste a pre-saved url.

You need to create a file named "hotkey-urls.txt" in the same folder as the exe or ahk file with following format:

```txt
yt|https://youtube.com
gg|https://google.com
```

Modifiers: (can be used together)

- Shift: Open URL instead
- Ctrl: Open Input-Window to allow longer shortcuts and to have no time limit.


## Soft Lock

Press Shift+Win+L to disable mouse and keyboard input. (Only works when run as administrator)

Press Win+L or Ctrl+Alt+Delete to exit.
