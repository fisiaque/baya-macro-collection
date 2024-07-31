if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

_start_() {   
    
    static _last_Pressed := "" 

    if _discord.loading {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Wait for Discord Bot Response!")
        return
    }
    
    if _last_Pressed != "" and A_TickCount - _last_Pressed <= 500 {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Debounce")
        return
    }

    if (_gui.Ready != 0 && macro.running != 1) { ; # PLAY
        WinActivate("ahk_id " _game.PID)
        WinWaitActive("ahk_id " _game.PID)
        WinMove(0, 0, , , "ahk_id " _game.PID)
        
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Play")

        _last_Pressed := A_TickCount 

        SetTimer(StartMacro, -50)
    } else if (macro.running != 0) { ; # PAUSE
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Pause")

        _last_Pressed := A_TickCount 
        
        macro.running := 0

    } else if _gui.Ready != 1 {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Save GUI Settings")
    } 
}
