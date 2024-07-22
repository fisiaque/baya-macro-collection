#Requires AutoHotkey v2.0
DetectHiddenWindows 1

receiverhWnd := WinExist("Receiver.ahk ahk_class AutoHotkey")
; The receiver script should have created a message with name "NewAHKScript", so get its number
MsgNum := DllCall("RegisterWindowMessage", "Str", "NewAHKScript")
DllCall("SendMessageCallback", "ptr", receiverHwnd, "uint", MsgNum, "ptr", 123, "ptr", -456, "ptr", CallbackCreate(SendAsyncProc), "ptr", 0)
TrayTip "Sent the message and am waiting for reply", "Sender.ahk"
Persistent()

; dwData is the same value as the last argument of SendMessageCallback (in this example, 0)
SendAsyncProc(hWnd, msg, dwData, result) {
    MsgBox "Got reply: " result
    ExitApp
}