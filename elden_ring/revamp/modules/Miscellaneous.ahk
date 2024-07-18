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

CheckBotNotActive() {
    check.bot_tries += 1

    if !(ProcessExist("BayaMacroBot.exe") or WinExist("BayaMacroBot.exe")) {
        return 1
    } else {
        try {
            if WinExist("BayaMacroBot.exe") {
                WinClose
                WinWaitClose
            }
            
            ProcessWaitClose("BayaMacroBot.exe", 60)

            return 1
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
    
    ; checks if bot is not active before delete exe
    if CheckBotNotActive() == 1 {
        ; delete bot exe
        if FileExist(A_WorkingDir "\BayaMacroBot.exe") {
            FileDelete A_WorkingDir "\BayaMacroBot.exe"
        }
    }

    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (InStr(A_LoopFileName, "baya") or IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
        }
    }
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