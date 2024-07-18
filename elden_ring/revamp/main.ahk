#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include modules\FileInstaller.ahk
#Include modules\FileReadLine.ahk
#Include modules\Misc.ahk

TraySetIcon(EnvGet("Icon"))

Persistent
OnExit ExitFunction

; checks
if CheckBotNotActive() == 1 {
    Run(EnvGet("BayaMacroBot"))
}

; variables
env := FileExist(A_WorkingDir "\.env") and A_WorkingDir "\.env" or "..\..\.env"

discord_Token := quoted(FileReadLine(env, 1)), 'Quoted', 'Iconi'
discord_UserId := quoted(FileReadLine(env, 2)), 'Quoted', 'Iconi'
discord_WebhookURL := quoted(FileReadLine(env, 3)), 'Quoted', 'Iconi'
game_AutoFarmMethod := quoted(FileReadLine(env, 4)), 'Quoted', 'Iconi'

;Sleep 2500

;if WinExist("BayaMacroBot.exe") {
;    WinClose
;}
