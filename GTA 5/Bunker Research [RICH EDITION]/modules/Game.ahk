CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

SetKeyDelay -1, 50

; object
macro := Object()
research := Object()

; variables
macro.running := 0
research.time := A_TickCount
research.notified := 0

MovingMouse(x, y, type, amount) {
    SendMode "Event"

    MouseGetPos &xpos, &ypos 
    MouseMove x - xpos, y - ypos, 2, "R"
    MouseClick type, x, y, amount
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

        ; Notify
        if (A_TickCount - research.time > 180000) && !(research.notified) { ; 180,000 ms == 3 Minutes
            research.notified := 1
            print("[Research(" Format_Msec(A_TickCount - _status._start_script) ")] Available Soon...")
        }

        ; Buy Research
        if PixelSearch(&_, &_, 1110, 637, 1203, 709, 0x840000, 3) {
            print("[Research(" Format_Msec(A_TickCount - _status._start_script) ")] Purchasing...")

            MovingMouse(1170, 696, "Left", 1)

            Sleep 500

            if !(macro.running) {
                break
            }
        }

        ; Confirm Research
        if PixelSearch(&_, &_, 991, 576, 1143, 659, 0xBD1F2C, 3) {
            print("[Research(" Format_Msec(A_TickCount - _status._start_script) ")] Confirming#1...")

            MovingMouse(1061, 614, "Left", 1)

            Sleep 1000

            if !(macro.running) {
                break
            }
        }

        ; Confirm Purchase
        if PixelSearch(&_, &_, 886, 778, 1032, 865, 0xBD1F2C, 3) {
            print("[Research(" Format_Msec(A_TickCount - _status._start_script) ")] Confirming#2...")

            MovingMouse(947, 849, "Left", 1)

            research.time := A_TickCount
            research.notified := 0

            Sleep 350

            if !(macro.running) {
                break
            }
        }
    }
}