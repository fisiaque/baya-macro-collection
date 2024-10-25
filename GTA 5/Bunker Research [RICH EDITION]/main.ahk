; -- made by faizul haque aka fiziaque
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
#SingleInstance Off

Persistent
DetectHiddenWindows True

; variables
global file_extensions := ['jpg','jpeg','png','gif','ico','exe']

_game := Object()
_status := Object()
_discord := Object()

_game.Title := "Grand Theft Auto V"
_game.PID := ""

_status._bot := ""
_status._start_script := A_TickCount

; -- includes
#Include modules\Game.ahk
#Include modules\Version.ahk
#Include modules\OutputConsole.ahk
#Include modules\Hotkeys.ahk

; start
print("[main(" Format_Msec(A_TickCount - _status._start_script) ") Modules Initialized")

OnExit ExitFunction

; hotkeys
~SC01B::ExitApp ; stopM

#HotIf _game.PID := WinExist(_game.Title) or print("[main(" Format_Msec(A_TickCount - _status._start_script) ")] GTA 5 not running")

~SC01A::_start_ ; start[

ExitFunction(ExitReason, ExitCode) {
    SoundBeep(250, 75)

    print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] Processing Closure...")
    
    _status._running := 0

    ; delete folder
    if FileExist(A_Temp "\BayaMacroImages") {
        FileDelete A_Temp "\BayaMacroImages"
        print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] BayaMacroImages Deleted")
    }

    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
            print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] " A_LoopFileName " Deleted")
        }
    }
} 

IsFileExtenstion(ext) {
    if ext != "" {
        Loop file_extensions.Length {
            if (InStr(file_extensions[A_Index], ext)) {
                return 1
            }
        }
    }

    return 0
}