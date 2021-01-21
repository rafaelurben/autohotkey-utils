# AutoHotKey Utils

You can install this script without AutoHotKey using the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases).

Current Features:

- [InstantSearch](#instantsearch)
- [ClipboardURLOpener](#clipboardurlopener)
- [URLShortcuts](#urlshortcuts)
- [QuickNotes](#quicknotes)

- [SoftLock](#softlock)*

## InstantSearch

Press `Win+Q` and enter a query to open in it in DuckDuckGo.

Modifiers:

- `Shift`: Use Google Instead

## ClipboardURLOpener

Press `Win+O` to open the URL from clipboard.

Modifiers: (excluding eachother)

- `Shift`: Open Input-Window to enter own URL.
- `Ctrl`: Open Input-Window to modify URL before opening.

## URLShortcuts

Press `Insert` and enter a 2-char keycode in 2 seconds to paste a pre-saved url.

You need to create a file named `hotkey-urls.txt` in the same folder as the .exe or .ahk file with following format:

```txt
yt|https://youtube.com
gg|https://google.com
```

If you edit this file while the script is already running, right-click the tray icon and click on `Controls -> Reload hotkey-urls.txt` to update the shortcuts.

Modifiers: (can be used together)

- `Shift`: Open URL instead of inserting it.
- `Ctrl`: Open Input-Window to allow longer shortcuts and to have no time limit.

## QuickNotes

Create a quick note with pressing `Win+N`. View and edit your notes with `Ctrl+Win+N`.

## SoftLock*

Press `Shift+Win+L` to disable mouse and keyboard input. 

Press `Win+L` or `Ctrl+Alt+Delete` to exit.

### Notes

\* = Only works when run as administrator