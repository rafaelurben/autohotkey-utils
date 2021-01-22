; Rafael Urben, 2021
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;; Variables

Global defaultkeybinds :=
(   
"UrlShortcuts_Insert|Insert
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
OpenUrl|+#o"
)

Global _UrlShortcuts_Data
Global _QuickNotes_GUITextEdit
Global _Settings_GUIUrlShortcutEdit
Global _Settings_GUIHotkeyEdit


;; Initialize

Menu, Controls, Add, Reload files, ReloadFiles
Menu, Controls, Add, [SoftLock] Block Input, SoftLock_Block
Menu, Tray, Add, Settings, Settings_Open
Menu, Tray, Add, Controls, :Controls

UrlShortcuts_ReloadUrls()
_RegisterHotkeys()
_RegisterHotstrings()

;;;; Debug
;; Auto-reload

~^s:: 
{
	IfWinActive, %A_ScriptName% 
		{ 
			SplashTextOn,,,Updated script, 
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

;; Public

ReloadFiles() {
	Reload
}

OpenUrl() {
	_OpenUrlEditor("https://")
}

;;;; Url-Shortcuts

UrlShortcuts_ReloadUrls()  {
	Global _UrlShortcuts_Data := _LoadDictFromFile("hotkey-urls.txt")
}

;; Insert Urls (L=2, Input)

UrlShortcuts_Insert() {
	Input, key, L2 T2
	if _UrlShortcuts_Data.HasKey(key)
		Send, % _UrlShortcuts_Data[key]
	else If key
		MsgBox, 0, Insert URL, Unknown shortcut: "%key%"
	return
}

;; Open Urls (L=2, Input)

UrlShortcuts_Open() {
	Input, key, L2 T2
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


;;;; Instant-Search

_InstantSearch(engineName, engineUrl) {
	InputBox, search, Search on %engineName%, Please enter your query:
	url = %engineUrl%%search%
	If !ErrorLevel
		_OpenUrl(url)
	return
}

InstantSearch_DuckDuckGo() { 
	_InstantSearch("DuckDuckGo", "https://duckduckgo.com/?q=")
}

InstantSearch_Google() {
	_InstantSearch("Google", "https://google.com/search?q=")
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
	Gui, QuickNotes:Add, Text, , Edit your notes:

	Gui, QuickNotes:Add, Edit, R20 W500 v_QuickNotes_GUITextEdit
	FileRead, FileContent, hotkey-notes.txt
	GuiControl,, _QuickNotes_GUITextEdit, %FileContent%

	Menu, FileMenu, Add, &Save`tCtrl+S, _QuickNotes_GUISave
	Menu, FileMenu, Add, &Reset`tCtrl+R, _QuickNotes_GUIReset
	Menu, FileMenu, Add, E&xit`tCtrl+W, _QuickNotes_GUIExit
	Menu, MenuBar, Add, &File, :FileMenu 
	Gui, QuickNotes:Menu, MenuBar

	Gui, Show
}


;;;; Soft-Lock (Only works when run As Admin)

SoftLock_UnBlock() {
	BlockInput, Off
	Menu, Controls, Delete, [SoftLock] Block Input
	Menu, Controls, Add, [SoftLock] Block Input, SoftLock_Block
}

SoftLock_Block() {
	Sleep, 500
	Menu, Controls, Delete, [SoftLock] Block Input
	Menu, Controls, Add, [SoftLock] Block Input, SoftLock_UnBlock
	Menu, Controls, Check, [SoftLock] Block Input
	BlockInput On
}


;;;; Settings

_Settings_GUISave() {
	Gui, Settings:Submit
	_OverwriteFile("hotkey-urls.txt", _Settings_GUIUrlShortcutEdit)
	_OverwriteFile("hotkey-keybinds.txt", _Settings_GUIHotkeyEdit)
	Reload
}

_Settings_GUIExit() {
	Gui, Settings:Destroy
}

Settings_Open() {
	Gui, Settings:New, , Settings

	Gui, Settings:Add, Text, , Edit URL shortcodes: (Format: "Shortcode|URL" -> one per line)
	Gui, Settings:Add, Edit, R20 W500 v_Settings_GUIUrlShortcutEdit
	FileRead, FileContent, hotkey-urls.txt
	GuiControl,, _Settings_GUIUrlShortcutEdit, %FileContent%

	Gui, Settings:Add, Link, , Edit Keybinds: (Format: "Action|Keybind") <a href="https://github.com/rafaelurben/autohotkey-utils/#modify-keybinds">Help</a>
	Gui, Settings:Add, Edit, R15 W500 v_Settings_GUIHotkeyEdit
	FileRead, FileContent, hotkey-keybinds.txt
	GuiControl,, _Settings_GUIHotkeyEdit, %FileContent%

	Menu, FileMenu, Add, &Save`tCtrl+S, _Settings_GUISave 
	Menu, FileMenu, Add, E&xit`tCtrl+W, _Settings_GUIExit
	Menu, MenuBar, Add, &File, :FileMenu 
	Gui, Settings:Menu, MenuBar

	Gui, Show
}


;;;;;;;;;;; Shortcuts

_RegisterHotkeys() {
	if !FileExist("hotkey-keybinds.txt") {
		_OverwriteFile("hotkey-keybinds.txt", defaultkeybinds)
	}

	keybinds := _LoadDictFromFile("hotkey-keybinds.txt")

	for function, shortcut in keybinds
	{
		try {
			Hotkey, %shortcut%, %function%, On
		} catch {
			MsgBox, 0, Hotkey Error, Unknown shortcut (%shortcut%) or action (%function%).
		}
	}
}

_RegisterHotstrings() {
	hostrings := _LoadDictFromFile("hotkey-hotstrings.txt")

	for key, value in hostrings
	{
		try {
			Hotstring(%key%, %value%, On)
		} catch {
			MsgBox, 0, Hotstring Error, Couldn't add Hostring! (%key%) -> (%value%).
		}
	}
}
