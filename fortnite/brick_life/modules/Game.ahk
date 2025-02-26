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
        print("[Game|movement(" Format_Msec(A_TickCount - _status._start_script) ")] Going Forward!")

        SendKeyPress("W", Random(100,300))
    }
    if N == 2 {
        print("[Game|movement(" Format_Msec(A_TickCount - _status._start_script) ")] Going Left!")

        SendKeyPress("A", Random(100,300))
    }
    if N == 3 {
        print("[Game|movement(" Format_Msec(A_TickCount - _status._start_script) ")] Going Back!")

        SendKeyPress("S", Random(100,300))
    }
    if N == 4 {
        print("[Game|movement(" Format_Msec(A_TickCount - _status._start_script) ")] Going Right!")

        SendKeyPress("D", Random(100,300))
    }
    if N == 5 {
        print("[Game|movement(" Format_Msec(A_TickCount - _status._start_script) ")] Jumping!")

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

    print("[Game|StartLoop(" Format_Msec(A_TickCount - _status._start_script) ")] Macro has started!")

    ; notify on discord
    Notify("<@" _ini.DiscordUserId "> Macro has started!")

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
                print("[Game|StartLoop(" Format_Msec(A_TickCount - _status._start_script) ")] Disconnected!")

                ; notify on discord
                Notify("<@" _ini.DiscordUserId "> You have disconnected from Fortnite Brick Life!")

                break
            }
        } 
    }
}