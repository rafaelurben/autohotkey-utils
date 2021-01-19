#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Rafael Urben, 2021
; -----------------
;
; https://github.com/rafaelurben/autohotkey-utils

; --------------------------------------------------------------------------------------

;; Variables
; Urls

urls := {}
Loop, Read, hotkey-urls.txt
{
	row := StrSplit(A_LoopReadLine, "|")
	key := row[1]
	val := row[2]
	urls[key] := val
}

;; Debug
; Auto-reload

~^s:: 
  IfWinActive, %A_ScriptName% 
    { 
       SplashTextOn,,,Updated script, 
       Sleep, 500 
       SplashTextOff 
       Reload 
    } 
return

;; Urls
; Paste Urls (L=2, Input)

Insert::
{
	Input, key, L2 T2
	if urls.HasKey(key)
		Send, % urls[key]
	Else If key
		MsgBox, Unknown key: %key%
	Return
}

; Open Urls (L=2, Input)

+Insert::
{
	Input, key, L2 T2
	if urls.HasKey(key)
		try {
			Run, % urls[key]
		} catch e {
			MsgBox, Can't open url!
		}
	Else If key
		MsgBox, Unknown key: %key%
	Return
}

; Paste urls (InputBox)

^Insert::
{
	InputBox, key, Paste URL, Please enter shortcode:
	if urls.HasKey(key)
		Send, % urls[key]
	Else If key
		MsgBox, Unknown key: %key%
	Return
}

; Open urls (InputBox)

+^Insert::
{
	InputBox, key, Open URL, Please enter shortcode:
	if urls.HasKey(key)
		try {
			Run, % urls[key]
		} catch e {
			MsgBox, Can't open url!
		}
	Else If key
		MsgBox, Unknown key: %key%
	Return
}

;; Search

#q::
{
	InputBox, search, Search on DuckDuckGo, Please enter your search:
	If !ErrorLevel
		Run, "https://duckduckgo.com/?q=%search%"
	Return
}

+#q::
{
	InputBox, search, Search on Google, Please enter your search:
	If !ErrorLevel
		Run, "https://google.com/search?q=%search%"
	Return
}