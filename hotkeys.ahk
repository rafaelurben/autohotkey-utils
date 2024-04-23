; Rafael Urben, 2022-2024
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

; #Warn  ; Enable warnings to assist with detecting common errors.
#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)

;; Variables

global CurrentVersion := "v2.0.0"

global _DEFAULTSETTINGS := Map(
	"SEARCHENGINE1", "DuckDuckGo|https://duckduckgo.com/?q=",
	"SEARCHENGINE2", "Google|https://google.com/search?q=",
	"SEARCHENGINE3", "Wikipedia|https://en.wikipedia.org/wiki/Special:Search?search=",
	"DATETIMEFORMAT", ""
)

global _DEFAULTKEYBINDS := Map(
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

global _GREEKALPHABET := Map(
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
	"Lamda", "Λ",
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
	"lamda", "λ",
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

;; Directories

DirCreate(A_WorkingDir "/data")
DirCreate(A_WorkingDir "/data/qr")
DirCreate(A_WorkingDir "/config")

;; Initialize config

global _UrlShortcuts_Data := _LoadDictFromFile("config/hotkey-urls.txt", "|")
global _Keybinds_Data := _LoadDictFromFile("config/hotkey-keybinds.txt", "|")
global _Settings_Data := _LoadDictFromFile("config/hotkey-settings.txt", "||")

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
		SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Reloading Script")
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

_GetSetting(key, dict, defaultdict) {
	try {
		if dict.Has(key)
			return dict[key]
		else
			return defaultdict[key]
	} catch as e {
		MsgBox("Failed to get setting with name " key "! `n`nError: " e.Message, "Settings error", 0)
	}	
}

_LoadDictFromFile(filename, seperator := "|") {
	_dict := Map()
	try {
		Loop Read, filename
		{
			row := StrSplit(A_LoopReadLine, seperator)
			key := row[1]
			val := row[2]
			_dict[key] := val
		}
	} catch OSError {
		; create file (didn't exist)
		FileAppend("", filename)
	}
	return _dict
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
				command := "`"" A_ScriptDir . "/hotkeys-" NewestVersion . ".exe`""
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
	command := "@echo off`nstart `"" A_ScriptFullPath "`""
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

;; Insert Urls (L=2, Input)

UrlShortcuts_Insert(*) {
	SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Insert shortcut")
	SplashTextGui.Add("Text", , "Please enter a shortcode...")
	SplashTextGui.Show("w300 h50")
	ihkey := InputHook("L2 T2", "{Esc}")
	ihkey.Start()
	endReason := ihkey.Wait()
	SplashTextGui.Destroy()
	if endReason = "Max" {
		key := ihkey.Input
		if _UrlShortcuts_Data.Has(key)
			Send(_UrlShortcuts_Data[key])
		else If key
			MsgBox("Unknown shortcut: `"" key "`"", "Insert URL failed", 0)
	}
}

;; Open Urls (L=2, Input)

UrlShortcuts_Open(*) {
	SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Open shortcut")
	SplashTextGui.Add("Text", , "Please enter a shortcode...")
	SplashTextGui.Show("w300 h50")
	ihkey := InputHook("L2 T2", "{Esc}")
	ihkey.Start()
	endReason := ihkey.Wait()
	SplashTextGui.Destroy()
	if endReason = "Max" {
		key := ihkey.Input
		if _UrlShortcuts_Data.Has(key)
			_OpenUrl(_UrlShortcuts_Data[key])
		else If key
			MsgBox("Unknown shortcut: `"" key "`"", "Open URL failed", 0)
	}
}

;; Insert urls (InputBox)

UrlShortcuts_BoxInsert(*) {
	IB := InputBox("Please enter shortcode:", "Insert URL")
	key := IB.Value
	if IB.Result = "OK" && key {
		if _UrlShortcuts_Data.Has(key)
			Send(_UrlShortcuts_Data[key])
		else If key
			MsgBox("Unknown key: `"" key "`"", "Insert URL failed", 0)
	}
}

;; Open urls (InputBox)

UrlShortcuts_BoxOpen(*) {
	IB := InputBox("Please enter shortcode:", "Open URL")
	key := IB.Value
	if IB.Result = "OK" && key {
		if _UrlShortcuts_Data.Has(key)
			_OpenUrl(_UrlShortcuts_Data[key])
		else If key
			MsgBox("Unknown key: `"" key "`"", "Open URL", 0)
	}
}


;;;; DriveLetterOpen

DriveLetterOpen(*) {
	SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Open drive"), SplashTextGui.Add("Text", , "Please enter a drive letter..."), SplashTextGui.Show("w300 h50")
	ihdrive := InputHook("L1 T2", "{Esc}"), ihdrive.Start(), ihdrive.Wait(), drive := ihdrive.Input
	SplashTextGui.Destroy
	if drive
		try {
			Run("`"" drive ":/`"")
		} catch {
			MsgBox("Couldn't open drive `"" drive "`"", "Drive not found", 0)
		}
	return
}


;;;; GreekAlphabet

GreekAlphabet(*) {
	SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Greek alphabet"), SplashTextGui.Add("Text", , "Please enter a letter..."), SplashTextGui.Show("w300 h50")
	ihletter := InputHook("T5", "{Esc}{Enter}"), ihletter.Start(), ihletter.Wait(), letter := ihletter.Input
	SplashTextGui.Destroy
	if _GREEKALPHABET.Has(letter) {
		greekletter := _GREEKALPHABET[letter]
		Send(greekletter)
	} else If letter
		MsgBox("Unknown letter: `"" letter "`"", "Greek alphabet", 0)
	return
}

;;;; Instant-Search

_InstantSearch(engineName, engineUrl, fromclipboard := false) {
	if fromclipboard {
		search := A_Clipboard
	} else {
		IB := InputBox("Please enter your query:", "Search on " engineName)
		if (IB.Result = "Cancel" || IB.Result = "Timeout") 
			return
		search := IB.Value
	}
	_search := _UrlEncode(search)
	url := engineUrl . "" . _search
	if url
		_OpenUrl(url)
	return
}

_InstantSearch_FromSetting(key, fromclipboard := false) {
	row := StrSplit(_GetSetting(key, _Settings_Data, _DEFAULTSETTINGS), "|")
	name := row[1]
	url := row[2]
	_InstantSearch(name, url, fromclipboard)
}

InstantSearch_1(*) {
	_InstantSearch_FromSetting("SEARCHENGINE1")
}

InstantSearch_2(*) {
	_InstantSearch_FromSetting("SEARCHENGINE2")
}

InstantSearch_3(*) {
	_InstantSearch_FromSetting("SEARCHENGINE3")
}

InstantSearch_1_Clipboard(*) {
	_InstantSearch_FromSetting("SEARCHENGINE1", true)
}

InstantSearch_2_Clipboard(*) {
	_InstantSearch_FromSetting("SEARCHENGINE2", true)
}

InstantSearch_3_Clipboard(*) {
	_InstantSearch_FromSetting("SEARCHENGINE3", true)
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

SoftLock_UnBlock(*) {
	BlockInput("Off")
	_ActionsMenu.Delete("[SoftLock] Block Input")
	_ActionsMenu.Add("[SoftLock] Block Input", SoftLock_Block)
}

SoftLock_Block(*) {
	Sleep(500)
	_ActionsMenu.Delete("[SoftLock] Block Input")
	_ActionsMenu.Add("[SoftLock] Block Input", SoftLock_UnBlock)
	_ActionsMenu.Check("[SoftLock] Block Input")
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
	_fmt := _GetSetting("DATETIMEFORMAT", _Settings_Data, _DEFAULTSETTINGS)
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

	SettingsGUI.Add("Link", "Y5 X5", "Edit URL shortcodes: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#create-url-shortcodes`">Syntax and Infos</a>")
	SettingsGUI_UrlShortcutEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-urls.txt")
	SettingsGUI_UrlShortcutEdit.Value := FileContent

	SettingsGUI.Add("Link", , "Edit Keybinds: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#modify-keybinds`">Syntax and Infos</a>")
	SettingsGUI_HotkeyEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-keybinds.txt")
	SettingsGUI_HotkeyEdit.Value := FileContent

	SettingsGUI.Add("Text", , "Press Ctrl+S to save and reload or Ctrl+W to exit without saving.")

	SettingsGUI.Add("Link", "Y5 X515", "Edit Hotstrings: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#create-hotstrings`">Syntax and Infos</a>")
	SettingsGUI_HotstringEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-hotstrings.txt")
	SettingsGUI_HotstringEdit.Value := FileContent

	SettingsGUI.Add("Link", , "Edit Settings: <a href=`"https://github.com/rafaelurben/autohotkey-utils/#settings`">Syntax and Infos</a>")
	SettingsGUI_SettingsEdit := SettingsGUI.Add("Edit", "R15 W500")
	FileContent := _ReadFileWithDefault("config/hotkey-settings.txt")
	SettingsGUI_SettingsEdit.Value := FileContent

	SettingsGUI.Add("Link", , "<a href=`"" . A_WorkingDir . "/config`">Open Config Folder</a> (Please do NOT edit files while the settings are opened!)")

	
	_SettingsGUI_Save(*) {
		SettingsGUI.Submit()
		_OverwriteFile("config/hotkey-urls.txt", SettingsGUI_UrlShortcutEdit.Value)
		_OverwriteFile("config/hotkey-keybinds.txt", SettingsGUI_HotkeyEdit.Value)
		_OverwriteFile("config/hotkey-hotstrings.txt", SettingsGUI_HotstringEdit.Value)
		_OverwriteFile("config/hotkey-settings.txt", SettingsGUI_SettingsEdit.Value)
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
	SettingsMenuBar := MenuBar()
	SettingsMenuBar.Add("&File", SettingsFileMenu)
	SettingsMenuBar.Add("&Links", SettingsLinksMenu)
	
	SettingsGUI.MenuBar := SettingsMenuBar
	SettingsGUI.Show()
}


;;;;;;;;;;; Main

_CreateTrayMenu() {
	UrlShortcutsMenu := Menu()
	UrlShortcutsMenu.Add("Insert", UrlShortcuts_BoxInsert)
	UrlShortcutsMenu.Add("Open", UrlShortcuts_BoxOpen)
	QRGeneratorMenu := Menu()
	QRGeneratorMenu.Add("Create from input", QRGenerator_InputBox)
	QRGeneratorMenu.Add("Create from clipbaord", QRGenerator_FromClipboard)
	InstantSearchMenu := Menu()
	InstantSearchMenu.Add("Search 1", InstantSearch_1)
	InstantSearchMenu.Add("Search 2", InstantSearch_2)
	InstantSearchMenu.Add("Search 3", InstantSearch_3)
	InstantSearchMenu.Add()
	InstantSearchMenu.Add("Search 1 from clipboard", InstantSearch_1_Clipboard)
	InstantSearchMenu.Add("Search 2 from clipboard", InstantSearch_2_Clipboard)
	InstantSearchMenu.Add("Search 3 from clipboard", InstantSearch_3_Clipboard)
	global _ActionsMenu := Menu()
	_ActionsMenu.Add("Close a Process", CloseProcess)
	_ActionsMenu.Add()
	_ActionsMenu.Add("[QRGenerator]", QRGeneratorMenu)
	_ActionsMenu.Add("[InstantSearch]", InstantSearchMenu)
	_ActionsMenu.Add("[UrlShortcuts]", UrlShortcutsMenu)
	_ActionsMenu.Add()
	_ActionsMenu.Add("[QuickNotes] Open", QuickNotes_Open)
	_ActionsMenu.Add("[SoftLock] Block Input", SoftLock_Block)
	Tray := A_TrayMenu
	Tray.Add()
	Tray.Add("Reload", ReloadFiles)
	Tray.Add("Settings", Settings_Open)
	Tray.Add("Check for updates", CheckForUpdate)
	Tray.Add()
	Tray.Add("Actions", _ActionsMenu)
	Tray.Add("Screenshot", Screenshot)
}

_RegisterHotkeys() {
	for func_name, _ in _DEFAULTKEYBINDS
	{
		func_obj := %func_name%
		if func_obj is Func {
			shortcut := _GetSetting(func_name, _Keybinds_Data, _DEFAULTKEYBINDS)

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
	hotstrings := _LoadDictFromFile("config/hotkey-hotstrings.txt")

	for key, value in hotstrings
	{
		try {
			Hotstring(key, value, "On")
		} catch as e {
			MsgBox("Invalid hostring: (`"" key "`" -> `"" value "`") `n`nError: " e.Message, "Hotstring Error", 0)
		}
	}
}
