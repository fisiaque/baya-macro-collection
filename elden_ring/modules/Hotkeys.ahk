_start_() {
    print("[Hotkeys] Start Inputted")
   
    _ready := 0

    if _ready != 0 {
        static _toggle := 0

        _toggle := !_toggle  

        if (_toggle != 0) { ; # PLAY
            
        } else if (_toggle != 1) { ; # PAUSE
            
        }
    }
}

_stop_() {
    print("[Hotkeys] Stop Inputted")

    ExitApp
}