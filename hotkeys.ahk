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
Menu, Controls, Add, Unblock Input, UnblockInput
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

UnblockInput()
{
	BlockInput, Off
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

;; Urls
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

;; Open Clipboard URL

#o::OpenUrl(Clipboard)

^#o::OpenUrlEditor(Clipboard)

+#o::OpenUrlEditor("https://")

;; Soft-Lock (If Run As Admin)

+#l::BlockInput On
