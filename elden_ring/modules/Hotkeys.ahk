_start_() {
    print("[Hotkeys] '[' Inputted")
    
    static _toggle := 0
    static _paused := 0

    _toggle := !_toggle  
    

    if (_gui.Ready != 0 && _toggle != 0) { ; # PLAY
        SetTimer(Checks, 1000)

        _paused := 0

        if check.window_ready != 0 {
            print("[Hotkeys] Start")

            _status._running := 1
            
        } else {
            _status._running:= 0
        }
        
    } else if (_paused != 1 && _toggle != 1) { ; # PAUSE
        print("[Hotkeys] Pause")
        SetTimer(Checks, 0)

        _paused := 1
        _status._running:= 0
    }
}

_stop_() {
    print("[Hotkeys] Stop")
    SetTimer(Checks, 0)
    
    _status._running := 0

    ExitApp
}