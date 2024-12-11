if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

_start_() {   
    
    static _last_Pressed := "" 

    if _last_Pressed != "" and A_TickCount - _last_Pressed <= 500 {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Debounce")
        return
    }

    if (macro.running != 1) { ; # PLAY
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Play")

        _last_Pressed := A_TickCount 

        SetTimer(StartMacro, -50)
    } else if (macro.running != 0) { ; # PAUSE
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Pause")

        _last_Pressed := A_TickCount 
        
        macro.running := 0
    }
}