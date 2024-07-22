_codes := Object()
_codes.Close := 001

IsArray(a) {
    return a.SetCapacity(0)=(a.MaxIndex()-a.MinIndex()+1)
}

CloseRunningScripts() {
    For hWnd in arr := WinGetList(A_WorkingDir "\" A_ScriptName) {
        if hWnd != A_ScriptHwnd {
            DllCall("SendMessageCallback", "ptr", hWnd, "uint", _msg_Num.Close, "ptr", 123, "ptr", -456, "ptr", CallbackCreate(SendAsyncProc), "ptr", 0)
        }
    }
}
SendAsyncProc(hWnd, msgNum, dwData, result) {
    ; -- CALLBACKS
    if result == _codes.Close {
        ExitApp
        return
    }

    ; -- WM_COPYDATA 
    ClassName := Type(result)

    if ClassName == "Array" {
        if result[1] == "DiscordBotCheck" {
            _status._bot := result[2]
        }
    } 
}
PostAsyncProc(wParam, lParam, msgNum, hwnd) {
    
    if msgNum == _msg_Num.WM_COPYDATA {
        StringAddress := NumGet(lParam, 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
        CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
        
        _data := StrSplit(CopyOfData, "|")  

        SendAsyncProc(hWnd, msgNum, 0, _data)
    }

    if msgNum == _msg_Num.Close {
        return _codes.Close
    }
   
}
; -- pre-check
RunAsTask()

if not A_IsAdmin {
    try {
        Run '*RunAs ' A_ScriptFullPath '',, 'Hide'
        ExitApp
    } catch as e {
        ExitApp
    }
}

; close all other running scripts 
CloseRunningScripts()