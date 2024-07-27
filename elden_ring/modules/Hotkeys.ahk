

_start_() {   
    
    static _last_Pressed := "" 

    _time_Pressed := A_TimeSincePriorHotkey != "" and A_TimeSincePriorHotkey or 0
    
    if _last_Pressed != "" and A_TickCount - _last_Pressed <= 500 {
        print("[Hotkeys] Pressing Debounce " _time_Pressed "ms")
        return
    }

    if (_gui.Ready != 0 && _status._running != 1) { ; # PLAY
        _game.PID := WinExist(_game.Title)

        WinActivate("ahk_id " _game.PID)
        WinWaitActive("ahk_id " _game.PID)
        WinMove(0, 0, , , "ahk_id " _game.PID)

        _status._running := 1
        
        print("[Hotkeys] Play " _time_Pressed "ms")

        _last_Pressed := A_TickCount 

        Run(EnvGet("BayaMacro") ' ' A_ScriptHwnd ' ' _ini.DataAutoFarm)
        
    } else if (_status._running != 0) { ; # PAUSE
        print("[Hotkeys] Pause " _time_Pressed "ms")

        _last_Pressed := A_TickCount 
        
        CheckIfActive("BayaMacro.exe")

        _status._running:= 0

    } else if _gui.Ready != 1 {
        print("[Hotkeys] Save GUI Settings " _time_Pressed "ms")
    } 
}
