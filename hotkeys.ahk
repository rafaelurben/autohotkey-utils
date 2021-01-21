; Rafael Urben, 2021
; ------------------
;
; https://github.com/rafaelurben/autohotkey-utils

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;; Initialize

Menu, Controls, Add, Reload hotkey-urls.txt, LoadUrls
Menu, Tray, Add, Settings, UtilsGUIOpen
Menu, Tray, Add, Controls, :Controls

LoadUrls()

;; Functions

LoadUrls() 
{
	Global urls := {}
	Loop, Read, hotkey-urls.txt
		{
			row := StrSplit(A_LoopReadLine, "|")
			key := row[1]
			val := row[2]
			urls[key] := val
		}
}

OpenUrl(url)
{
	try {
		Run, %url%
	} catch e {
		MsgBox, 0, Opening URL failed, Can't open "%url%"! Is this a valid url?
	}
	return
}

OpenUrlEditor(defaultUrl)
{
	InputBox, url, Open URL, Please enter your url:, , , , , , , , %defaultUrl%
	If !ErrorLevel
		OpenUrl(url)
	return
}

OpenSearch(engineName, engineUrl)
{
	InputBox, search, Search on %engineName%, Please enter your query:
	url = %engineUrl%%search%
	If !ErrorLevel
		OpenUrl(url)
	return
}

;; Debug
; Auto-reload

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

;; Urls-Shortcuts
; Paste Urls (L=2, Input)

Insert::
{
	Input, key, L2 T2
	if urls.HasKey(key)
		Send, % urls[key]
	else If key
		MsgBox, 0, Insert URL, Unknown key: "%key%"
	return
}

; Open Urls (L=2, Input)

+Insert::
{
	Input, key, L2 T2
	if urls.HasKey(key)
		OpenUrl(urls[key])
	else If key
		MsgBox, 0, Open URL, Unknown key: "%key%"
	return
}

; Paste urls (InputBox)

^Insert::
{
	InputBox, key, Insert URL, Please enter shortcode:
	if urls.HasKey(key)
		Send, % urls[key]
	else If key
		MsgBox, 0, Insert URL, Unknown key: "%key%"
	return
}

; Open urls (InputBox)

+^Insert::
{
	InputBox, key, Open URL, Please enter shortcode:
	if urls.HasKey(key)
		OpenUrl(urls[key])
	else If key
		MsgBox, 0, Open URL, Unknown key: "%key%"
	return
}

;; Search

#q::OpenSearch("DuckDuckGo", "https://duckduckgo.com/?q=")

+#q::OpenSearch("Google", "https://google.com/search?q=")

;; Clipboard-URL-Opener

#o::OpenUrl(Clipboard)

^#o::OpenUrlEditor(Clipboard)

+#o::OpenUrlEditor("https://")

;; Soft-Lock (If Run As Admin)

UnblockInput()
{
	BlockInput, Off
	Menu, Controls, Delete, Unblock Input
}

+#l::
{
	Sleep, 500
	Menu, Controls, Add, Unblock Input, UnblockInput
	BlockInput On
}

;;;; GUI Editor

Global UtilsGUIShortcutEdit

UtilsGUISave()
{
	Gui, Settings:Submit
	file := FileOpen("hotkey-urls.txt", "w")
	file.Write(UtilsGUIShortcutEdit)
	file.Close()
	LoadUrls()
}

UtilsGUIExit()
{
	Gui, Settings:Destroy
}

UtilsGUIOpen() 
{
	Gui, Settings:New, , Settings
	Gui, Settings:Add, Text, , Edit URL shortcuts: (Format: "Shortcut|URL" -> one per line)

	Gui, Settings:Add, Edit, R20 W500 vUtilsGUIShortcutEdit
	FileRead, FileContent, hotkey-urls.txt
	GuiControl,, UtilsGUIShortcutEdit, %FileContent%

	Menu, FileMenu, Add, &Save`tCtrl+S, UtilsGUISave 
	Menu, FileMenu, Add, E&xit`tCtrl+W, UtilsGUIExit
	Menu, MyMenuBar, Add, &File, :FileMenu 
	Gui, Settings:Menu, MyMenuBar

	Gui, Show
}
