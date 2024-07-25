#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

DetectHiddenWindows True

hWnd := A_Args[1]
TimeOutTime := 4000

send(StringToSend) {
    CopyDataStruct := Buffer(3*A_PtrSize) 

    SizeInBytes := (StrLen(StringToSend) + 1) * 2

    NumPut( "Ptr", SizeInBytes  ; OS requires that this be done.
          , "Ptr", StrPtr(StringToSend)  ; Set lpData to point to the string itself.
          , CopyDataStruct, A_PtrSize)

    SendMessage(0x004A, 0, CopyDataStruct,, "ahk_id " hWnd,,,, TimeOutTime)
}

F1:: {
    StringToSend := "Print|[macro] Checking ..."
    send(StringToSend)
}