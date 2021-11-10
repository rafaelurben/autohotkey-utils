# AutoHotKey Utils

Autohotkey-utils gives you some very useful utils.

Jump to [config](#config).

## Installation

You can install this script without AutoHotKey using the .exe files found under [Releases](https://github.com/rafaelurben/autohotkey-utils/releases). Sorry to all non-Windows-users, but this is a Windows-only thing. :(

The first time you launch the script, it will ask you if you want it to automatically start everytime you log in. If you missed the chance to click yes, you can just delete the ".hotkey-temp.txt" file and reload the script.

Everytime the script reloads, it will check if there is a newer version of it available on this page and will ask you if you want to update.

Note: Windows may warn you that this script is insecure, but you can ignore this warning as long as you download the exe file from this repository. If you don't trust this exe file, you can also download the current .ahk file, but then you must also install AutoHotkey. But please note, that the update engine doesn't work when using the .ahk file!

## Current Modules

- [InstantSearch](#instantsearch)
- [QRGenerator](#qrgenerator)
- [ClipboardURL](#clipboardurl)
- [UrlShortcuts](#urlshortcuts)
- [QuickNotes](#quicknotes)
- [SoftLock](#softlock)

### InstantSearch

Enter a query to open it in a search engine.

You can modify the used search engines via [settings](#settings). Settings format: `SEARCHENGINE?||EngineName|EngineUrl` (where ? in [1,2,3])

| Action                    | Description                         | Default shortcut |
| ------------------------- | ----------------------------------- | ---------------- |
| InstantSearch_1           | Search on DuckDuckGo                | `Win+Q`          |
| InstantSearch_2           | Search on Google                    | `Shift+Win+Q`    |
| InstantSearch_3           | Search on Wikipedia                 | -                |
| InstantSearch_1_Clipboard | Search on DuckDuckGo from Clipboard | -                |
| InstantSearch_2_Clipboard | Search on Google from Clipboard     | -                |
| InstantSearch_3_Clipboard | Search on Wikipedia from Clipboard  | -                |

---

### QRGenerator

Generate a QRCode from any text.

Note: Please use the clipboard action if you need to use multiline data.

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

**ProTip**: You can also enter a file path or command to be executed instead of an url!

This module needs some configuration. (see [here](#create-url-shortcodes))

| Action                 | Description                                                                              | Default shortcut    |
| ---------------------- | ---------------------------------------------------------------------------------------- | ------------------- |
| UrlShortcuts_Insert    | Press and enter a 2-char shortcode during a 2-second-timeframe to **paste** url or text. | `Insert`            |
| UrlShortcuts_Open      | Press and enter a 2-char shortcode during a 2-second-timeframe to **open** url.          | `Shift+Insert`      |
| UrlShortcuts_BoxInsert | Open Input-Window and enter shortcode to **paste** url or text.                          | `Ctrl+Insert`       |
| UrlShortcuts_BoxOpen   | Open Input-Window and enter shortcode to **open** url.                                   | `Ctrl+Shift+Insert` |

---

### Drive letter open

Quickly open an explorer window with the desired drive.

| Action          | Description                                               | Default shortcut |
| --------------- | --------------------------------------------------------- | ---------------- |
| DriveLetterOpen | Press and enter a drive letter to open it in the explorer | `Shift+Win+E`    |

---

### QuickNotes

Create notes on the fly or paste your clipboard for later use.

Note: Please use the open action if you need to enter multiple lines.

| Action            | Description                  | Default shortcut |
| ----------------- | ---------------------------- | ---------------- |
| QuickNotes_Create | Create e new note            | `Shift+Win+N`    |
| QuickNotes_Open   | View and edit existing notes | `Ctrl+Win+N`     |

---

### SoftLock

Disable mouse and keyboard input via shortcut. (Note: This only works when the script is run as administrator.)

Press `Win+L` or `Ctrl+Alt+Delete` to exit.

| Action         | Description     | Default shortcut |
| -------------- | --------------- | ---------------- |
| SoftLock_Block | Block the input | `Shift+Win+L`    |

---

### Hotstrings

This module needs some configuration. (see [here](#create-hostrings))

---

### General actions

| Action         | Description                      | Default shortcut |
| -------------- | -------------------------------- | ---------------- |
| CloseProcess   | Close a process by name          |                  |
| ReloadFiles    | Reload the script and all files  | `Ctrl+Win+i`     |
| Settings_Open  | Open the settings page           | `Shift+Win+i`    |
| HoldRightMouse | Hold down the right mouse button |                  |
| HoldLeftMouse  | Hold down the left mouse button  |                  |
| PasteDateTime  | Paste the current date and time  |                  |

---

## Config

You can configurate and change some things in this little "app". You can open the settings via right click on the tray icon -> Settings or via the defined keybind (default: `Shift+Win+i`).

You can also edit the settings in their corresponding files, but don't forget to reload afterwards if you edit the files directly. (default: `Ctrl+Win+i`)
If you edit them in the settings, this is automatically done for you after saving.

### Create URL-Shortcodes

You can modify the shortcodes used for the [UrlShortcuts](#UrlShortcuts) module in the file called "hotkey-urls.txt" or in the settings. Use the following syntax: `shortcode|url`

Example:

```txt
gg|https://google.com
yt|https://youtube.com
```

### Create Hotstrings

Hotstrings automatically replaces certain strings while you're typing. E.g. you type "btw" and an ending character (`-()[]{}:;'"/\,.?!`, tab or newline) and btw automatically gets replaced with "by the way".

You can create hotstrings in the file called "hotkey-hotstrings.txt". Use the following syntax: `hotstring|replacement`

The hotstring syntax can be found [here](https://www.autohotkey.com/docs/Hotstrings.htm#Options). Note: Replace "::" between hotstring and replacement with "|"!

Example:

```txt
:o:@gm|@gmail.com
::btw|by the way
:*:hi|hello
```

Common options:

| Option | Behaviour                                                |
| ------ | -------------------------------------------------------- |
| o      | Automatically removes ending character after replacement |
| ?      | Allows hotstring to be IN a word                         |
| \*     | Doesn't require ending character to trigger              |

---

### Modify keybinds

You can modify the keybinds used in this app in the file called "hotkey-keybinds.txt" or in the settings. Use the following syntax: `action|keybind`

Note: If the actions are not present in the file, the default values are used. If you want do disable a default hotkey, enter the action without a keybind. (e.g. 4th line in example)

The keybind syntax can be found [here](https://www.autohotkey.com/docs/Hotkeys.htm#Symbols), all actions are listed in the tables on this page. Common modifiers are also found in the table below.

Example:

```txt
InstantSearch_1_Clipboard|#Numpad1
InstantSearch_2_Clipboard|#Numpad2
InstantSearch_3_Clipboard|#Numpad3
ReloadFiles|
```

Common modifiers:

| Modifier | Meaning           |
| -------- | ----------------- |
| #        | Windows-Key (Win) |
| +        | Shift             |
| ^        | Control (Ctrl)    |
| !        | Alt               |

---

### Settings

Some things like the search engines can be changed via settings. These are found in the settings page or the file called "hotkey-settings.txt". Use the following format: `Key||Value` Note: Use "||" here!

Note: If the keys are not present in the file, the default values are used.

Default:

```txt
SEARCHENGINE_1||DuckDuckGo|https://duckduckgo.com/?q
SEARCHENGINE_2||Google|https://google.com/search?q=
SEARCHENGINE_3||Wikipedia|https://en.wikipedia.org/wiki/Special:Search?search=
DATETIMEFORMAT||
```

Check [this page](https://www.autohotkey.com/docs/commands/FormatTime.htm#Date_Formats) for date formats.
