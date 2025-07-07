; Rafael Urben, 2022-2025
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

#Warn All ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)

;; Version

global CurrentVersion := "v2.0.2"

;; Directories

DirCreate(A_WorkingDir "/data")
DirCreate(A_WorkingDir "/data/qr")
DirCreate(A_WorkingDir "/config")

;; Config

class Config {
	; Settings
	static _SETTINGS_Default := Map(
		"SEARCHENGINE1", "DuckDuckGo|https://duckduckgo.com/?q=",
		"SEARCHENGINE2", "Google|https://google.com/search?q=",
		"SEARCHENGINE3", "Wikipedia|https://en.wikipedia.org/wiki/Special:Search?search=",
		"DATETIMEFORMAT", "yyyy-MM-dd HH-mm-ss"
	)
	static _SETTINGS_Custom := this.LoadMapFromFile("hotkey-settings.txt", "||")
	
	static GetSetting(name) {
		return this._get(name, this._SETTINGS_Custom, this._SETTINGS_Default)
	}

	; Keybinds
	static _KEYBINDS_Default := Map(
		"UrlShortcuts_Insert", "Insert",
		"UrlShortcuts_Open", "^Insert",
		"UrlShortcuts_BoxInsert", "+Insert",
		"UrlShortcuts_BoxOpen", "+^Insert",
		"DriveLetterOpen", "+#e",
		"GreekAlphabet", "",
		"InstantSearch_1", "+#q",
		"InstantSearch_2", "",
		"InstantSearch_3", "",
		"InstantSearch_1_Clipboard", "#q",
		"InstantSearch_2_Clipboard", "",
		"InstantSearch_3_Clipboard", "",
		"QRGenerator_InputBox", "+!#q",
		"QRGenerator_FromClipboard", "!#q",
		"ClipboardUrl_Open", "#o",
		"ClipboardUrl_OpenEditor", "+#o",
		"QuickNotes_Create", "",
		"QuickNotes_Open", "",
		"SoftLock_Block", "+#l",
		"CloseProcess", "+#Esc",
		"ReloadFiles", "",
		"Settings_Open", "+#i",
		"HoldLeftMouse", "",
		"HoldRightMouse", "",
		"PasteDateTime", ""
	)

	static _KEYBINDS_Custom := this.LoadMapFromFile("hotkey-keybinds.txt", "|")

	static GetKeybind(name) {
		return this._get(name, this._KEYBINDS_Custom, this._KEYBINDS_Default)
	}

	static GetKeybindHumanReadable(name) {
		keybind := this.GetKeybind(name)
		keybind := StrReplace(keybind, "+", "Shift+",,, 1)
		keybind := StrReplace(keybind, "^", "Ctrl+",,, 1)
		keybind := StrReplace(keybind, "#", "Win+",,, 1)
		keybind := StrReplace(keybind, "!", "Alt+",,, 1)
		return keybind
	}

	; Utils
	static _get(key, dict, default) {
		try {
			if dict.Has(key)
				return dict[key]
			else
				return default[key]
		} catch as e {
			MsgBox("Failed to get config with name " key "! `n`nError: " e.Message, "Settings error", 0)
		}
	}
	
	static LoadMapFromFile(filename, separator := "|") {
		filepath := A_WorkingDir . "/config/" . filename
		_dict := Map()
		try {
			Loop Read, filepath
			{
				if (A_LoopReadLine = "") 
					continue
			
				row := StrSplit(A_LoopReadLine, separator)
				if (row.length != 2) {
					MsgBox("Invalid line in config file " filename ":`n`n" A_Index ": " A_LoopReadLine, "Configuration syntax error", 0)
					continue
				}

				key := row[1]
				val := row[2]
				_dict[key] := val
			}
		} catch OSError {
			; create file (didn't exist)
			FileAppend("", filepath)
		} catch Error as e {
			MsgBox("Failed to load config file " filename "! `n`nError: " e.Message, "Configuration error", 0)
		}
		return _dict
	}

	static StoreMapToFile(dict, filename, separator := "|") {
		filepath := A_WorkingDir . "/config/" . filename
		try {
			_file := FileOpen(filepath, "w")
			for key, value in dict {
				_file.WriteLine(key . separator . value)
			}
			_file.Close()
		} catch OSError as e {
			MsgBox("Failed to store config file " filename "! `n`nError: " e.Message, "Configuration error", 0)
		}
	}
}

class Settings {
	; [InstantSearch]
	static SearchEngine1 := SearchEngine.ParseFromString(Config.GetSetting("SEARCHENGINE1"))
	static SearchEngine2 := SearchEngine.ParseFromString(Config.GetSetting("SEARCHENGINE2"))
	static SearchEngine3 := SearchEngine.ParseFromString(Config.GetSetting("SEARCHENGINE3"))

