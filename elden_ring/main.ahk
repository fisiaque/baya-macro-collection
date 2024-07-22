; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Off

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

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

; -- includes
#Include modules\Initialize.ahk
#Include modules\Version.ahk
#Include modules\OutputConsole.ahk
#Include modules\FileInstaller.ahk
#Include modules\Miscellaneous.ahk
#Include modules\Hotkeys.ahk
#Include modules\GUI.ahk
#Include modules\Github.ahk
#Include modules\Game.ahk

print("[main] Modules Initialized")

OnExit ExitFunction

OnMessage(_msg_Num.Close, PostAsyncProc)
OnMessage(_msg_Num.WM_COPYDATA, PostAsyncProc)

; variables
_status := Object()

_status._halt := 0
_status._running := 0
_status._auto_log := 0
_status._macro := 0
_status._bot := ""

discord_env := A_WorkingDir "\discord.env" 

discord_Token := quoted(FileReadLine(discord_env, 1))

; checks
GithubUpdate() ; checks if macro up to date

checkBot := DiscordBotCheck.Bind(discord_Token)

SetTimer(checkBot, -50)
SetTimer(Checks, 1000)

; hotkeys
SC01B::ExitApp ; stop

SC01A::_start_ ; start[]
