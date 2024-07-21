; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Off

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

Persistent
DetectHiddenWindows True

; set icon using dll
if FileExist(A_WorkingDir "\icons.dll") {
    FileDelete(A_WorkingDir "\icons.dll")
} 

FileInstall ".\DLL\icons.dll", A_WorkingDir "\icons.dll", 1
FileSetAttrib "+H", A_WorkingDir "\icons.dll"

TraySetIcon "icons.dll", 1 ; 1 = Baya_Icon | 2 = Ricon_Icon

FileDelete(A_WorkingDir "\icons.dll")

MsgBox "HWD: " 

; -- pre-functions
Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
{
    StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
    
    MsgBox CopyOfData
    MsgBox msg

    if CopyOfData == "Close" and hwnd == A_ScriptHwnd {
        ExitApp
    }
    
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}
Send_WM_COPYDATA(StringToSend, TargetScriptTitle)
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
    CopyDataStruct := Buffer(3*A_PtrSize)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut( "Ptr", SizeInBytes  ; OS requires that this be done.
          , "Ptr", StrPtr(StringToSend)  ; Set lpData to point to the string itself.
          , CopyDataStruct, A_PtrSize)
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows True
    SetTitleMatchMode 2
    TimeOutTime := 4000  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    ; Must use SendMessage not PostMessage.
    RetValue := SendMessage(0x004A, 0, CopyDataStruct,, TargetScriptTitle,,,, TimeOutTime) ; 0x004A is WM_COPYDATA.
    DetectHiddenWindows Prev_DetectHiddenWindows  ; Restore original setting for the caller.
    SetTitleMatchMode Prev_TitleMatchMode         ; Same.
    return RetValue  ; Return SendMessage's reply back to our caller.
}

CloseRunningScripts() {
    static _count := 0

    _count += 1

    For hWnd in arr := WinGetList(A_WorkingDir "\" A_ScriptName) {
        if hWnd != A_ScriptHwnd {
            _check := Send_WM_COPYDATA("Close", hWnd)

            if _count < 3 and _check != 1 {
                CloseRunningScripts()
            } else if _check != 1 {
                ExitApp
            } else {
                _count := 0
            }
        }
    }
}
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

; close all other running scripts 
CloseRunningScripts()

; -- includes
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

OnMessage 0x004A, Receive_WM_COPYDATA  ; 0x004A is WM_COPYDATA

; variables
_status := Object()

_status._halt := 0
_status._running := 0
_status._auto_log := 0
_status._macro := 0

if !A_IsCompiled and !FileExist("..\.env") { ; if .env doesn't exist on source, create one
    FileAppend "discord_Token = ''", "..\.env"
}

discord_env := !A_IsCompiled and "..\.env" or A_WorkingDir "\discord.env" 

discord_Token := quoted(FileReadLine(discord_env, 1))

; checks
GithubUpdate() ; checks if macro up to date

checkBot := DiscordBotCheck.Bind(discord_Token)

SetTimer(checkBot, -50)
SetTimer(Checks, 1000)

; hotkeys
SC01B::ExitApp ; stop

SC01A::_start_ ; start[]
