#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 3

InstallKeybdHook
InstallMouseHook

#Include C:\Users\ofhaq\Documents\.elden_ring\.libs\Handler.ahk

SetTitleMatchMode 2
DetectHiddenWindows true

; HWND
MacroHWND := WinExist("Ahk_PID " DllCall("GetCurrentProcessId"))

Persistent
OnExit ExitFunc

; functions
ExitFunc(ExitReason, ExitCode) {
    SoundBeep(1500)

    FarmLoopStop()

    BlockInput "MouseMoveOff" 

    if FileExist(A_Temp "\.runes.png") {
        FileDelete A_Temp "\.runes.png"
    }   

    for name, file in images.OwnProps() {
        if InStr(file, "\AppData\Local\Temp\") and FileExist(file) {
            FileDelete file
        }
    }
}

; hotkeys
;stops
SC01B::{ ; #]
    ExitApp
}

#HotIf WinActive("ELDEN RING™") ; following hotkey will only run if elden ring is open!

;play/pause
SC01A:: ;#[ 
{
    PID := RetrievePID()
    Ready := RetrieveReady()

    if Ready != 0 {
        static toggle := 0

        toggle := !toggle  

        if (toggle != 0) { ; # PLAY
            Initialize()
        } else if (toggle != 1) { ; # PAUSE
            BlockInput "MouseMoveOff"

            Reload
        }
    }
}

; checks
SetTimer CheckWindow, 1000 ; checks window every second
SetTimer CheckDied, 1000 ; check if died every second