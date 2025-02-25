if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

; baya macro images
LoopImages() {
    loop files ".\images\*.png" {
        FileInstall A_LoopFileFullPath, A_Temp "\" GetName() A_LoopFileName, 1
        FileSetAttrib "+H", A_Temp "\" GetName() A_LoopFileName
    }
}

try {
    LoopImages()
}

; baya macro png
;if !(FileExist(A_Temp "\???.png")) {
;    FileInstall ".\images\???.png", A_Temp "\???.png", 1
;    FileSetAttrib "+H", A_Temp "\???.png"
;} 
