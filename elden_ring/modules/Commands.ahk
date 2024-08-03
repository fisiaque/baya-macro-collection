if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

commands := Object()
commands.active := ""
commands.start := A_TickCount
commands.start_cycle := macro.cycle
commands.cycle := 3

Shutdown_Command(_reasoning := "") {
    Notify("CHECKING SHUTDOWN")
}

Check_Command() {
    Notify("CHECKING CHECK")
}

; -- set commands
Set_Command_Shutdown(_reasoning := "") {
    if commands.active == "" {
        commands.start := A_TickCount
        commands.start_cycle := macro.cycle
        commands.active := "Shutdown"
    } else {
        print("[Commands(" Format_Msec(A_TickCount - _status._start_script) ")] Wait for " commands.active " Command to Finish")
    
        Notify("Wait for " commands.active " Command to Finish")
    }
}

Set_Command_Check() {
    if commands.active == "" {
        commands.start := A_TickCount
        commands.start_cycle := macro.cycle
        commands.active := "Check"
    } else {
        print("[Commands(" Format_Msec(A_TickCount - _status._start_script) ")] Wait for " commands.active " Command to Finish")
    
        Notify("Wait for " commands.active " Command to Finish")
    }
}

Set_Command_Cancel() {
    commands.active := ""
}