	; [UrlShortcodes]
	static UrlShortcodes := Config.LoadMapFromFile("hotkey-urls.txt", "|")

	; [HotStrings]
	static HotStrings := Config.LoadMapFromFile("hotkey-hotstrings.txt")

	; [Random]
	static DateTimeFormat := Config.GetSetting("DATETIMEFORMAT")
}

;; Initialize

_CreateTrayMenu()
_RegisterHotkeys()
_RegisterHotstrings()
_CleanupUpdate()
CheckForUpdate(false, false)

;;;; Debug
;; Auto-reload

~^s::
{
	if WinActive(A_ScriptName)
	{
		SplashTextGui := Gui("-Sysmenu +ToolWindow +Disabled", "Reloading Script")
		SplashTextGui.Add("Text", , "Script is reloading...")
		SplashTextGui.Show("w120 h30")
		Sleep(500)
		SplashTextGui.Destroy
		Reload()
	}
	return
}


;;;; Functions

;; Private

_OpenUrl(url, *) {
	try {
		Run(url)
	} catch Error as e {
		MsgBox("Can't open `"" url "`"! Is this a valid url? `n`nError: `"" e.Message, "Opening URL failed", 0)
	}
	return
}

_OpenUrlEditor(defaultUrl) {
	IB := InputBox("Please enter your url:", "Open URL", , defaultUrl)
	if IB.Result = "OK"
		_OpenUrl(IB.Value)
	return
}

_OverwriteFile(filename, content := "") {
	_file := FileOpen(filename, "w")
	_file.Write(content)
	_file.Close()
}

_ReadFileWithDefault(filename, default := "") {
	try {
		return Fileread(filename)
	} catch OSError {
		return default
	}
}

_CloseProcess(name) {
	try {
		ProcessClose(name)
	} catch {
		MsgBox("Couldn't close process `"" name "`"", "Error", 0)
	}
}

_UrlEncode(Url, Flags := 0x000C3000) {
	; Source: https://www.autohotkey.com/boards/viewtopic.php?p=379780#p379780
	Local CC := 4096, Esc := "", Result := ""
	Loop {
		VarSetStrCapacity(&Esc, CC)
		Result := DllCall("Shlwapi.dll\UrlEscapeW", "Str", Url, "Str", &Esc, "UIntP", &CC, "UInt", Flags, "UInt")
	} Until Result != 0x80004003 ; E_POINTER
	Return Esc
}

;; Public

ReloadFiles(*) {
	Reload()
}

CloseProcess(*) {
	IB := InputBox("Please enter process name:", "Close Process", , "explorer.exe")
	if IB.Result = "OK"
		_CloseProcess(IB.Value)
	return
}

CheckForUpdate(show_no_new_update_message := true, show_error_message := true, *) {
	rand := Random(1, 10255)
	try {
		Download("https://raw.githubusercontent.com/rafaelurben/autohotkey-utils/master/version.txt?randParam=" rand, ".hotkey-temp.txt")
	} catch OSError as e {
		if (show_error_message) {
			MsgBox("Couldn't check for new autohotkey-utils versions!`n`nError: " e.Message, "Checking for updates failed")
		}
		return
	}
	NewestVersion := _ReadFileWithDefault(".hotkey-temp.txt")
	NewestVersion := Trim(NewestVersion, OmitChars := " `t`n`r")
	if (StrCompare(NewestVersion, CurrentVersion) > 0) {
		msgResult := MsgBox("Your current version: " CurrentVersion " `nNewest version available: " NewestVersion "`n`nWould you like to download the new version?", "Update available", 292)
		if (msgResult = "Yes")
		{
			try {
				Download("https://github.com/rafaelurben/autohotkey-utils/releases/download/" NewestVersion "/hotkeys-" NewestVersion ".exe?randParam=" rand, "hotkey-" NewestVersion ".exe")
				command := "@echo off`nstart `"autohotkey-utils`" /b `"" A_ScriptDir "/hotkeys-" NewestVersion ".exe`""
				_OverwriteFile("hotkey-run.bat", command)
				msgResult := MsgBox("The newest version has been downloaded.`n`nDo you want to update now?", "Downloaded " NewestVersion, 291)
				if (msgResult = "Yes")
				{
					_OverwriteFile(".hotkey-temp.txt", "UpdateDone")
					Run("hotkey-" NewestVersion ".exe")
					ExitApp()
				}
			} catch Error as e {
				MsgBox("The update to " NewestVersion " failed with error: " e.Message, "Update failed", 16)
			}
		}
	} else if show_no_new_update_message {
		MsgBox("Your current version (" CurrentVersion ") is the newest version available.", "No Update available", 0)
	}
}

_CleanupUpdate() {
	command := "@echo off`nstart `"autohotkey-utils`" /b `"" A_ScriptFullPath "`""
	_OverwriteFile("hotkey-run.bat", command)
	
	TempData := _ReadFileWithDefault(".hotkey-temp.txt", false)
	if (TempData = "UpdateDone") {
		_OverwriteFile(".hotkey-temp.txt", "-")
		msgResult := MsgBox("Your script has been updated to the newest version (" CurrentVersion "). You can delete the old version now.`n`nWould you like to open the folder?", "Update successful", 68)
		if (msgResult = "Yes")
			Run(A_ScriptDir)
	} else if (!TempData) {
		msgResult := MsgBox("Welcome to autohotkey-utils!`n`nDo you want to add this script to autostart?", "Welcome!", 68)
		if (msgResult = "Yes")
		{
			A_UserProfile := EnvGet("UserProfile")
			cmd := "mklink `"" A_UserProfile . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Run autohotkey-utils by rafaelurben`" `"" A_ScriptDir "\hotkey-run.bat`""
			_OverwriteFile(".hotkey-add-to-autostart.bat", cmd)
			RunWait("*RunAs `".hotkey-add-to-autostart.bat`"")
			MsgBox("The script has been added to autostart.", "Added to autostart", 64)
			FileDelete(".hotkey-add-to-autostart.bat")
		}
		_OverwriteFile(".hotkey-temp.txt", "-")
	}
}

;;;; Url-Shortcuts

;; Insert Urls (L=2, InputHook)

UrlShortcuts_Insert(*) {
	SplashTextGui := Gui("-Sysmenu +ToolWindow +AlwaysOnTop +Disabled", "Insert shortcut")
	SplashTextGui.Add("Text", , "Please enter a shortcode...")
	SplashTextGui.Show("w300 h50 NA")
	ihkey := InputHook("L2 T2", "{Esc}")
	ihkey.Start()
	endReason := ihkey.Wait()
	SplashTextGui.Destroy()
	if endReason = "Max" {
		key := ihkey.Input
		if Settings.UrlShortcodes.Has(key)
			Send(Settings.UrlShortcodes[key])
		else If key
			MsgBox("Unknown shortcode: `"" key "`"", "Insert URL failed", 0)
	}
}

;; Open Urls (L=2, InputHook)

UrlShortcuts_Open(*) {
	SplashTextGui := Gui("-Sysmenu +ToolWindow +AlwaysOnTop +Disabled", "Open shortcut")
	SplashTextGui.Add("Text", , "Please enter a shortcode...")
	SplashTextGui.Show("w300 h50 NA")
	ihkey := InputHook("L2 T2", "{Esc}")
	ihkey.Start()
	endReason := ihkey.Wait()
	SplashTextGui.Destroy()
	if endReason = "Max" {
		key := ihkey.Input
		if Settings.UrlShortcodes.Has(key)
			_OpenUrl(Settings.UrlShortcodes[key])
		else If key
			MsgBox("Unknown shortcode: `"" key "`"", "Open URL failed", 0)
	}
}

;; Insert urls (InputBox)

UrlShortcuts_BoxInsert(*) {
	IB := InputBox("Please enter a shortcode:", "Insert URL")
	key := IB.Value
	if IB.Result = "OK" && key {
		if Settings.UrlShortcodes.Has(key)
			Send(Settings.UrlShortcodes[key])
		else If key
			MsgBox("Unknown shortcode: `"" key "`"", "Insert URL failed", 0)
	}
}

;; Open urls (InputBox)

UrlShortcuts_BoxOpen(*) {
	IB := InputBox("Please enter a shortcode:", "Open URL")
	key := IB.Value
	if IB.Result = "OK" && key {
		if Settings.UrlShortcodes.Has(key)
			_OpenUrl(Settings.UrlShortcodes[key])
		else If key
			MsgBox("Unknown shortcode: `"" key "`"", "Open URL", 0)
	}
}


;;;; DriveLetterOpen

DriveLetterOpen(*) {
	SplashTextGui := Gui("-Sysmenu +ToolWindow +Disabled", "Open explorer")
	SplashTextGui.Add("Text", , "Please enter a drive letter...")
	SplashTextGui.Add("Text", , "You can also use one of the special keys:"
								"`n.`tOpen autohotkey-utils directory"
								"`n~/-`tOpen user profile directory")
	SplashTextGui.Show("w300 h100")
	ihdrive := InputHook("L1 T5", "{Esc}")
	ihdrive.Start()
	endReason := ihdrive.Wait()
	SplashTextGui.Destroy()
	if endReason = "Max" {
		drive := ihdrive.Input
		if (drive == ".") {
			Run("`"" A_WorkingDir "`"")
		} else if (drive == "~" || drive == "-") {
			A_UserProfile := EnvGet("UserProfile")
			Run("`"" A_UserProfile "`"")
		} else {
			try {
				Run("`"" drive ":/`"")
			} catch {
				MsgBox("Couldn't open drive `"" drive "`"", "Drive not found", 0)
			}
		}
	}
}


;;;; GreekAlphabet

global GREEK_ALPHABET := Map(
	"Alpha", "Α",
	"Beta", "Β",
	"Gamma", "Γ",
	"Delta", "Δ",
	"Epsilon", "Ε",
	"Zeta", "Ζ",
	"Eta", "Η",
	"Theta", "Θ",
	"Iota", "Ι",
	"Kappa", "Κ",
	"Lambda", "Λ",
	"Mu", "Μ",
	"Nu", "Ν",
	"Xi", "Ξ",
	"Omicron", "Ο",
	"Pi", "Π",
	"Rho", "Ρ",
	"Sigma", "Σ",
	"Tau", "Τ",
	"Upsilon", "Υ",
	"Phi", "Φ",
	"Chi", "Χ",
	"Psi", "Ψ",
	"Omega", "Ω",
	"alpha", "α",
	"beta", "β",
	"gamma", "γ",
	"delta", "δ",
	"epsilon", "ε",
	"zeta", "ζ",
	"eta", "η",
	"theta", "θ",
	"iota", "ι",
	"kappa", "κ",
	"lambda", "λ",
	"mu", "μ",
	"nu", "ν",
	"xi", "ξ",
	"omicron", "ο",
	"pi", "π",
	"rho", "ρ",
	"sigma", "σ",
	"tau", "τ",
	"upsilon", "υ",
	"phi", "φ",
	"chi", "χ",
	"psi", "ψ",
	"omega", "ω"
)

GreekAlphabet(*) {
	prompt := "Please enter the name of the greek letter to be inserted.`n`nAvailable letters: `n"
	for letterName, greekLetter in GREEK_ALPHABET {
		letterName2 := StrLower(letterName)
		greekLetter2 := GREEK_ALPHABET[letterName2]
		prompt .= Format("{} / {} = {} / {}`n", greekLetter, greekLetter2, letterName, letterName2)
		if A_Index >= GREEK_ALPHABET.Count / 2
			break
	}
	IB := InputBox(prompt, "Greek alphabet", "H" (130 + 19 * GREEK_ALPHABET.Count / 2))
	letter := IB.Value
	if IB.Result = "OK" && letter {
		if GREEK_ALPHABET.Has(letter) {
			greekletter := GREEK_ALPHABET[letter]
			Send(greekletter)
		} else If letter
			MsgBox("Unknown letter: `"" letter "`"", "Greek alphabet", 0)
		return
	}
}

;;;; Instant-Search

class SearchEngine extends Object {
	static ParseFromString(str) {
		; Format: "Name|Url" (query will be appended to the url)
		; Example: "DuckDuckGo|https://duckduckgo.com/?q="
		row := StrSplit(str, "|")
		return SearchEngine(row[1], row[2])
	}

	__New(name, url) {
		this.name := name
		this.url := url
	}

	Search(query) {
		_query := _UrlEncode(query)
		url := this.url . "" . _query
		_OpenUrl(url)
	}

	SearchFromMsgBox() {
		IB := InputBox("Please enter your query:", "Search on " this.name)
		if (IB.Result = "OK") 
			this.Search(IB.Value)
	}

	SearchFromClipboard() {
		this.Search(A_Clipboard)
	}
}

InstantSearch_1(*) {
	Settings.SearchEngine1.SearchFromMsgBox()
}

InstantSearch_2(*) {
	Settings.SearchEngine2.SearchFromMsgBox()
}

InstantSearch_3(*) {
	Settings.SearchEngine3.SearchFromMsgBox()
}

InstantSearch_1_Clipboard(*) {
	Settings.SearchEngine1.SearchFromClipboard()
}

InstantSearch_2_Clipboard(*) {
	Settings.SearchEngine2.SearchFromClipboard()
}

InstantSearch_3_Clipboard(*) {
	Settings.SearchEngine3.SearchFromClipboard()
}

;;;; QR-Generator

_QRGenerator(data) {
	newdata := _UrlEncode(data)

	try {
		Download("http://api.qrserver.com/v1/create-qr-code/?format=png&size=500x500&data=" newdata, A_WorkingDir "/data/qr/qrcode.png")
		Download("http://api.qrserver.com/v1/create-qr-code/?format=svg&size=500x500&data=" newdata, A_WorkingDir "/data/qr/qrcode.svg")
	} catch as e {
		MsgBox("An error occured: " e.Message "`n`nNote: This module requires an internet connection.", "QRGenerator Error", 0)
		return
	}

	QRGeneratorGUI := Gui()
	QRGeneratorGUI.Title := "autohotkey-utils by @rafaelurben - QR-Generator (via goqr.me)"

	QRGeneratorGUI.Add("Picture", "x0 y0 w500 h500", A_WorkingDir . "/data/qr/qrcode.png")
	QRGeneratorGUI.Add("Link", , "<a href=`"" . A_WorkingDir . "/data/qr/qrcode.svg`">Open svg</a> - <a href=`"" . A_WorkingDir . "/data/qr/qrcode.png`">Open Image</a> - <a href=`"" . A_WorkingDir . "/data/qr`">Open Folder</a> - <a href=`"http://api.qrserver.com/v1/create-qr-code/?format=svg&size=500x500&data=" . newdata . "`">Open in Browser</a>")
	QRGeneratorGUI.Add("Text", , "Data: `"" . data . "`"")

	QRGeneratorGUI_Exit(*) {
		QRGeneratorGUI.Destroy()
	}

	QRGeneratorFileMenu := Menu()
	QRGeneratorFileMenu.Add("E&xit`tCtrl+W", QRGeneratorGUI_Exit)
	QRGeneratorMenuBar := MenuBar()
	QRGeneratorMenuBar.Add("&File", QRGeneratorFileMenu)
	
	QRGeneratorGUI.MenuBar := QRGeneratorMenuBar
	QRGeneratorGUI.Show("Center w500")
}

QRGenerator_InputBox(*) {
	IB := InputBox("Please enter your data:", "Create a QR-Code")
	if IB.Result = "OK"
		_QRGenerator(IB.Value)
	return
}

QRGenerator_FromClipboard(*) {
	_QRGenerator(A_Clipboard)
}


;;;; Clipboard-Url-Opener

ClipboardUrl_Open(*) {
	_OpenUrl(A_Clipboard)
}

ClipboardUrl_OpenEditor(*) {
	_OpenUrlEditor(A_Clipboard)
}


;;;; Quick-Notes

QuickNotes_Create(*) {
	IB := InputBox("Please enter a text to create a note:", "QuickNote")
	note := IB.Value
	if IB.Result = "OK" && note
		FileAppend("`n" note, "config/hotkey-notes.txt")
}

QuickNotes_Open(*) {
	QuickNotesGUI := Gui()
	QuickNotesGUI.Title := "autohotkey-utils by @rafaelurben - QuickNotes"
	QuickNotesGUI.Add("Text", , "Edit your notes:")

	QuickNotesGUI_TextEdit := QuickNotesGUI.Add("Edit", "R20 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-notes.txt")
	QuickNotesGUI_TextEdit.Value := FileContent

	_QuickNotes_GUISave(*) {
		oSaved := QuickNotesGUI.Submit()
		_OverwriteFile("config/hotkey-notes.txt", QuickNotesGUI_TextEdit.Value)
	}

	_QuickNotes_GUIReset(*) {
		oSaved := QuickNotesGUI.Submit()
		_OverwriteFile("config/hotkey-notes.txt")
		QuickNotes_Open()
	}
	
	_QuickNotes_GUIExit(*) {
		QuickNotesGUI.Destroy()
	}

	QuickNotesGUI.Add("Text", , "Press Ctrl+S to save and exit or Ctrl+W to exit without saving.`nPress Ctrl+R to reset the file. (irreversible)")
	
	QuickNotesFileMenu := Menu()
	QuickNotesFileMenu.Add("&Save`tCtrl+S", _QuickNotes_GUISave)
	QuickNotesFileMenu.Add("&Reset`tCtrl+R", _QuickNotes_GUIReset)
	QuickNotesFileMenu.Add("E&xit`tCtrl+W", _QuickNotes_GUIExit)
	QuickNotesMenuBar := MenuBar()
	QuickNotesMenuBar.Add("&File", QuickNotesFileMenu)
	QuickNotesGUI.MenuBar := QuickNotesMenuBar

	QuickNotesGUI.Show()
}


;;;; Soft-Lock (Only works when run as Admin)

SoftLock_Block(*) {
	Sleep(500)
	BlockInput("On")
}

;;;; Random

HoldLeftMouse(*) {
	Click("Down Left")
}

HoldRightMouse(*) {
	Click("Down Right")
}

PasteDateTime(*) {
	_fmt := Settings.DateTimeFormat
	currentdatetime := FormatTime(, _fmt)
	SendInput(currentdatetime)
}

Screenshot(*) {
	Send("+#s")
}

;;;; Settings

Settings_Open(*) {
	SettingsGUI := Gui()
	SettingsGUI.Title := "autohotkey-utils by @rafaelurben - settings"

	; [UrlShortcuts] settings (top left)
	SettingsGUI.SetFont("bold")
	SettingsGUI.Add("Link", "Y5 X5", "Edit URL shortcodes: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#create-url-shortcodes`">Syntax and Infos</a>")
	SettingsGUI.SetFont("norm")
	SettingsGUI_UrlShortcutEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-urls.txt")
	SettingsGUI_UrlShortcutEdit.Value := FileContent

	; Keybinds settings (bottom left)
	SettingsGUI.SetFont("bold")
	SettingsGUI.Add("Link", , "Edit Keybinds: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#modify-keybinds`">Syntax and Infos</a>")
	SettingsGUI.SetFont("norm")
	SettingsGUI_HotkeyEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-keybinds.txt")
	SettingsGUI_HotkeyEdit.Value := FileContent

	; Hotstrings settings (top right)
	SettingsGUI.SetFont("bold")
	SettingsGUI.Add("Link", "Y5 X515", "Edit Hotstrings: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#create-hotstrings`">Syntax and Infos</a>")
	SettingsGUI.SetFont("norm")
	SettingsGUI_HotstringEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-hotstrings.txt")
	SettingsGUI_HotstringEdit.Value := FileContent

	; Util Settings
	SettingsGUI.SetFont("bold")
	SettingsGUI.Add("Link",, "Edit Settings: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#settings`">Infos</a>")
	SettingsGUI.SetFont("norm")

	SettingsGUI.Add("Text", "yp+20", "[InstantSearch]: Search engines")
	SettingsGUI.Add("Text", "xp+0", "No.")
	SettingsGUI.Add("Text", "xp+20", "Engine Name:")
	SettingsGUI.Add("Text", "xp+200", "Engine URL:")

	SettingsGUI.Add("Text", "xp-220 yp+22", "1")
	SettingsSearchEngine1_Name := SettingsGUI.Add("Edit", "r1 w200 xp+20", Settings.SearchEngine1.name)
	SettingsSearchEngine1_URL := SettingsGUI.Add("Edit", "r1 w280 xp+200", Settings.SearchEngine1.url)
	
	SettingsGUI.Add("Text", "xp-220 yp+22", "2")
	SettingsSearchEngine2_Name := SettingsGUI.Add("Edit", "r1 w200 xp+20", Settings.SearchEngine2.name)
	SettingsSearchEngine2_URL := SettingsGUI.Add("Edit", "r1 w280 xp+200", Settings.SearchEngine2.url)
	
	SettingsGUI.Add("Text", "xp-220 yp+22", "3")
	SettingsSearchEngine3_Name := SettingsGUI.Add("Edit", "r1 w200 xp+20", Settings.SearchEngine3.name)
	SettingsSearchEngine3_URL := SettingsGUI.Add("Edit", "r1 w280 xp+200", Settings.SearchEngine3.url)

	SettingsGUI.Add("Link", "xp-220 yp+25", "[PasteDateTime]: Date time format - See <a href=`"https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Date_Formats`">here</a> for syntax")
	SettingsDateTimeFormat := SettingsGUI.Add("Edit", "r1 w500", Settings.DateTimeFormat)

	; Settings status bar
	SettingsStatusBar := SettingsGUI.Add("StatusBar", "xp-220 yp+25", "Press Ctrl+S to save and reload or Ctrl+W to exit without saving.")
	
	_SettingsGUI_Save(*) {
		SettingsStatusBar.Text := "Saving settings... Please wait."
		SettingsGUI.Submit()
		_OverwriteFile("config/hotkey-urls.txt", SettingsGUI_UrlShortcutEdit.Value)
		_OverwriteFile("config/hotkey-keybinds.txt", SettingsGUI_HotkeyEdit.Value)
		_OverwriteFile("config/hotkey-hotstrings.txt", SettingsGUI_HotstringEdit.Value)
		Config.StoreMapToFile(Map(
			"SEARCHENGINE1", SettingsSearchEngine1_Name.Value . "|" . SettingsSearchEngine1_URL.Value,
			"SEARCHENGINE2", SettingsSearchEngine2_Name.Value . "|" . SettingsSearchEngine2_URL.Value,
			"SEARCHENGINE3", SettingsSearchEngine3_Name.Value . "|" . SettingsSearchEngine3_URL.Value,
			"DATETIMEFORMAT", SettingsDateTimeFormat.Value
		), "hotkey-settings.txt", "||")
		Reload()
	}

	_SettingsGUI_Exit(*) {
		SettingsGUI.Destroy()
	}

	SettingsFileMenu := Menu()
	SettingsFileMenu.Add("&Save`tCtrl+S", _SettingsGUI_Save)
	SettingsFileMenu.Add("E&xit`tCtrl+W", _SettingsGUI_Exit)
	SettingsLinksMenu := Menu()
	SettingsLinksMenu.Add("Repository (GitHub)", _OpenUrl.Bind("https://github.com/rafaelurben/autohotkey-utils/"))
	SettingsLinksMenu.Add("Releases (GitHub)", _OpenUrl.Bind("https://github.com/rafaelurben/autohotkey-utils/releases"))
	SettingsLinksMenu.Add("Author (GitHub)", _OpenUrl.Bind("https://github.com/rafaelurben/"))
	SettingsAdvancedMenu := Menu()
	SettingsAdvancedMenu.Add("Open config folder (Please close this window before editing files!)", _OpenUrl.Bind(A_WorkingDir . "/config"))
	SettingsMenuBar := MenuBar()
	SettingsMenuBar.Add("&File", SettingsFileMenu)
	SettingsMenuBar.Add("&Links", SettingsLinksMenu)
	SettingsMenuBar.Add("&Advanced", SettingsAdvancedMenu)
	
	SettingsGUI.MenuBar := SettingsMenuBar
	SettingsGUI.Show()
}


;;;;;;;;;;; Main

_CreateTrayMenu() {
	UrlShortcodesMenu := Menu()
	UrlShortcodesMenu.Add("Insert`t" Config.GetKeybindHumanReadable("UrlShortcuts_Insert"), UrlShortcuts_BoxInsert)
	UrlShortcodesMenu.Add("Open`t" Config.GetKeybindHumanReadable("UrlShortcuts_Open"), UrlShortcuts_Open)
	UrlShortcodesMenu.Add("Insert (Box)`t" Config.GetKeybindHumanReadable("UrlShortcuts_BoxInsert"), UrlShortcuts_BoxInsert)
	UrlShortcodesMenu.Add("Open (Box)`t" Config.GetKeybindHumanReadable("UrlShortcuts_BoxOpen"), UrlShortcuts_BoxOpen)

	QRGeneratorMenu := Menu()
	QRGeneratorMenu.Add("Create from input`t" Config.GetKeybindHumanReadable("QRGenerator_InputBox"), QRGenerator_InputBox)
	QRGeneratorMenu.Add("Create from clipbaord`t" Config.GetKeybindHumanReadable("QRGenerator_FromClipboard"), QRGenerator_FromClipboard)

	QuickNotesMenu := Menu()
	QuickNotesMenu.Add("Create`t" Config.GetKeybindHumanReadable("QuickNotes_Create"), QuickNotes_Create)
	QuickNotesMenu.Add("Open all`t" Config.GetKeybindHumanReadable("QuickNotes_Open"), QuickNotes_Open)

	ClipboardUrlMenu := Menu()
	ClipboardUrlMenu.Add("Open`t" Config.GetKeybindHumanReadable("ClipboardUrl_Open"), ClipboardUrl_Open)
	ClipboardUrlMenu.Add("Open with editor`t" Config.GetKeybindHumanReadable("ClipboardUrl_OpenEditor"), ClipboardUrl_OpenEditor)

	InstantSearchMenu := Menu()
	InstantSearchMenu.Add(Settings.SearchEngine1.name "`t" Config.GetKeybindHumanReadable("InstantSearch_1"), InstantSearch_1)
	InstantSearchMenu.Add(Settings.SearchEngine1.name " (clipboard) `t" Config.GetKeybindHumanReadable("InstantSearch_1_Clipboard"), InstantSearch_1_Clipboard)
	InstantSearchMenu.Add()
	InstantSearchMenu.Add(Settings.SearchEngine2.name "`t" Config.GetKeybindHumanReadable("InstantSearch_2"), InstantSearch_2)
	InstantSearchMenu.Add(Settings.SearchEngine2.name " (clipboard) `t" Config.GetKeybindHumanReadable("InstantSearch_2_Clipboard"), InstantSearch_2_Clipboard)
	InstantSearchMenu.Add()
	InstantSearchMenu.Add(Settings.SearchEngine3.name "`t" Config.GetKeybindHumanReadable("InstantSearch_3"), InstantSearch_3)
	InstantSearchMenu.Add(Settings.SearchEngine3.name " (clipboard) `t" Config.GetKeybindHumanReadable("InstantSearch_3_Clipboard"), InstantSearch_3_Clipboard)
	
	global _ActionsMenu := Menu()
	_ActionsMenu.Add("[InstantSearch]", InstantSearchMenu)
	_ActionsMenu.Add("[QRGenerator]", QRGeneratorMenu)
	_ActionsMenu.Add("[ClipboardURL]", ClipboardUrlMenu)
	_ActionsMenu.Add("[UrlShortcuts]", UrlShortcodesMenu)
	_ActionsMenu.Add("[DriveLetterOpen] Open`t" Config.GetKeybindHumanReadable("DriveLetterOpen"), DriveLetterOpen)
	_ActionsMenu.Add("[GreekAlphabet] Insert`t" Config.GetKeybindHumanReadable("GreekAlphabet"), GreekAlphabet)
	_ActionsMenu.Add("[QuickNotes]", QuickNotesMenu)
	if (A_IsAdmin) {
		_ActionsMenu.Add()
		_ActionsMenu.Add("[SoftLock] Block Input`t" Config.GetKeybindHumanReadable("SoftLock_Block"), SoftLock_Block)
	}
	_ActionsMenu.Add()
	_ActionsMenu.Add("Close process by name`t" Config.GetKeybindHumanReadable("CloseProcess"), CloseProcess)
	_ActionsMenu.Add("Paste date and time`t" Config.GetKeybindHumanReadable("PasteDateTime"), PasteDateTime)

	Tray := A_TrayMenu
	Tray.Add()
	Tray.Add("Check for updates", CheckForUpdate)
	Tray.Add("Reload`t" Config.GetKeybindHumanReadable("ReloadFiles"), ReloadFiles)
	Tray.Add("Settings`t" Config.GetKeybindHumanReadable("Settings_Open"), Settings_Open)
	Tray.Add()
	Tray.Add("Actions", _ActionsMenu)
	Tray.Add("Screenshot", Screenshot)
}

_RegisterHotkeys() {
	for func_name, _ in Config._KEYBINDS_Default
	{
		func_obj := %func_name%
		if func_obj is Func {
			shortcut := Config.GetKeybind(func_name)

			if (shortcut != "") {
				try {
					Hotkey(shortcut, func_obj, "On")
				} catch {
					MsgBox("Couldn't create shortcut `"" shortcut "`" for action `"" func_name "`".", "Hotkey Error", 0)
				}
			}
		} else {
			MsgBox("Unknown action: `"" func_name "`".", "Hotkey Error", 0)
		}
	}
}

_RegisterHotstrings() {
	for key, value in Settings.HotStrings
	{
		try {
			Hotstring(key, value, "On")
		} catch as e {
			MsgBox("Invalid hostring: (`"" key "`" -> `"" value "`") `n`nError: " e.Message, "Hotstring Error", 0)
		}
	}
}
