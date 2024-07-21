

_start_() {    
    static _toggle := 0  

    _time_Pressed := A_TimeSincePriorHotkey != "" and A_TimeSincePriorHotkey or 0
    
    if (_gui.Ready != 0 && _toggle != 1) { ; # PLAY
        _toggle := 1

        print("[Hotkeys] Play " _time_Pressed "ms")

        if A_IsPaused {
            Pause -1
        }

        _status._running := 1
        
    } else if (_toggle != 0) { ; # PAUSE
        print("[Hotkeys] Pause " _time_Pressed "ms")
        
        _status._running:= 0

        _toggle := 0

        if !A_IsPaused {
            Pause -1
        }
    }
}
