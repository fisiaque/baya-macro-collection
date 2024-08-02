if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

commands := Object()
commands.shutdown := 0
commands.check := 0

Shutdown_Command(_reasoning := "") {
    static active := 0

    if active == 0 {
        active := 1

        while (commands.shutdown && (macro.running && !(macro.is_alive))) {
            Sleep 1000
        }
        
        notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> Initialized Shutdown Command" or "Initialized Shutdown Command"

        if _reasoning == "Battery" {
            notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> Less than 15% of Battery Life, Shutting Down PC" or "Less than 15% of Battery Life, Shutting Down Laptop"
        }
        
        Notify(notification)

        print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Shutdown Command")
    
        ;Shutdown 9

        active := 0
    }
}

Check_Command() {
    static active := 0

    if active == 0 {
        active := 1

        while (commands.check && (macro.running && !(macro.is_alive))) {
            Sleep 100
        }
    
        print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Check Command")
    
        Notify("Initialized Check Command")
    
        commands.check := 0

        active := 0
    }
}
