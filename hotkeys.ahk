; Rafael Urben, 2021
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;; Initialize

Menu, Controls, Add, [UrlShortcuts] Reload, UrlShortcutsReloadUrls
Menu, Controls, Add, [SoftLock] Block Input, SoftLockBlock
Menu, Tray, Add, Settings, SettingsGUIOpen
Menu, Tray, Add, Controls, :Controls

UrlShortcutsReloadUrls()

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

OpenUrl(url)
{
	try {
		Run, %url%
	} catch e {
		MsgBox, 0, Opening URL failed, Can't open "%url%"! Is this a valid url?
	}
	return
}

OpenUrlEditor(defaultUrl="https://")
{
	InputBox, url, Open URL, Please enter your url:, , , , , , , , %defaultUrl%
	If !ErrorLevel
		OpenUrl(url)
	return
}

;;;; Url-Shortcuts

Global UrlShortcutsData := {}

UrlShortcutsReloadUrls() 
{
	Global UrlShortcutsData := {}
	Loop, Read, hotkey-urls.txt
		{
			row := StrSplit(A_LoopReadLine, "|")
			key := row[1]
			val := row[2]
			UrlShortcutsData[key] := val
		}
}

;; Insert Urls (L=2, Input)

UrlShortcutsInsert()
{
	Input, key, L2 T2
	if UrlShortcutsData.HasKey(key)
		Send, % UrlShortcutsData[key]
	else If key
		MsgBox, 0, Insert URL, Unknown shortcut: "%key%"
	return
}

;; Open Urls (L=2, Input)

UrlShortcutsOpen()
{
	Input, key, L2 T2
	if UrlShortcutsData.HasKey(key)
		OpenUrl(UrlShortcutsData[key])
	else If key
		MsgBox, 0, Open URL, Unknown shortcut: "%key%"
	return
}

;; Insert urls (InputBox)

UrlShortcutsBoxInsert()
{
	InputBox, key, Insert URL, Please enter shortcode:
	if UrlShortcutsData.HasKey(key)
		Send, % UrlShortcutsData[key]
	else If key
		MsgBox, 0, Insert URL, Unknown key: "%key%"
	return
}

;; Open urls (InputBox)

UrlShortcutsBoxOpen()
{
	InputBox, key, Open URL, Please enter shortcode:
	if UrlShortcutsData.HasKey(key)
		OpenUrl(UrlShortcutsData[key])
	else If key
		MsgBox, 0, Open URL, Unknown key: "%key%"
	return
}


;;;; Instant-Search

InstantSearch(engineName, engineUrl)
{
	InputBox, search, Search on %engineName%, Please enter your query:
	url = %engineUrl%%search%
	If !ErrorLevel
		OpenUrl(url)
	return
}

InstantSearchDuckDuckGo()
{ 
	InstantSearch("DuckDuckGo", "https://duckduckgo.com/?q=")
}

InstantSearchGoogle()
{
	InstantSearch("Google", "https://google.com/search?q=")
}


;;;; Clipboard-Url-Opener

ClipBoardUrlOpenerOpen() 
{ 	
	OpenUrl(Clipboard)
}
ClipBoardUrlOpenerOpenEditor() 
{
	OpenUrlEditor(Clipboard)
}


;;;; Quick-Notes

Global QuickNotesGUITextEdit

QuickNotesQuickCreate()
{
	InputBox, note, QuickNote, Please enter a text to create a note:
	if note
		FileAppend, `n%note%, hotkey-notes.txt
}

QuickNotesGUISave()
{
	Gui, QuickNotes:Submit
	file := FileOpen("hotkey-notes.txt", "w")
	file.Write(QuickNotesGUITextEdit)
	file.Close()
}

QuickNotesGUIReset()
{
	Gui, QuickNotes:Submit
	file := FileOpen("hotkey-notes.txt", "w")
	file.Close()
	QuickNotesGUIOpen()
}

QuickNotesGUIExit()
{
	Gui, QuickNotes:Destroy
}

QuickNotesGUIOpen() 
{
	Gui, QuickNotes:New, , QuickNotes
	Gui, QuickNotes:Add, Text, , Edit your notes:

	Gui, QuickNotes:Add, Edit, R20 W500 vQuickNotesGUITextEdit
	FileRead, FileContent, hotkey-notes.txt
	GuiControl,, QuickNotesGUITextEdit, %FileContent%

	Menu, FileMenu, Add, &Save`tCtrl+S, QuickNotesGUISave
	Menu, FileMenu, Add, &Reset`tCtrl+R, QuickNotesGUIReset
	Menu, FileMenu, Add, E&xit`tCtrl+W, QuickNotesGUIExit
	Menu, MenuBar, Add, &File, :FileMenu 
	Gui, QuickNotes:Menu, MenuBar

	Gui, Show
}


;;;; Soft-Lock (Only works when run As Admin)

SoftLockUnBlock()
{
	BlockInput, Off
	Menu, Controls, Delete, [SoftLock] Block Input
	Menu, Controls, Add, [SoftLock] Block Input, SoftLockBlock
}

SoftLockBlock()
{
	Sleep, 500
	Menu, Controls, Delete, [SoftLock] Block Input
	Menu, Controls, Add, [SoftLock] Block Input, SoftLockUnBlock
	Menu, Controls, Check, [SoftLock] Block Input
	BlockInput On
}


;;;; Settings

Global SettingsGUIShortcutEdit

SettingsGUISave()
{
	Gui, Settings:Submit
	file := FileOpen("hotkey-urls.txt", "w")
	file.Write(SettingsGUIShortcutEdit)
	file.Close()
	UrlShortcutsReloadUrls()
}

SettingsGUIExit()
{
	Gui, Settings:Destroy
}

SettingsGUIOpen() 
{
	Gui, Settings:New, , Settings
	Gui, Settings:Add, Text, , Edit URL shortcuts: (Format: "Shortcut|URL" -> one per line)

	Gui, Settings:Add, Edit, R20 W500 vSettingsGUIShortcutEdit
	FileRead, FileContent, hotkey-urls.txt
	GuiControl,, SettingsGUIShortcutEdit, %FileContent%

	Menu, FileMenu, Add, &Save`tCtrl+S, SettingsGUISave 
	Menu, FileMenu, Add, E&xit`tCtrl+W, SettingsGUIExit
	Menu, MenuBar, Add, &File, :FileMenu 
	Gui, Settings:Menu, MenuBar

	Gui, Show
}


;;;;;;;;;;; Shortcuts

Insert::UrlShortcutsInsert()
+Insert::UrlShortcutsOpen()
^Insert::UrlShortcutsBoxInsert()
+^Insert::UrlShortcutsBoxOpen()

#q::InstantSearchDuckDuckGo()
+#q::InstantSearchGoogle()

#o::ClipBoardUrlOpenerOpen()
^#o::ClipBoardUrlOpenerOpenEditor()
+#o::OpenUrlEditor()

#n::QuickNotesQuickCreate()
^#n::QuickNotesGUIOpen()

+#l::SoftLockBlock()
