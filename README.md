# AutoHotKey Utils

You can install this script without AutoHotKey using the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases). Sorry to all non-Windows-users, but this is a Windows-only thing. :(

Jump to [config](#config).

## Current Features

- [InstantSearch](#instantsearch)
- [ClipboardURL](#clipboardurl)
- [URLShortcuts](#urlshortcuts)
- [QuickNotes](#quicknotes)

- [SoftLock](#softlock)*

### InstantSearch

Press `Win+Q` and enter a query to open in it in DuckDuckGo.

Modifiers:

- `Shift`: Use Google Instead

### ClipboardURL

Press `Win+O` to open the URL from clipboard.

Modifiers: (excluding eachother)

- `Ctrl`: Open Input-Window to modify URL before opening.

### URLShortcuts

Press `Insert` and enter a 2-char keycode during a 2-second-timeframe to paste a pre-saved url.

This module needs some configuration. (see [here](#create-url-shortcodes))

Modifiers: (can be used together)

- `Shift`: Open URL instead of inserting it.
- `Ctrl`: Open Input-Window to allow longer shortcuts and to have no time limit.

### QuickNotes

Create a quick note with pressing `Win+N`. View and edit your notes with `Ctrl+Win+N`.

### SoftLock*

Press `Shift+Win+L` to disable mouse and keyboard input. 

Press `Win+L` or `Ctrl+Alt+Delete` to exit.

## Config

You can configurate and change some things in this little "app". You can open the settings via right click on the tray icon -> Settings.

### Create URL-Shortcodes

You can modify the shortcodes used for the [UrlShortcuts](#urlshortcuts) module in the file called "hotkey-urls.txt" or in the settings. Use the following syntax: `shortcode|url`

Example:

```txt
gg|https://google.com
yt|https://youtube.com
```

### Modify keybinds

You can modify the keybinds used in this app in the file called "hotkey-keybinds.txt" or in the settings. Use the following syntax: `action|keybind`

The keybind syntax can be found [here](https://www.autohotkey.com/docs/Hotkeys.htm#Symbols).

Default keybinds:

```txt
UrlShortcuts_Insert|Insert
UrlShortcuts_Open|+Insert
UrlShortcuts_BoxInsert|^Insert
UrlShortcuts_BoxOpen|+^Insert
InstantSearch_DuckDuckGo|#q
InstantSearch_Google|+#q
ClipboardUrl_Open|#o
ClipboardUrl_OpenEditor|^#o
QuickNotes_Create|#n
QuickNotes_Open|^#n
SoftLock_Block|+#l
OpenUrl|+#o
```

Additionally, hotkeys for the following actions can be created:

- ReloadFiles
- UrlShortcuts_ReloadUrls
- Settings_Open

## Notes

\* = Only works when run as administrator

PS: All the shortcuts and modifiers shown on this page are working in the default configuration.
