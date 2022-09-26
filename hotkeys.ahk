; Rafael Urben, 2022
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;; Variables

Global CurrentVersion := "v1.0"

Global _DEFAULTSETTINGS := {  "SEARCHENGINE1": "DuckDuckGo|https://duckduckgo.com/?q="
  							, "SEARCHENGINE2": "Google|https://google.com/search?q="
							, "SEARCHENGINE3": "Wikipedia|https://en.wikipedia.org/wiki/Special:Search?search=" 
							, "DATETIMEFORMAT": "" }

Global _DEFAULTKEYBINDS := {  "UrlShortcuts_Insert": "Insert"
							, "UrlShortcuts_Open": "+Insert"
							, "UrlShortcuts_BoxInsert": "^Insert"
							, "UrlShortcuts_BoxOpen": "+^Insert"
							, "DriveLetterOpen": "+#e"
							, "GreekAlphabet": "+#g"
							, "InstantSearch_1": "#q"
							, "InstantSearch_2": "+#q"
							, "InstantSearch_3": ""
							, "InstantSearch_1_Clipboard": ""
							, "InstantSearch_2_Clipboard": ""
							, "InstantSearch_3_Clipboard": ""
							, "QRGenerator_InputBox": "^#q"
							, "QRGenerator_FromClipboard": "!#q"
							, "ClipboardUrl_Open": "#o"
							, "ClipboardUrl_OpenEditor": "^#o"
							, "QuickNotes_Create": "+#n"
							, "QuickNotes_Open": "^#n"
							, "SoftLock_Block": "+#l"
							, "OpenUrl": "+#o"
							, "CloseProcess": ""
							, "ReloadFiles": "^#i"
							, "Settings_Open": "+#i"
							, "HoldLeftMouse": ""
							, "HoldRightMouse": ""
							, "PasteDateTime": "" }

Global _GREEKALPHABET := {"Alpha": "Α", "Beta": "Β", "Gamma": "Γ", "Delta": "Δ", "Epsilon": "Ε", "Zeta": "Ζ", "Eta": "Η", "Theta": "Θ", "Iota": "Ι", "Kappa": "Κ", "Lamda": "Λ", "Mu": "Μ", "Nu": "Ν", "Xi": "Ξ", "Omicron": "Ο", "Pi": "Π", "Rho": "Ρ", "Sigma": "Σ", "Tau": "Τ", "Upsilon": "Υ", "Phi": "Φ", "Chi": "Χ", "Psi": "Ψ", "Omega": "Ω", "alpha": "α", "beta": "β", "gamma": "γ", "delta": "δ", "epsilon": "ε", "zeta": "ζ", "eta": "η", "theta": "θ", "iota": "ι", "kappa": "κ", "lamda": "λ", "mu": "μ", "nu": "ν", "xi": "ξ", "omicron": "ο", "pi": "π", "rho": "ρ", "sigma": "σ", "tau": "τ", "upsilon": "υ", "phi": "φ", "chi": "χ", "psi": "ψ", "omega": "ω"}

;; GUI Veriables

Global _QuickNotes_GUITextEdit
Global _Settings_GUIUrlShortcutEdit
Global _Settings_GUIHotkeyEdit
Global _Settings_GUIHotstringEdit
Global _Settings_GUISettingsEdit

;; Initialize

Global _UrlShortcuts_Data := _LoadDictFromFile("hotkey-urls.txt", "|")
Global _Keybinds_Data := _LoadDictFromFile("hotkey-keybinds.txt", "|")
Global _Settings_Data := _LoadDictFromFile("hotkey-settings.txt", "||")

_CreateTrayMenu()
_RegisterHotkeys()
_RegisterHotstrings()
_CleanupUpdate()
CheckForUpdate(false)

;;;; Debug
;; Auto-reload

~^s:: 
{
	IfWinActive, %A_ScriptName% 
		{ 
			SplashTextOn,300,50,Reloading Script, Script is reloading...
			Sleep, 500  
			SplashTextOff
			Reload 
		} 
	return
}


