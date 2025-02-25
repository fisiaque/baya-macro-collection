; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Force

Persistent
DetectHiddenWindows True

; variables
global file_extensions := ['jpg','jpeg','png','gif','ico','exe']

_ini := Object()
_game := Object()
_status := Object()
_discord := Object()

_game.Title := "Google Chrome"
_game.PID := ""

_status._bot := ""
_status._start_script := A_TickCount

_ini.DiscordUserId := FileRead(A_WorkingDir "\DiscordUserId.txt")
_ini.DiscordWebhookURL := FileRead(A_WorkingDir "\DiscordWebhook.txt")

; -- includes
#Include modules\Game.ahk
#Include modules\Version.ahk
#Include modules\OutputConsole.ahk
#Include modules\Hotkeys.ahk
#Include modules\FileInstaller.ahk
#Include modules\Miscellaneous.ahk

; start
print("[main(" Format_Msec(A_TickCount - _status._start_script) ") Modules Initialized")

OnExit ExitFunction

; hotkeys
~SC01B::ExitApp ; stopM

#HotIf _game.PID := WinExist(_game.Title) or print("[main(" Format_Msec(A_TickCount - _status._start_script) ")] Fortnite | Xbox Cloud Gaming (Beta) on Xbox.com - Google Chrome not running")

~SC01A::_start_ ; start[