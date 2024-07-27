_codes := Object()
_codes.Close := 001

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
    }

    ; -- WM_COPYDATA 
    ClassName := Type(result)

    if ClassName == "Array" {
        if result[1] == "Print" {
            print(result[2])
        } else if result[1] == "DiscordBotCheck" {
            if _status._bot == "" {
                _status._bot := result[2]
            }
        } else if result[1] == "Command" {
            if result[2] == "Shutdown" {
                print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Shutdown Protocol")
                Shutdown 9
            } else if result[2] == "Check" {
                print("[Initialize(" Format_Msec(A_TickCount - _status._start_script) ")] Check Protocol")

            }
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