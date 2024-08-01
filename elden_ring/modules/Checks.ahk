if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

;#objects
Checks() {
    static _notified := A_TickCount

    ;-- WinActive checks if window is active | not to get mixed up with WinActivate which makes window on top
    if (WinActive("ahk_id " _game.PID)) {
        WinGetClientPos &_game_X, &_game_Y, &_game_Width, &_game_Height, "ahk_id " _game.PID
            
        if (_game_X != 8 && _game_Y != 31) { ; since windowed | checks if it's in the top left
            print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] Elden Ring window is not positioned properly")

            if A_TickCount - _notified >= 5000 { ; prints out every 5 seconds
                _notified := A_TickCount

                _time_String := FormatTime("hm", "Time")
                print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] (" _time_String ") : Game window should be positioned top left")

                SoundBeep(1000, 500)
            }
                
            macro.running := 0
            _status._running := 0 ; macro stops it wrong resolution 

            return 0
        }

        if (_game_Width != 800 && _game_Height != 450) { 
            print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] Elden Ring is not the correct resolution")

            if A_TickCount - _notified >= 5000 { ; prints out every 5 seconds
                _notified := A_TickCount

                _time_String := FormatTime("hm", "Time")
                print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] (" _time_String ") : In-game resolution must be 800x450 'Windowed'")

                SoundBeep(1000, 500)
            }
                
            macro.running := 0
            _status._running := 0 ; macro stops it wrong resolution 

            return 0
        } 

        if macro.is_alive && (ImageSearch(&_, &_, 257, 198, 548, 307, "*50 " A_Temp "\" GetName() "Died.png") || PixelSearch(&_, &_, 71, 49, 75, 57, 0x9A8422, 3)) {  
            UnpressKeys()

            print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] User Died!")

            notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> User has died!" or "User has died!"

            Notify(notification)

            Send(sw("F8"))

            macro.is_alive := 0 ; dead  
            
            return 0
        }

    } else {
        print("[Checks(" Format_Msec(A_TickCount - _status._start_script) ")] Elden Ring is not active")

        SoundBeep(1000, 500)

        notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> Elden Ring is not active" or "Elden Ring is not active]"

        Notify(notification)

        macro.running := 0

        _status._running := 0 ; when elden ring doesn't exist macro stops

        return 0
    }

    return 1
}

CheckIfActive(_name) { 
    static active_tries := 0

    if !(ProcessExist(_name)) and !(WinExist(_name)) {
        return 1
    } else {
        try {
            active_tries += 1

            RunWait '*RunAs taskkill.exe /F /T /IM ' _name,, 'Hide'
           
            ProcessWaitClose(_name, 15)
            
            if !(ProcessExist(_name)) and !(WinExist(_name)) {
                active_tries := 0

                UnpressKeys()
                
                return 1
            } else {
                if active_tries < 3 {
                    CheckIfActive(_name)
                } else {
                    active_tries := 0
                    return 0
                }
            }
            
        } catch as e {
            if active_tries < 3 {
                CheckIfActive(_name)
            } else {
                active_tries := 0
                return 0
            }
        } 
    }
}

DiscordBotCheck(discord_Token) {
    _discord.loading := 1

    while !(_gui.Ready) {
        Sleep 100
    }

    if discord_Token != "" and CheckIfActive("BayaMacroBot.exe") == 1 {
        print("[DiscordBotCheck(" Format_Msec(A_TickCount - _status._start_script) ")] Loading... (Timeout after 60s)")
        
        discord_ID_DATA := _ini.DiscordUserId "," _ini.DiscordRoleId

        Run(EnvGet("BayaMacroBot") ' ' A_ScriptHwnd ' ' discord_Token ' ' discord_ID_DATA)

        _last_TickCount := A_TickCount

        while _status._bot == "" and A_TickCount - _last_TickCount <= 60000 { ;checks status bot or times out after 1 min
            Sleep 1000
        }

        if _status._bot == "success" {
            print("[DiscordBotCheck(" Format_Msec(A_TickCount - _status._start_script) ")] Successfully Activated!")
        } else {
            print("[DiscordBotCheck(" Format_Msec(A_TickCount - _status._start_script) ")] Failed to Activate")
        }

        _discord.loading := 0
    } else if discord_Token == "" {
        print("[DiscordBotCheck(" Format_Msec(A_TickCount - _status._start_script) ")] Empty Discord Token")
        _discord.loading := 0
    }
}

CheckIfRunning() {
    if _status._running != 0 {
        return 1
    }

    return 0
}