;;;; Functions

;; Private

_OpenUrl(url) {
	try {
		Run, %url%
	} catch e {
		MsgBox, 0, Opening URL failed, Can't open "%url%"! Is this a valid url?
	}
	return
}

_OpenUrlEditor(defaultUrl) {
	InputBox, url, Open URL, Please enter your url:, , , , , , , , %defaultUrl%
	If !ErrorLevel
		_OpenUrl(url)
	return
}

_GetSetting(key, dict, defaultdict) {
	if dict.HasKey(key) 
		return dict[key]
	else 
		return defaultdict[key]
}

_LoadDictFromFile(filename, seperator="|") {
	dict := {}
	Loop, Read, %filename%
		{
			row := StrSplit(A_LoopReadLine, seperator)
			key := row[1]
			val := row[2]
			dict[key] := val
		}
	return dict
}

_OverwriteFile(filename, content="") {
	file := FileOpen(filename, "w")
	file.Write(content)
	file.Close()
}

_CloseProcess(name) {
	try {
		Process, Close, %name%
	} catch {
		MsgBox, 0, Error, Couldn't close process "%name%"
	}
}

_UrlEncode(String)
{
	OldFormat := A_FormatInteger
	SetFormat, Integer, H

	Loop, Parse, String
	{
		if A_LoopField is alnum
		{
			Out .= A_LoopField
			continue
		}
		Hex := SubStr( Asc( A_LoopField ), 3 )
		Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
	}

	SetFormat, Integer, %OldFormat%

	return Out
}

;; Public

ReloadFiles() {
	Reload
}

OpenUrl() {
	_OpenUrlEditor("https://")
}

CloseProcess() {
	InputBox, name, Close Process, Please enter process name:,,,,,,,,explorer.exe
	if !ErrorLevel
		_CloseProcess(name)
	return
}

