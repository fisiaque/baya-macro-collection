

_start_() {    
    static _toggle := 0  

    _time_Pressed := A_TimeSincePriorHotkey != "" and A_TimeSincePriorHotkey or 0
    
    if (_gui.Ready != 0 && _toggle != 1) { ; # PLAY
        _toggle := 1

        print("[Hotkeys] Play " _time_Pressed "ms")

        Run(EnvGet("BayaMacro") ' ' A_ScriptHwnd)

        _status._running := 1
        
    } else if (_toggle != 0) { ; # PAUSE
        print("[Hotkeys] Pause " _time_Pressed "ms")
        
        _status._running:= 0

        CheckIfActive("BayaMacro.exe")

        _toggle := 0

    } else if _gui.Ready != 1 {
        print("[Hotkeys] Save GUI Settings " _time_Pressed "ms")
    }
}
