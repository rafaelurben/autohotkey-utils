# AutoHotKey Utils

You can install this script without AutoHotKey using the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases). Sorry to all non-Windows-users, but this is a Windows-only thing. :(

Jump to [config](#config). Jump to [important notes](#important-notes).

## Current Modules

- [InstantSearch](#instantsearch)
- [QRGenerator](#qrgenerator)
- [ClipboardURL](#clipboardurl)
- [UrlShortcuts](#UrlShortcuts)
- [QuickNotes](#quicknotes)
- [SoftLock](#softlock)[*](#important-notes)

### InstantSearch

Enter a query to open it in a search engine.

| Action                   | Description          | Default shortcut |
| ------------------------ | -------------------- | ---------------- |
| InstantSearch_DuckDuckGo | Search on DuckDuckGo | `Win+Q`          |
| InstantSearch_Google     | Search on Google     | `Shift+Win+Q`    |

---

### QRGenerator

Generate a QRCode from an url or plaintext. If you use an url, please escape it is passed as the data parameter (see [goqr.me](http://goqr.me/de/api/doc/create-qr-code/)).

| Action                    | Description                         | Default shortcut |
| ------------------------- | ----------------------------------- | ---------------- |
| QRGenerator_InputBox      | Open Input-Window to enter text/url | `Ctrl+Win+Q`     |
| QRGenerator_FromClipboard | Use data in Clipboard               | `Alt+Win+Q`      |

---

### ClipboardURL

Open the URL from the clipboard directly in your default browser.

| Action                  | Description                                    | Default shortcut |
| ----------------------- | ---------------------------------------------- | ---------------- |
| ClipboardURL_Open       | Open Url directly                              | `Win+O`          |
| ClipboardURL_OpenEditor | Open Input-Window to modify URL before opening | `Ctrl+Win+O`     |

---

### UrlShortcuts

Save URLs to open easily via shortcodes.

This module needs some configuration. (see [here](#create-url-shortcodes))

| Action                  | Description                                                                              | Default shortcut    |
| ----------------------- | ---------------------------------------------------------------------------------------- | ------------------- |
| UrlShortcuts_Insert     | Press and enter a 2-char shortcode during a 2-second-timeframe to **paste** url or text. | `Insert`            |
| UrlShortcuts_Open       | Press and enter a 2-char shortcode during a 2-second-timeframe to **open** url.          | `Shift+Insert`      |
| UrlShortcuts_BoxInsert  | Open Input-Window and enter shortcode to **paste** url or text.                          | `Ctrl+Insert`       |
| UrlShortcuts_BoxOpen    | Open Input-Window and enter shortcode to **open** url.                                   | `Ctrl+Shift+Insert` |
| UrlShortcuts_ReloadUrls | Reload hotkey-urls.txt                                                                   | -                   |

---

### QuickNotes

Create notes on the fly.

| Action            | Description         | Default shortcut |
| ----------------- | ------------------- | ---------------- |
| QuickNotes_Create | Create e new note   | `Win+N`          |
| QuickNotes_Open   | Edit existing notes | `Ctrl+Win+N`     |

---

### SoftLock*

Disable mouse and keyboard input via shortcut.

Press `Win+L` or `Ctrl+Alt+Delete` to exit.

| Action         | Description     | Default shortcut |
| -------------- | --------------- | ---------------- |
| SoftLock_Block | Block the input | `Shift+Win+L`    |

---

### General actions

| Action        | Description                     |
| ------------- | ------------------------------- |
| ReloadFiles   | Reload the script and all files |
| CloseProcess  | Close a process by name         |
| Settings_Open | Open the settings page          |

---

## Config

You can configurate and change some things in this little "app". You can open the settings via right click on the tray icon -> Settings.

### Create URL-Shortcodes

You can modify the shortcodes used for the [UrlShortcuts](#UrlShortcuts) module in the file called "hotkey-urls.txt" or in the settings. Use the following syntax: `shortcode|url`

**ProTip**: You can also enter a file path or command to be executed instead of an url!

Example:

```txt
gg|https://google.com
yt|https://youtube.com
```

### Create Hotstrings

Hotstrings automatically replaces certain strings while you're typing. E.g. you type "btw" and an ending character ("-()[]{}:;'"/\,.?!\`n \`t") and btw automatically gets replaced with "by the way".

You can create hotstrings in the file called "hotkey-hotstrings.txt". Use the following syntax: `hotstring|replacement`

The hotstring syntax can be found [here](https://www.autohotkey.com/docs/Hotstrings.htm#Options). Note: Replace "::" between hotstring and replacement with "|"!

Example:

```txt
:o:@gm|@gmail.com
::btw|by the way
:*:hi|hello
```

Common options:

| Option | Behaviour                                               |
| ------ | ------------------------------------------------------- |
| o      | Automatically remove ending character after replacement |
| ?      | Allow hotstring to be IN a word                         |
| *      | Don't require ending character                          |

---

### Modify keybinds

You can modify the keybinds used in this app in the file called "hotkey-keybinds.txt" or in the settings. Use the following syntax: `action|keybind`

The keybind syntax can be found [here](https://www.autohotkey.com/docs/Hotkeys.htm#Symbols), all actions are listed in the tables on this page.

Default hotkey-urls.txt file:

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

## Important notes

Modules marked with \* are only available when the script is run with elevated permissions ("as administrator").

When updating to a newer version, you may need to update the hotkey-keybinds.txt file if you want to use the new features.
