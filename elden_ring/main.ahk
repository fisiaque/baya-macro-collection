; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Off

Persistent
DetectHiddenWindows True

_msg_Num := Object()
_msg_Num.Close := DllCall("RegisterWindowMessage", "Str", "CloseAHKScript")
_msg_Num.WM_COPYDATA := 0x004A ; -- WM_COPYDATA 

; set icon using dll
if FileExist(A_WorkingDir "\icons.dll") {
    FileDelete(A_WorkingDir "\icons.dll")
} 

FileInstall ".\DLL\icons.dll", A_WorkingDir "\icons.dll", 1
FileSetAttrib "+H", A_WorkingDir "\icons.dll"

TraySetIcon "icons.dll", 1 ; 1 = Baya_Icon | 2 = Ricon_Icon

FileDelete(A_WorkingDir "\icons.dll")

; variables
_game := Object()
_status := Object()
_discord := Object()

_game.Title := "ELDEN RING™"
_game.PID := ""

_status._bot := ""
_status._start_script := A_TickCount

; -- includes
#Include modules\Initialize.ahk
#Include modules\Version.ahk
#Include modules\OutputConsole.ahk
#Include modules\FileInstaller.ahk
#Include modules\Miscellaneous.ahk
#Include modules\Hotkeys.ahk
#Include modules\GUI.ahk
#Include modules\Github.ahk
#Include modules\Checks.ahk
#Include modules\Commands.ahk
#Include modules\Game.ahk

print("[main(" Format_Msec(A_TickCount - _status._start_script) ") Modules Initialized")

OnExit ExitFunction

OnMessage(_msg_Num.Close, PostAsyncProc)
OnMessage(_msg_Num.WM_COPYDATA, PostAsyncProc)

_discord.env := A_WorkingDir "\discord.env" 
_discord.token := quoted(FileReadLine(_discord.env, 1))
_discord.loading := 0

checkBot := DiscordBotCheck.Bind(_discord.token)
SetTimer(checkBot, -50)

; latest version?
GithubUpdate() ; checks if macro up to date

; hotkeys
~SC01B::ExitApp ; stopM

#HotIf _game.PID := WinExist(_game.Title) or print("[main(" Format_Msec(A_TickCount - _status._start_script) ")] Elden Ring not running")

~SC01A::_start_ ; start[]
