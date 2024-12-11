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
if !(FileExist(A_Temp "\BayaMacroPerforming.png")) {
    FileInstall "..\visuals\BayaMacroPerforming.png", A_Temp "\BayaMacroPerforming.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroPerforming.png"
} 
if !(FileExist(A_Temp "\BayaMacroSync.png")) {
    FileInstall ".\images\BayaMacroSync.png", A_Temp "\BayaMacroSync.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroSync.png"
} 

