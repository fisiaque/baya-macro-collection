#Requires AutoHotkey v2.0
#SingleInstance Force

; env file
if !(FileExist(A_WorkingDir "\.env") or FileExist("..\..\.env")) {
    FileInstall "..\..\.env", A_WorkingDir "\.env", 1
} 

; discord bot
if !(FileExist(A_WorkingDir "\BayaMacroBot.exe")) {
    FileInstall "..\..\bot\output\BayaMacroBot.exe", A_WorkingDir "\BayaMacroBot.exe", 1
    FileSetAttrib "+H", A_WorkingDir "\BayaMacroBot.exe"
} 

EnvSet "BayaMacroBot", A_WorkingDir "\BayaMacroBot.exe"

; icons
if !(FileExist(A_Temp "\baya_icon.ico")) {
    FileInstall "..\icons\baya_icon.ico", A_Temp "\baya_icon.ico", 1
    FileSetAttrib "+H", A_Temp "\baya_icon.ico"
} 

EnvSet "Icon", A_Temp "\baya_icon.ico"