Receive_WM_COPYDATA(wParam, lParam, msg, hwnd)
{
    MsgBox hwnd
    StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
    CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
    
    MsgBox CopyOfData
    MsgBox msg
    
    return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

OnMessage 0x004A, Receive_WM_COPYDATA  ; 0x004A is WM_COPYDATA

A_Clipboard := A_ScriptHwnd 

Run '"pythonw" "C:\Users\ofhaq\Documents\baya_macros\elden_ring\test.py" ' A_ScriptHwnd 


while 1 {
    sleep 100
}