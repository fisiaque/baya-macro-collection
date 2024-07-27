

_start_() {   
    
    static _last_Pressed := "" 
    
    if _last_Pressed != "" and A_TickCount - _last_Pressed <= 500 {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Debounce")
        return
    }

    if (_gui.Ready != 0 && _status._running != 1) { ; # PLAY
        _game.PID := WinExist(_game.Title)

        WinActivate("ahk_id " _game.PID)
        WinWaitActive("ahk_id " _game.PID)
        WinMove(0, 0, , , "ahk_id " _game.PID)

        _status._running := 1
        
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Play")

        _last_Pressed := A_TickCount 

        Run(EnvGet("BayaMacro") ' ' A_ScriptHwnd ' ' _ini.DataAutoFarm ' ' _status._start_script)
        
    } else if (_status._running != 0) { ; # PAUSE
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Pause")

        _last_Pressed := A_TickCount 
        
        CheckIfActive("BayaMacro.exe")

        _status._running:= 0

    } else if _gui.Ready != 1 {
        print("[Hotkeys(" Format_Msec(A_TickCount - _status._start_script) ")] Save GUI Settings")
    } 
}
