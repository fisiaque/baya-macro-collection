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

sw(key, state := "") {
    sws := "{" . Format("sc{:X}", getKeySC(key)) " " . state . "}"

    if state == "" {
       sws := StrReplace(sws, A_Space)
    }

    return sws
}

SendKeyPress(key) {
    SendInput(sw(key, "Down"))
    Sleep 50
    SendInput(sw(key, "Up"))
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

        ; Make sure to over over trophies on ps3
        SendKeyPress("Z")

        Sleep(250)

        SendKeyPress("Z")

        Sleep(250)

        LoopSkip := A_TickCount

        print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Waiting for Sync Error..." macro.cycle " Synced")

        while !ImageSearch(&_, &_, 0, 0, 1920, 1080, "*100 " A_Temp "\BayaMacroErrorMin.png") && A_TickCount - LoopSkip <= 60000 { 
            Sleep(100)
        }

        if A_TickCount - LoopSkip >= 60000 {
            print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Max " macro.cycle " Synced?")
            break
        }

        macro.cycle += 1

        print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Synced " macro.cycle)

        SendKeyPress("X")

        Sleep(250)

        SendKeyPress("X")

        Sleep(250)

        SendKeyPress("X")

        Sleep(500)
    }
}