CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

SetKeyDelay -1, 50

; object
macro := Object()
research := Object()

; variables
macro.running := 0
macro.cycle := 0
research.time := A_TickCount
research.notified := 0

MovingMouse(x, y, type, amount) {
    SendMode "Event"

    MouseGetPos &xpos, &ypos 
    MouseMove x - xpos, y - ypos, 2, "R"
    MouseClick type, x, y, amount
}

SendKeyPress(key, delay := 50) {
    SendInput(sw(key, "Down"))
    Sleep delay
    SendInput(sw(key, "Up"))
}

movement(N) {
    if N == 1 {
        SendKeyPress("W", Random(100,300))
    }
    if N == 2 {
        SendKeyPress("A", Random(100,300))
    }
    if N == 3 {
        SendKeyPress("S", Random(100,300))
    }
    if N == 4 {
        SendKeyPress("D", Random(100,300))
    }
    if N == 5 {
        SendKeyPress("Space")
    }
}

StartMacro() {
    if macro.running {
        return
    }

    macro.running := 1
    research.time := A_TickCount
    research.notified := 0

    loop {
        if !(macro.running) {
            break
        }

        if PixelSearch(&_, &_, 1738, 88, 1784, 144, 0xAAAFDB, 3) { ; Searches for Resident color
            movement(Random(1, 5))

            starting := A_TickCount

            while A_TickCount - starting < 5000 {
                if !PixelSearch(&_, &_, 1738, 88, 1784, 144, 0xAAAFDB, 3) {
                    break
                }

                Sleep 100
            }

            if !PixelSearch(&_, &_, 1738, 88, 1784, 144, 0xAAAFDB, 3) {
                print("[Game(" Format_Msec(A_TickCount - _status._start_script) ")] Left?")

                ; notify on discord
                Notify("<@" _ini.DiscordUserId "> You have left? Fortite Brick Life")

                break
            }
        } 
    }
}