CheckForUpdate(shownonewupdatemessage=true) {
	Random, rand, 1, 10255
	UrlDownloadToFile, https://raw.githubusercontent.com/rafaelurben/autohotkey-utils/master/version.txt?randParam=%rand%, .hotkey-temp.txt
	FileRead, NewestVersion, .hotkey-temp.txt
	NewestVersion :=  Trim(NewestVersion, OmitChars := " `t`n`r")
	if (NewestVersion != CurrentVersion) {
		MsgBox, 292, Update available, Your current version: %CurrentVersion% `nNewest version available: %NewestVersion%`n`nWould you like to download the new version?
		IfMsgBox, Yes
			{
				UrlDownloadToFile, https://github.com/rafaelurben/autohotkey-utils/releases/download/%NewestVersion%/hotkeys-%NewestVersion%.exe?randParam=%rand%, hotkey-%NewestVersion%.exe
				if !ErrorLevel {
					command := """" . A_ScriptDir . "/hotkeys-" . NewestVersion . ".exe"""
					_OverwriteFile("hotkey-run.bat", command)
					MsgBox, 291, Downloaded %NewestVersion%, The newest version has been downloaded.`n`nDo you want to update now?
					IfMsgBox, Yes
						{
							_OverwriteFile(".hotkey-temp.txt", "UpdateDone")
							Run, hotkey-%NewestVersion%.exe
							ExitApp
						}
					IfMsgBox, No
						return
				} else {
					MsgBox, 16, Update failed, The update to %NewestVersion% failed.
				}
			}
	} else if shownonewupdatemessage {
		MsgBox, 0, No Update available, Your current version (%CurrentVersion%) is the newest version available.
	}
}

_CleanupUpdate() {
	FileRead, TempData, .hotkey-temp.txt
	command := """" . A_ScriptFullPath . """"
	_OverwriteFile("hotkey-run.bat", command)
	if (TempData = "UpdateDone") {
		_OverwriteFile(".hotkey-temp.txt", "-")
		MsgBox, 65, Update successful, Your script has been updated to the newest version (%CurrentVersion%). You can delete the old version now.`n`nWould you like to open the folder?
		IfMsgBox, Ok
			Run, %A_ScriptDir%
	} else if (!TempData) {
		MsgBox, 68, Welcome!, Welcome to autohotkey-utils!`n`nDo you want to add this script to autostart?
		IfMsgBox, Yes
			{
				EnvGet, A_UserProfile, UserProfile
				Run, %comspec% /c mklink "%A_UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\hotkey-run.bat" "%A_ScriptDir%\hotkey-run.bat"
			}
		_OverwriteFile(".hotkey-temp.txt", "-")
	}
}

;;;; Url-Shortcuts

;; Insert Urls (L=2, Input)

UrlShortcuts_Insert() {
	SplashTextOn,300,50,Insert shortcut, Please enter a shortcode...
	Input, key, L2 T2, {Esc}
	SplashTextOFf
	if _UrlShortcuts_Data.HasKey(key)
		Send, % _UrlShortcuts_Data[key]
	else If key
		MsgBox, 0, Insert URL, Unknown shortcut: "%key%"
	return
}

;; Open Urls (L=2, Input)

UrlShortcuts_Open() {
	SplashTextOn,300,50,Open shortcut, Please enter a shortcode...
	Input, key, L2 T2, {Esc}
	SplashTextOFf
	if _UrlShortcuts_Data.HasKey(key)
		_OpenUrl(_UrlShortcuts_Data[key])
	else If key
		MsgBox, 0, Open URL, Unknown shortcut: "%key%"
	return
}

;; Insert urls (InputBox)

UrlShortcuts_BoxInsert() {
	InputBox, key, Insert URL, Please enter shortcode:
	if _UrlShortcuts_Data.HasKey(key)
		Send, % _UrlShortcuts_Data[key]
	else If key
		MsgBox, 0, Insert URL, Unknown key: "%key%"
	return
}

;; Open urls (InputBox)

UrlShortcuts_BoxOpen() {
	InputBox, key, Open URL, Please enter shortcode:
	if _UrlShortcuts_Data.HasKey(key)
		_OpenUrl(_UrlShortcuts_Data[key])
	else If key
		MsgBox, 0, Open URL, Unknown key: "%key%"
	return
}


;;;; DriveLetterOpen

DriveLetterOpen() {
	SplashTextOn,300,50,Open drive, Please enter a drive letter...
	Input, drive, L1 T2, {Esc}
	SplashTextOff
	if drive
		try {
			Run, "%drive%:/"
		} catch e {
			MsgBox, 0, Drive not found, Couldn't open drive "%drive%"
		}
	return
}


;;;; GreekAlphabet

GreekAlphabet() {
	SplashTextOn,300,50,Greek alphabet, Please enter a letter...
	Input, letter, T5, {Esc}{Enter}
	SplashTextOff
	if _GREEKALPHABET.HasKey(letter) {
		greekletter := _GREEKALPHABET[letter]
		Send, % greekletter
		MsgBox, 0, Greek alphabet, Letter: "%letter%" -> %greekletter%
	} else If letter
		MsgBox, 0, Greek alphabet, Unknown letter: "%letter%"
	return
}

;;;; Instant-Search

_InstantSearch(engineName, engineUrl, fromclipboard=false) {
	if fromclipboard
		search := Clipboard
	else
		InputBox, search, Search on %engineName%, Please enter your query:
	search := _UrlEncode(search)
	url = %engineUrl%%search%
	If !ErrorLevel
		_OpenUrl(url)
	return
}

_InstantSearch_FromSetting(key, fromclipboard=false) {
	row := StrSplit(_GetSetting(key, _Settings_Data, _DEFAULTSETTINGS), "|")
	name := row[1]
	url := row[2]
	_InstantSearch(name, url, fromclipboard)
}

InstantSearch_1() { 
	_InstantSearch_FromSetting("SEARCHENGINE1") 
}

InstantSearch_2() {
	_InstantSearch_FromSetting("SEARCHENGINE2")
}

InstantSearch_3() {
	_InstantSearch_FromSetting("SEARCHENGINE3")
}

InstantSearch_1_Clipboard() { 
	_InstantSearch_FromSetting("SEARCHENGINE1", true) 
}

InstantSearch_2_Clipboard() {
	_InstantSearch_FromSetting("SEARCHENGINE2", true)
}

InstantSearch_3_Clipboard() {
	_InstantSearch_FromSetting("SEARCHENGINE3", true)
}

;;;; QR-Generator

_QRGenerator_GUIExit() {
	Gui, QRGenerator:Destroy
}

_QRGenerator(data) {
	newdata := _UrlEncode(data)
	UrlDownloadToFile, http://api.qrserver.com/v1/create-qr-code/?format=png&size=500x500&data=%newdata%, hotkey-qrcode.png
	UrlDownloadToFile, http://api.qrserver.com/v1/create-qr-code/?format=svg&size=500x500&data=%newdata%, hotkey-qrcode.svg

	if !ErrorLevel {
		Gui, QRGenerator:New
		Gui, QRGenerator: +AlwaysOnTop +Resize -MaximizeBox

		Gui, QRGenerator:Add, Picture, x0 y0 w500 h500, hotkey-qrcode.png
		Gui, QRGenerator:Add, Link, , <a href="hotkey-qrcode.svg">Open svg</a> - <a href="hotkey-qrcode.png">Open Image</a> - <a href="%A_WorkingDir%">Open Folder</a> - <a href="http://api.qrserver.com/v1/create-qr-code/?format=svg&size=500x500&data=%newdata%">Open in Browser</a>
		Gui, QRGenerator:Add, Text, , Data: "%data%"

		Menu, QRGeneratorFileMenu, Add, E&xit`tCtrl+W, _QRGenerator_GUIExit
		Menu, QRGeneratorMenuBar, Add, &File, :QRGeneratorFileMenu 
		Gui, QRGenerator:Menu, QRGeneratorMenuBar
		
		Gui, QRGenerator:Show, Center w500, QRGenerator (via goqr.me)
	} else {
		MsgBox, 0, QRGenerator Error, An error occured
	}
}

