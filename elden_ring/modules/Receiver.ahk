#Requires AutoHotkey v2.0

; Register a new window message with the custom name "NewAHKScript"
MsgNum := DllCall("RegisterWindowMessage", "Str", "NewAHKScript")
OnMessage(MsgNum, NewScriptCreated)
Persistent()

NewScriptCreated(wParam, lParam, msg, hwnd) {
    Loop {
        ib := InputBox("Script with hWnd " hwnd " sent message:`n`nwParam: " wParam "`nlParam: " lParam "`n`nReply:", "Message")
        if ib.Result = "Cancel"
            return 0
        else if !IsInteger(IB.Value)
            MsgBox "The reply can only be a number", "Error"
        else
            return IB.Value
    }
}