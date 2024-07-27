#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

DetectHiddenWindows True

; pre variables
hWnd := A_Args[1]
autoFarmMethod := A_Args[2]
scriptStart := A_Args[3]

TimeOutTime := 4000

; pre functions
Send(StringToSend) {
    CopyDataStruct := Buffer(3*A_PtrSize) 

    SizeInBytes := (StrLen(StringToSend) + 1) * 2

    NumPut( "Ptr", SizeInBytes  ; OS requires that this be done.
          , "Ptr", StrPtr(StringToSend)  ; Set lpData to point to the string itself.
          , CopyDataStruct, A_PtrSize)

    SendMessage(0x004A, 0, CopyDataStruct,, "ahk_id " hWnd,,,, TimeOutTime)
}

print(NewMessage) {
    StringToSend := "Print|" NewMessage

    Send(StringToSend)
}

command(NewCommand) {
    StringToSend := "Command|" NewCommand

    Send(StringToSend)
}

Format_Msec(ms) {
    VarSetStrCapacity(&t,256),DllCall("GetDurationFormat","uint",2048,"uint",0,"ptr",0,"int64",ms*10000,"wstr","hh':'mm':'ss","wstr",t,"int",256)
    return t
}

; variables

; game functions

F1:: {
    print("[BayaMacro(" Format_Msec(A_TickCount - scriptStart) ")] HI BAYA")
}
