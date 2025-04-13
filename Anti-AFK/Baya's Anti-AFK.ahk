#Requires AutoHotkey v2.0
#SingleInstance Force

; +================================================================+
; |___  ____ _   _ ____ . ____    ____ _  _ ___ _    ____ ____ _  _|
; ||__] |__|  \_/  |__| ' [__     |__| |\ |  |  | __ |__| |___ |_/ |
; ||__] |  |   |   |  |   ___]    |  | | \|  |  |    |  | |    | \_|
; +================================================================+

;   Programs --> Executables that the target processes run under (array)
;   Timeout  --> Idle time required for Anti-AFK to start (minutes)
;   Delay    --> Time between Anti-AFK's actions (minutes)
;   Poll     --> Time interval for polling whether the process is running (seconds)

;==================================================
; Hotkey to Exit
;==================================================
End::ExitApp

;==================================================
; Editable Variables
;==================================================
Programs := ["RobloxPlayerBeta.exe"]
Timeout  := 1       ; in minutes
Delay    := 15      ; in minutes
Poll     := 5       ; in seconds

;==================================================
; Non-Editable Variables
;==================================================
Tray := A_TrayMenu
tray_icon := ""
Timeout   *= 60     ; convert to seconds
Delay     *= 60
poll_ms   := Poll * 1000

;==================================================
; Tooltip Texts (Customisable)
;==================================================
disabled_tooltip := "No Windows Found`nPress END to exit"
idle_tooltip     := "Anti AFK"
active_tooltip   := "Anti-AFK Active`nPress END to exit"

;==================================================
; DLL Calls
;==================================================
full_command_line := DllCall("GetCommandLine", "str")

;==================================================
; Prompt to Run as Admin
;==================================================
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    admin_title := "Run as Admin?"
    admin_message := "
    (
        Anti-AFK has the option to temporarily block
        keystrokes when running as Admin.

        This is optional but be aware keystrokes may
        leak into the target window if you are typing
        whilst Anti-AFK is interacting with it.
    )"

    result := MsgBox(admin_message, admin_title, "Y/N T4")

    if (result = "Yes")
    {
        try
        {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
        ExitApp
    }
}

;==================================================
; Function: Reset AFK Timer
;==================================================
ResetTimer()
{
    SendInput("{h Down}")
    Sleep(50)
    SendInput("{h Up}")
}

;==================================================
; Tray Icon Functions
;==================================================
TrayScriptDisabled()
{
    global tray_icon
    if (tray_icon = "ScriptDisabled")
        return

    tray_icon := "ScriptDisabled"
    A_IconTip := disabled_tooltip
    TraySetIcon(A_AhkPath, 4, 1)
}

TrayScriptIdle()
{
    global tray_icon
    if (tray_icon = "ScriptIdle")
        return

    tray_icon := "ScriptIdle"
    A_IconTip := idle_tooltip
    TraySetIcon(A_AhkPath, 1, 1)
}

TrayScriptActive()
{
    global tray_icon
    if (tray_icon = "ScriptActive")
        return

    tray_icon := "ScriptActive"
    A_IconTip := active_tooltip
    TraySetIcon(A_AhkPath, 2, 1)
}

;==================================================
; Main Polling Function
;==================================================
UpdateOnPoll()
{
    loop_timeout_count := Map()
    loop_delay_count := Map()
    script_active_flag := False
    script_idle_flag := False

    for _, executable in Programs
    {
        window_list := WinGetList("ahk_exe " . executable)

        Loop window_list.Length
        {
            window := window_list[A_Index]
            loop_timeout_count[window] := Max(1, Round(Timeout / Poll))
            loop_delay_count[window] := 1

            if WinActive("ahk_id " window)
            {
                if (A_TimeIdlePhysical > Timeout * 1000)
                {
                    loop_delay_count[window] -= 1
                    script_active_flag := True
                }
                else
                {
                    loop_timeout_count[window] := Max(1, Round(Timeout / Poll))
                    loop_delay_count[window] := 1
                    script_idle_flag := True
                }

                if (loop_delay_count[window] = 0)
                {
                    loop_delay_count[window] := Max(1, Round(Delay / Poll))
                    ResetTimer()
                }
            }
            else
            {
                if (loop_timeout_count[window] > 0)
                    loop_timeout_count[window] -= 1

                if (loop_timeout_count[window] = 0)
                {
                    loop_delay_count[window] -= 1
                    script_active_flag := True
                }
                else
                {
                    loop_delay_count[window] := 1
                    script_idle_flag := True
                }

                if (loop_delay_count[window] = 0)
                {
                    loop_delay_count[window] := Max(1, Round(Delay / Poll))

                    BlockInput "On"
                    old_window := WinGetID("A")

                    WinSetTransparent(0, "ahk_id " window)
                    WinActivate("ahk_id " window)

                    ResetTimer()

                    WinMoveBottom("ahk_id " window)
                    WinSetTransparent("Off", "ahk_id " window)

                    WinActivate("ahk_id " old_window)
                    BlockInput "Off"
                }
            }
        }
    }

    if script_active_flag 
    {
        TrayScriptActive()
    }  
    else if script_idle_flag 
    {
        TrayScriptIdle()
    }
    else 
    {
        TrayScriptDisabled()
    }
}

;==================================================
; Start the Polling Timer
;==================================================
SetTimer(UpdateOnPoll, poll_ms)
