_start_() {
    print("[Hotkeys] '[' Inputted")
    
    static _toggle := 0  

    if (_gui.Ready != 0 && _toggle != 1) { ; # PLAY
        _toggle := 1
        print("[Hotkeys] Play")

        if A_IsPaused {
            Pause -1
        }

        SetTimer(Checks, 1000)

        _status._running := 1
        
    } else if (_toggle != 0) { ; # PAUSE
        print("[Hotkeys] Pause")
        
        if !A_IsPaused {
            Pause -1
        }

        SetTimer(Checks, 0)

        _status._running:= 0

        _toggle := 0
    }
}
