if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

; env file
if !(FileExist(A_WorkingDir "\discord.env")) {
    FileInstall ".\files\discord.env", A_WorkingDir "\discord.env", 1
} 

; discord bot
if !(FileExist(A_Temp "\BayaMacroBot.exe")) {
    FileInstall "..\bot\output\BayaMacroBot.exe", A_Temp "\BayaMacroBot.exe", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroBot.exe"
} 

EnvSet "BayaMacroBot", A_Temp "\BayaMacroBot.exe"

; baya macro images
LoopImages() {
    loop files ".\images\*.png" {
        FileInstall A_LoopFileFullPath, A_Temp "\" GetName() A_LoopFileName, 1
        FileSetAttrib "+H", A_Temp "\" GetName() A_LoopFileName
    }
}

try {
    LoopImages()
} catch as e {
    Loop Files, A_Temp "\*.png" { 
        FileDelete A_LoopFileFullPath
        print("[FileInstaller(" Format_Msec(A_TickCount - _status._start_script) ")] " A_LoopFileName " Deleted")
    }

    LoopImages()
}

; baya macro png
if !(FileExist(A_Temp "\BayaMacroImage.png")) {
    FileInstall "..\visuals\BayaMacroImage.png", A_Temp "\BayaMacroImage.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroImage.png"
} 
if !(FileExist(A_Temp "\BayaMacroBanner.png")) {
    FileInstall "..\visuals\BayaMacroBanner.png", A_Temp "\BayaMacroBanner.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroBanner.png"
} 

