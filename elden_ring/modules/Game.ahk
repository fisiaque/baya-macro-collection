if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

Thread "Interrupt", 0

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

SetKeyDelay -1, 50

; object
macro := Object()
macro.cycle := 0
macro.force_shutdown := 0

; variables
macro.running := 0

MovingMouse(x, y, type, amount) {
    SendMode "Event"

    MouseGetPos &xpos, &ypos 
    MouseMove x - xpos, y - ypos, 2, "R"
    MouseClick type, x, y, amount
}

Wait(ms) {
    starting := A_TickCount

    while A_TickCount - starting < ms {
        SetTimer Checks, -50

        RetrieveRunes()

        if !(macro.running) || (!(macro.is_alive) && !(macro.loading)) { ; if macro stops running return false
            return 0
        }

        Sleep 50
    }

    return 1
}

SendKeyPress(key) {
    SendInput(sw(key, "Down"))
    Sleep 50
    SendInput(sw(key, "Up"))
}

; COMMANDS CHECK
CommandsCheck() {
    if commands.active == "Shutdown" || macro.force_shutdown {
        commands.active := ""
        
        Shutdown_Command()
        Termination()
    }
    if commands.active == "Check" {
        commands.active := ""

        Check_Command()
    }
}

; GAME FUNCTIONS
OpenMap() {
     ; -- OPEN MENU
    LoopSkip := A_TickCount

    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempting to Open Menu")

    while !ImageSearch(&_, &_, 24, 41, 58, 74, "*25 " A_Temp "\" GetName() "Map.png") && A_TickCount - LoopSkip <= 5000 {
        SendKeyPress("M")

        result := Wait(500)

        if !(result) { ; if something went wrong
            break   ; break loop
        }
    }

    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }
     
    return 1
}

Travel() {
    LoopSkip := A_TickCount

    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempting to Find Site")

    while !ImageSearch(&FoundX, &FoundY, 191, 109, 238, 162, "*50 " A_Temp "\" GetName() "Site.png") && A_TickCount - LoopSkip <= 5000 {
        SendKeyPress("F") ; open sites menu

        result := Wait(350)

        if !(result) { ; if something went wrong
            break   ; break loop
        }
    }

    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    return 1
}

TravelAccept() {
    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempting to Travel")

    if ImageSearch(&FoundX, &FoundY, 191, 109, 238, 162, "*50 " A_Temp "\" GetName() "Site.png") {
        loop 2 {
            print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempt " A_Index " to press 'Enter'")

            SendKeyPress("Enter")
            
            result := Wait(350)

            if !(result) { ; if something went wrong
                break   ; break loop
            }
        }

        if !(macro.running) || (!(macro.is_alive)) {
            return 0
        }
    }

    LoopSkip := A_TickCount

    while ImageSearch(&_, &_, 275, 224, 592, 291, "*25 " A_Temp "\" GetName() "Ok.png") && A_TickCount - LoopSkip <= 5000 {
        print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempt " A_Index " to 'Click' OK")
    
        MovingMouse(313, 273, "Left", 2)

        result := Wait(350)

        if !(result) { ; if something went wrong
            break   ; break loop
        }
    }

    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }
        
    return 1
}

WaitLoading() {  
    macro.loading := 1

    LoadWait := 10000 ; 10000 seconds
    LoopSkip := A_TickCount

    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Waiting for Loading Screen")

    while !ImageSearch(&_, &_, 18, 410, 226, 473, "*50 " A_Temp "\" GetName() "Next.png") && A_TickCount - LoopSkip <= LoadWait { ; 10 seconds loop skip
        result := Wait(250)

        if !(result) || ImageSearch(&_, &_, 18, 410, 226, 473, "*25 " A_Temp "\" GetName() "Next.png") { ; if something went wrong
            break   ; break loop
        }
    }

    if !(macro.running) { ; macro stopped
        return 0
    }

    Wait(1000)

    if !(macro.running) { ; macro stopped
        return 0
    }

    if ImageSearch(&_, &_, 18, 410, 226, 473, "*50 " A_Temp "\" GetName() "Next.png") {
        LoopSkip := A_TickCount

        while ImageSearch(&_, &_, 18, 410, 226, 473, "*50 " A_Temp "\" GetName() "Next.png") && A_TickCount - LoopSkip <= LoadWait { ; 10 seconds loop skip
            result := Wait(250)
    
            if !(result) { ; if something went wrong
               break   ; break loop
            }
        }
    else
        Wait(LoadWait)
    }

    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Finished Loading")

    if !(macro.running) { ; macro stopped
       return 0
    }

    result := Wait(2000)

    if !(result) {
        return 0
    }

    ; -- check commands
    if macro.cycle >= (commands.start_cycle + commands.cycle) || macro.force_shutdown {
        CommandsCheck()
    }

    macro.loading := 0

    return 1
}

