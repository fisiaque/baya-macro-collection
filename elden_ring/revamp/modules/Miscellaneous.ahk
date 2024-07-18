#Requires AutoHotkey v2.0
#SingleInstance Force

;#objects
check := Object()

;#variables
check.bot_tries := 0

;#global
global file_extensions := ['jpg','jpeg','png','gif','ico']

;#functions
quoted(str) {
    If RegExMatch(str, "'(.+?)'", &m)
     Return m[1]
}

FileReadLine(file_to_read, line_number) {
    file_object := FileOpen(file_to_read, "r")
    loop line_number
        line_text := file_object.ReadLine() 
    file_object.Close
    return line_text
}

IsFileExtenstion(ext) {
    if ext != "" {
        Loop file_extensions.Length {
            if (InStr(file_extensions[A_Index], ext)) {
                return 1
            }
        }
    }

    return 0
}

CheckBotNotActive() {
    check.bot_tries += 1

    if !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
        return 1
    } else {
        try {
            RunWait '*RunAs taskkill.exe /F /T /IM BayaMacroBot.exe',, 'Hide'
           
            ProcessWaitClose("BayaMacroBot.exe", 15)
            
            if !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
                return 1
            } else {
                if check.bot_tries < 3 {
                    CheckBotNotActive()
                } else {
                    return 0
                }
            }
            
        } catch as e {
            if check.bot_tries < 3 {
                CheckBotNotActive()
            } else {
                return 0
            }
        } 
    }
}

ExitFunction(ExitReason, ExitCode) {
    SoundBeep(1500)

    print("[ExitFunction] Processing Closure...")
    
    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (InStr(A_LoopFileName, "baya") or IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
            print("[ExitFunction] " A_LoopFileName " Deleted")
        }
    }

    ; checks if bot is not active before delete exe
    if CheckBotNotActive() == 1 {
        ; delete bot exe
        if FileExist(A_WorkingDir "\BayaMacroBot.exe") and !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
            FileDelete A_WorkingDir "\BayaMacroBot.exe"
            print("[ExitFunction] BayaMacroBot.exe Deleted")
        }
    }
} 

DiscordBotCheck(discord_Token) {
    if discord_Token != "" and CheckBotNotActive() == 1 {
        print("[DiscordBotCheck] Activating Discord Command Bot...")
    
        A_Clipboard := "" ;Empty Clipboard
    
        Run(EnvGet("BayaMacroBot"))
    
        if ClipWait(10) and A_Clipboard == "success" {
            
            print("[DiscordBotCheck] success")
        } else {
            print("[DiscordBotCheck] fail")
        }

        A_Clipboard := "" ;Empty Clipboard
    }
}