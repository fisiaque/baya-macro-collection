; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; -- pre-check
if not A_IsAdmin {
    try {
        Run '*RunAs ' A_ScriptFullPath '',, 'Hide'
        ExitApp
    } catch as e {
        ExitApp
    }
}

; -- includes
#Include modules\FileInstaller.ahk
#Include modules\Miscellaneous.ahk
#Include modules\OutputConsole.ahk

print("[main] Modules Initialized")

TraySetIcon(EnvGet("Icon"))

Persistent
OnExit ExitFunction

; variables
env := FileExist(A_WorkingDir "\.env") and A_WorkingDir "\.env" or "..\..\.env"

discord_Token := quoted(FileReadLine(env, 1)), 'Quoted', 'Iconi'
discord_UserId := quoted(FileReadLine(env, 2)), 'Quoted', 'Iconi'
discord_WebhookURL := quoted(FileReadLine(env, 3)), 'Quoted', 'Iconi'
bot_Loaded := quoted(FileReadLine(env, 4)), 'Quoted', 'Iconi'
bot_Shutdown := quoted(FileReadLine(env, 5)), 'Quoted', 'Iconi'

; checks
checkBot := DiscordBotCheck.Bind(discord_Token)

SetTimer(checkBot, -50)
