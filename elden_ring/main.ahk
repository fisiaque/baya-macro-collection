; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; -- pre-check
RunAsTask()

if not A_IsAdmin {
    try {
        Run '*RunAs ' A_ScriptFullPath '',, 'Hide'
        ExitApp
    } catch as e {
        ExitApp
    }
}

; -- includes
#Include modules\Version.ahk
#Include modules\OutputConsole.ahk
#Include modules\FileInstaller.ahk
#Include modules\Miscellaneous.ahk
#Include modules\Hotkeys.ahk
#Include modules\Game.ahk
#Include modules\GUI.ahk
#Include modules\Github.ahk

print("[main] Modules Initialized")

TraySetIcon(EnvGet("Icon"))

Persistent
OnExit ExitFunction

; variables
env := FileExist(A_WorkingDir "\.env") and A_WorkingDir "\.env" or "..\.env"
discord_Token := quoted(FileReadLine(env, 1)), 'Quoted', 'Iconi'

; checks
GithubUpdate() ; checks if macro up to date

checkBot := DiscordBotCheck.Bind(discord_Token)

SetTimer(checkBot, -50)

; hotkeys
SC01B::_stop_ ; stop

#HotIf WinActive("ELDEN RING™") ; Any Scripts After Will Only Run If __game__ is Active

SC01A::_start_ ; start