QRGenerator_InputBox() {
	InputBox, data, Create a QR-Code, Please enter your data:
	if !ErrorLevel
		_QRGenerator(data)
	return
}

QRGenerator_FromClipboard() {
	_QRGenerator(Clipboard)
}


;;;; Clipboard-Url-Opener

ClipboardUrl_Open() { 	
	_OpenUrl(Clipboard)
}

ClipboardUrl_OpenEditor() {
	_OpenUrlEditor(Clipboard)
}


;;;; Quick-Notes

QuickNotes_Create() {
	InputBox, note, QuickNote, Please enter a text to create a note:
	if note
		FileAppend, `n%note%, hotkey-notes.txt
}

_QuickNotes_GUISave() {
	Gui, QuickNotes:Submit
	_OverwriteFile("hotkey-notes.txt", _QuickNotes_GUITextEdit)
}

_QuickNotes_GUIReset() {
	Gui, QuickNotes:Submit
	file := FileOpen("hotkey-notes.txt", "w")
	file.Close()
	QuickNotes_Open()
}

_QuickNotes_GUIExit() {
	Gui, QuickNotes:Destroy
}

QuickNotes_Open() {
	Gui, QuickNotes:New, , QuickNotes
	Gui, QuickNotes: +AlwaysOnTop
	Gui, QuickNotes:Add, Text, , Edit your notes:

	Gui, QuickNotes:Add, Edit, R20 W500 v_QuickNotes_GUITextEdit
	FileRead, FileContent, hotkey-notes.txt
	GuiControl,, _QuickNotes_GUITextEdit, %FileContent%

	Gui, QuickNotes:Add, Text, , Press Ctrl+S to save and exit or Ctrl+W to exit without saving.`nPress Ctrl+R to reset the file. (irreversible)

	Menu, QuickNotesFileMenu, Add, &Save`tCtrl+S, _QuickNotes_GUISave
	Menu, QuickNotesFileMenu, Add, &Reset`tCtrl+R, _QuickNotes_GUIReset
	Menu, QuickNotesFileMenu, Add, E&xit`tCtrl+W, _QuickNotes_GUIExit
	Menu, QuickNotesMenuBar, Add, &File, :QuickNotesFileMenu 
	Gui, QuickNotes:Menu, QuickNotesMenuBar

	Gui, Show
}


;;;; Soft-Lock (Only works when run as Admin)

SoftLock_UnBlock() {
	BlockInput, Off
	Menu, ActionsMenu, Delete, [SoftLock] Block Input
	Menu, ActionsMenu, Add, [SoftLock] Block Input, SoftLock_Block
}

SoftLock_Block() {
	Sleep, 500
	Menu, ActionsMenu, Delete, [SoftLock] Block Input
	Menu, ActionsMenu, Add, [SoftLock] Block Input, SoftLock_UnBlock
	Menu, ActionsMenu, Check, [SoftLock] Block Input
	BlockInput On
}


;;;; Random

HoldLeftMouse() {
	Click, Down Left
}

HoldRightMouse() {
	Click, Down Right
}

PasteDateTime() {
	format := _GetSetting("DATETIMEFORMAT", _Settings_Data, _DEFAULTSETTINGS)
	FormatTime, currentdatetime,, %format%
	SendInput, %currentdatetime%
}

Screenshot() {
	Send, +#s
}

;;;; Settings

_Settings_GUISave() {
	Gui, Settings:Submit
	_OverwriteFile("hotkey-urls.txt", _Settings_GUIUrlShortcutEdit)
	_OverwriteFile("hotkey-keybinds.txt", _Settings_GUIHotkeyEdit)
	_OverwriteFile("hotkey-hotstrings.txt", _Settings_GUIHotstringEdit)
	_OverwriteFile("hotkey-settings.txt", _Settings_GUISettingsEdit)
	Reload
}

_Settings_GUIExit() {
	Gui, Settings:Destroy
}

Settings_Open() {
	Gui, Settings:New, , Settings
	Gui, Settings: +AlwaysOnTop
	

	Gui, Settings:Add, Link, Y5 X5, Edit URL shortcodes: <a href="https://github.com/rafaelurben/autohotkey-utils/#create-url-shortcodes">Syntax and Infos</a>
	Gui, Settings:Add, Edit, R15 W500 v_Settings_GUIUrlShortcutEdit
	FileRead, FileContent, hotkey-urls.txt
	GuiControl,, _Settings_GUIUrlShortcutEdit, %FileContent%

	Gui, Settings:Add, Link, , Edit Keybinds: <a href="https://github.com/rafaelurben/autohotkey-utils/#modify-keybinds">Syntax and Infos</a>
	Gui, Settings:Add, Edit, R15 W500 v_Settings_GUIHotkeyEdit
	FileRead, FileContent, hotkey-keybinds.txt
	GuiControl,, _Settings_GUIHotkeyEdit, %FileContent%

	Gui, Settings:Add, Text, , Press Ctrl+S to save and reload or Ctrl+W to exit without saving.

	Gui, Settings:Add, Link, Y5 X515 , Edit Hotstrings: <a href="https://github.com/rafaelurben/autohotkey-utils/#create-hotstrings">Syntax and Infos</a>
	Gui, Settings:Add, Edit, R15 W500 v_Settings_GUIHotstringEdit
	FileRead, FileContent, hotkey-hotstrings.txt
	GuiControl,, _Settings_GUIHotstringEdit, %FileContent%

	Gui, Settings:Add, Link, , Edit Settings: <a href="https://github.com/rafaelurben/autohotkey-utils/#settings">Syntax and Infos</a>
	Gui, Settings:Add, Edit, R15 W500 v_Settings_GUISettingsEdit
	FileRead, FileContent, hotkey-settings.txt
	GuiControl,, _Settings_GUISettingsEdit, %FileContent%

	Gui, Settings:Add, Link, , <a href="%A_WorkingDir%">Open Folder</a> (Please do NOT edit files while the settings are opened!)


	Menu, SettingsFileMenu, Add, &Save`tCtrl+S, _Settings_GUISave 
	Menu, SettingsFileMenu, Add, E&xit`tCtrl+W, _Settings_GUIExit
	Menu, SettingsMenuBar, Add, &File, :SettingsFileMenu 
	Gui, Settings:Menu, SettingsMenuBar

	Gui, Show
}


;;;;;;;;;;; Main

_CreateTrayMenu() {
	Menu, UrlShortcutsMenu, Add, Insert, UrlShortcuts_BoxInsert
	Menu, UrlShortcutsMenu, Add, Open, UrlShortcuts_BoxOpen
	Menu, QRGeneratorMenu, Add, Create from input, QRGenerator_InputBox
	Menu, QRGeneratorMenu, Add, Create from clipbaord, QRGenerator_FromClipboard
	Menu, InstantSearchMenu, Add, Search 1, InstantSearch_1
	Menu, InstantSearchMenu, Add, Search 2, InstantSearch_2
	Menu, InstantSearchMenu, Add, Search 3, InstantSearch_3
	Menu, InstantSearchMenu, Add
	Menu, InstantSearchMenu, Add, Search 1 from clipboard, InstantSearch_1_Clipboard
	Menu, InstantSearchMenu, Add, Search 2 from clipboard, InstantSearch_2_Clipboard
	Menu, InstantSearchMenu, Add, Search 3 from clipboard, InstantSearch_3_Clipboard
	Menu, ActionsMenu, Add, Close a Process, CloseProcess
	Menu, ActionsMenu, Add
	Menu, ActionsMenu, Add, [QRGenerator], :QRGeneratorMenu
	Menu, ActionsMenu, Add, [InstantSearch], :InstantSearchMenu
	Menu, ActionsMenu, Add, [UrlShortcuts], :UrlShortcutsMenu
	Menu, ActionsMenu, Add
	Menu, ActionsMenu, Add, [QuickNotes] Open, QuickNotes_Open
	Menu, ActionsMenu, Add, [SoftLock] Block Input, SoftLock_Block
	Menu, Tray, Add
	Menu, Tray, Add, Reload, ReloadFiles
	Menu, Tray, Add, Settings, Settings_Open
	Menu, Tray, Add, Check for updates, CheckForUpdate
	Menu, Tray, Add
	Menu, Tray, Add, Actions, :ActionsMenu
	Menu, Tray, Add, Screenshot, Screenshot
}

_RegisterHotkeys() {
	for function, _ in _DEFAULTKEYBINDS
	{
		if IsFunc(function) {
			shortcut := _GetSetting(function, _Keybinds_Data, _DEFAULTKEYBINDS)

			if (shortcut != "") {
				try {
					Hotkey, %shortcut%, %function%, On
				} catch {
					MsgBox, 0, Hotkey Error, Couldn't create shortcut "%shortcut%" for action "%function%".
				}
			}
		} else {
			MsgBox, 0, Hotkey Error, Unknown action: "%function%".
		}
	}
}

_RegisterHotstrings() {
	hotstrings := _LoadDictFromFile("hotkey-hotstrings.txt")

	for key, value in hotstrings
	{
		try {
			Hotstring(key, value, On)
		} catch {
			MsgBox, 0, Hotstring Error, Invalid hostring: ("%key%" -> "%value%").
		}
	}
}