RetrieveRunes() {
    if ImageSearch(&_, &_, 279, 389, 555, 444, "*50 " A_Temp "\" GetName() "Retrieve.png") {
        print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Attempting to Retrieve Runes")

        SendKeyPress("E")
    }
}

FarmMob() {
    macro.farming := 1
    print("[BayaMacro(" Format_Msec(A_TickCount - _status._start_script) ")] Albinaurics Walk Path")

    SendInput(sw("W", "Down") SendInput(sw("LShift", "Down")))
    Wait(1000) 
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendInput(sw("W", "Up") sw("LShift", "Up"))
    SendInput(sw("W", "Down") sw("LShift", "Down") sw("A", "Down"))
    Wait(350)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendInput(sw("W", "Up") sw("LShift", "Up") sw("A", "Up"))
    SendInput(sw("W", "Down") sw("LShift", "Down"))
    Wait(750)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendInput(sw("W", "Up") sw("LShift", "Up"))
    SendInput(sw("W", "Down") sw("LShift", "Down") sw("A", "Down"))
    Wait(450)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendInput(sw("W", "Up") sw("LShift", "Up") sw("A", "Up"))
    SendInput(sw("W", "Down") sw("LShift", "Down"))
    Wait(400)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendInput(sw("W", "Up") sw("LShift", "Up"))
    
    SendKeyPress("F")    
    Wait(3000)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    SendKeyPress("F")
    Wait(6000)
    if !(macro.running) || (!(macro.is_alive)) {
        return 0
    }

    macro.farming := 1

    return 1
}

Termination() {
    print("[Game(" Format_Msec(A_TickCount - _status._start_script) ")] Terminating...")

    UnpressKeys()

    macro.running := 0

    Exit
}

StartMacro() {
    if macro.running {
        return
    }

    macro.running := 1
    macro.is_alive := 1
    macro.farming := 0
    macro.loading := 0
    macro.cycle := 1

    commands.can_use := 0

    result := Checks()

    if !(result) {
        Termination()
        return
    }

    Loop {
    ;    if macro.is_alive {
            result := OpenMap()

            if !(result) {
                if !(macro.running) { ; macro stopped
                    break
                }
                if !(macro.is_alive) {
                    result := WaitLoading() ; Use Same WaitLoading as below
    
                    if !(result) {
                        if !(macro.running) { ; macro stopped
                            break
                        }
                    }

                    continue
                }
            }
    
            result := Travel()
    
            if !(result) {
                if !(macro.running) { ; macro stopped
                    break
                }
                if !(macro.is_alive) {                    
                    result := WaitLoading() ; Use Same WaitLoading as below
    
                    if !(result) {
                        if !(macro.running) { ; macro stopped
                            break
                        }
                    }

                    continue
                }
            }
    
            result := TravelAccept()
    
            if !(result) {
                if !(macro.running) { ; macro stopped
                    break
                }
                if !(macro.is_alive) {                    
                    result := WaitLoading() ; Use Same WaitLoading as below
    
                    if !(result) {
                        if !(macro.running) { ; macro stopped
                            break
                        }
                    }

                    continue
                }
            }
    
            result := WaitLoading() ; Use Same WaitLoading as below
    
            if !(result) {
                if !(macro.running) { ; macro stopped
                    break
                }
            }
    ;    }
    
        macro.is_alive:= 1

        result := FarmMob()

        if !(result) {
            if !(macro.running) { ; macro stopped
                break
            }
            if (!(macro.is_alive)) {  
                macro.farming := 0
                    
                result := WaitLoading() ; Use Same WaitLoading as above

                if !(result) {
                    if !(macro.running) { ; macro stopped
                        break
                    }
                }
            }
        }

        macro.cycle += 1
    }

    Termination()
}