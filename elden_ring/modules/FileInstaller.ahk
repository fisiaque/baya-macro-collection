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

; baya macro png
if !(FileExist(A_Temp "\BayaMacroImage.png")) {
    FileInstall "..\visuals\BayaMacroImage.png", A_Temp "\BayaMacroImage.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroImage.png"
} 
if !(FileExist(A_Temp "\BayaMacroBanner.png")) {
    FileInstall "..\visuals\BayaMacroBanner.png", A_Temp "\BayaMacroBanner.png", 1
    FileSetAttrib "+H", A_Temp "\BayaMacroBanner.png"
} 



