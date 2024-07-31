if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

commands := Object()
commands.shutdown := 0
commands.check := 0

Shutdown_Command() {
    while (commands.shutdown && !(macro.is_alive)) {
        Sleep 1000
    }

    print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Shutdown Command")
    
    Notify("Initialized Shutdown Command")

    ;Shutdown 9
}

Check_Command() {
    while (commands.check && !(macro.is_alive)) {
        Sleep 100
    }

    print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Check Command")

    Notify("Initialized Check Command")

    commands.check := 0
}
