# AutoHotKey Utils

You can install this script without AutoHotKey using the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases). Sorry to all non-Windows-users, but this is a Windows-only thing. :(

Jump to [config](#config).

## Current Features

- [InstantSearch](#instantsearch)
- [QRGenerator](#qrgenerator)
- [ClipboardURL](#clipboardurl)
- [URLShortcuts](#urlshortcuts)
- [QuickNotes](#quicknotes)

- [SoftLock](#softlock)*

### InstantSearch

Enter a query to open it in a search engine.

Default keybinds:

- `Win+Q`: Search on DuckDuckGo
- `Shift+Win+Q`: Search on Google

### QRGenerator

Generate a QRCode from an url or plaintext. If you use a url, please escape the url.

Default keybinds:

- `Ctrl+Win+Q`: Open Input-Window to enter text/url
- `Alt+Win+Q`: Use data in Clipboard

### ClipboardURL

Open the URL from the clipboard directly in your default browser.

Default keybinds:

- `Win+O`: Open Url directly
- `Ctrl+Win+O`: Open Input-Window to modify URL before opening

### URLShortcuts

Save URLs to open easily via shortcodes.

This module needs some configuration. (see [here](#create-url-shortcodes))

Default keybinds:

- `Insert`: Press and enter a 2-char shortcode during a 2-second-timeframe to **paste** url or text.
- `Shift+Insert`: Press and enter a 2-char shortcode during a 2-second-timeframe to **open** url.
- `Ctrl+Insert`: Open Input-Window and enter shortcode to **paste** url or text.
- `Ctrl+Shift+Insert`: Open Input-Window and enter shortcode to **open** url.

### QuickNotes

Create a quick note with pressing `Win+N`. View and edit your notes with `Ctrl+Win+N`.

### SoftLock*

Disable mouse and keyboard input via shortcut.

Default keybinds:

- `Shift+Win+L`: Block input

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

Default keybinds: (hotkey-urls.txt)

```txt
UrlShortcuts_Insert|Insert
UrlShortcuts_Open|+Insert
UrlShortcuts_BoxInsert|^Insert
UrlShortcuts_BoxOpen|+^Insert
InstantSearch_DuckDuckGo|#q
InstantSearch_Google|+#q
QRGenerator_InputBox|^#q
QRGenerator_FromClipboard|!#q
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
