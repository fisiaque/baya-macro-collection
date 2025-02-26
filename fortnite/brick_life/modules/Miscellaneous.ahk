
if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}


keys := "W|A|S|D|Q|E|M|F|Esc|Enter|LButton|MButton|RButton|Numpad2|Numpad4|Numpad6|Numpad8|WheelUp|WheelDown|Right|LShift"

;#global
global file_extensions := ['jpg','jpeg','png','gif','ico','exe']
 
;#functions
quoted(str) {
    If RegExMatch(str, "'(.+?)'", &m)
     Return m[1]
}

StrReadLine(str, n) {  ; Return a line from a string, by line number
    arr := StrSplit(str, '`n', '`r')

    If arr.Has(n) {
        Return arr[n]
    }
}

FileReadLine(file_to_read, line_number) {
    file_object := FileOpen(file_to_read, "r")
    loop line_number
        line_text := file_object.ReadLine() 
    file_object.Close
    return line_text
}

sw(key, state := "") {
    sws := "{" . Format("sc{:X}", getKeySC(key)) " " . state . "}"

    if state == "" {
       sws := StrReplace(sws, A_Space)
    }

    return sws
}

UnpressKeys() {
    loop parse keys, "|" {
        if GetKeyState(A_LoopField) {
            SendInput(sw(A_LoopField, "Up"))
        }
    }
}

IsFileExtenstion(ext) {
    if ext != "" {
        Loop file_extensions.Length {
            if (InStr(file_extensions[A_Index], ext)) {
                return 1
            }
        }
    }

    return 0
}

GetArrayValueIndex(arr, val) {
    if val != "" {
        Loop arr.Length {
            if (InStr(arr[A_Index], val))
                return A_Index
        }
    }
}

WithinRange(num, min, max) {
    if IsNumber(num) {
        _number := Number(num)
 
        if _number >= min and _number <= max {
            return 1
        }
    } else {
        print("[Misc|WithinRange(" Format_Msec(A_TickCount - _status._start_script) ")] Not Given Number")
    }

    return 0
}

ExitFunction(ExitReason, ExitCode) {
    SoundBeep(250, 75)

    print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] Processing Closure...")
    
    _status._running := 0

    ; delete folder
    if FileExist(A_Temp "\BayaMacroImages") {
        FileDelete A_Temp "\BayaMacroImages"
        print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] BayaMacroImages Deleted")
    }

    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
            print("[Misc|ExitFunction(" Format_Msec(A_TickCount - _status._start_script) ")] " A_LoopFileName " Deleted")
        }
    }
} 

Class CreateFormData {

    __New(&retData, &retHeader, objParam) {

        Local CRLF := "`r`n", i, k, v, str, pvData
        ; Create a random Boundary
        Local Boundary := CreateFormData.RandomBoundary()
        Local BoundaryLine := "------------------------------" . Boundary

        ; Create an IStream backed with movable memory.
        hData := DllCall("GlobalAlloc", "uint", 0x2, "uptr", 0, "ptr")
        DllCall("ole32\CreateStreamOnHGlobal", "ptr", hData, "int", False, "ptr*", &pStream:=0, "uint")
        CreateFormData.pStream := pStream

        ; Loop input paramters
        For k, v in objParam.OwnProps()
        {
            If IsObject(v) {
                For i, FileName in v
                {
                    str := BoundaryLine . CRLF
                        . 'Content-Disposition: form-data; name="' . k . '"; filename="' . FileName . '"' . CRLF
                        . 'Content-Type: ' . CreateFormData.MimeType(FileName) . CRLF . CRLF

                    CreateFormData.StrPutUTF8( str )
                    CreateFormData.LoadFromFile( Filename )
                    CreateFormData.StrPutUTF8( CRLF )

                }
            } Else {
                str := BoundaryLine . CRLF
                    . 'Content-Disposition: form-data; name="' . k '"' . CRLF . CRLF
                    . v . CRLF
                CreateFormData.StrPutUTF8( str )
            }
        }

        CreateFormData.StrPutUTF8( BoundaryLine . "--" . CRLF )

        CreateFormData.pStream := ObjRelease(pStream) ; Should be 0.
        pData := DllCall("GlobalLock", "ptr", hData, "ptr")
        size := DllCall("GlobalSize", "ptr", pData, "uptr")

        ; Create a bytearray and copy data in to it.
        retData := ComObjArray( 0x11, size ) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
        pvData  := NumGet( ComObjValue( retData ), 8 + A_PtrSize , "ptr" )
        DllCall( "RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size )

        DllCall("GlobalUnlock", "ptr", hData)
        DllCall("GlobalFree", "Ptr", hData, "Ptr")                   ; free global memory

        retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
    }

    static StrPutUTF8( str ) {
        buf := Buffer(StrPut(str, "UTF-8") - 1) ; remove null terminator
        StrPut(str, buf, buf.size, "UTF-8")
        DllCall("shlwapi\IStream_Write", "ptr", CreateFormData.pStream, "ptr", buf.Ptr, "uint", buf.Size, "uint")
    }

    static LoadFromFile( filepath ) {
        DllCall("shlwapi\SHCreateStreamOnFileEx"
                    ,   "wstr", filepath
                    ,   "uint", 0x0             ; STGM_READ
                    ,   "uint", 0x80            ; FILE_ATTRIBUTE_NORMAL
                    ,    "int", False            ; fCreate is ignored when STGM_CREATE is set.
                    ,    "ptr", 0               ; pstmTemplate (reserved)
                    ,   "ptr*", &pFileStream:=0
                    ,   "uint")
        DllCall("shlwapi\IStream_Size", "ptr", pFileStream, "uint64*", &size:=0, "uint")
        DllCall("shlwapi\IStream_Copy", "ptr", pFileStream , "ptr", CreateFormData.pStream, "uint", size, "uint")
        ObjRelease(pFileStream)
    }

    static RandomBoundary() {
        str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
        Sort str, 'D| Random'
        str := StrReplace(str, "|")
        Return SubStr(str, 1, 12)
    }

    static MimeType(FileName) {
        n := FileOpen(FileName, "r").ReadUInt()
        Return (n        = 0x474E5089) ? "image/png"
            :  (n        = 0x38464947) ? "image/gif"
            :  (n&0xFFFF = 0x4D42    ) ? "image/bmp"
            :  (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
            :  (n&0xFFFF = 0x4949    ) ? "image/tiff"
            :  (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
            :  "application/octet-stream"
    }

}

; webhook
Webhook(URL, _params) {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", URL, true)
    
        ;_params := { content       : "Hello? <@" 400783672980144128 ">"
        ;            , username      : "Baya's Macro 🖱️⌨️"
        ;            , avatar_url    : "https://i.imgur.com/rTHyKfI.png"
        ;            , file          : [A_WorkingDir "\.imgs\.later.png"]  
        ;        }
        
    CreateFormData(&PostData, &hdr_ContentType, _params)
    
    whr.SetRequestHeader("Content-Type", hdr_ContentType)
    whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
        
    whr.Send(PostData)
    whr.WaitForResponse()
}

; notify
error_amount := 0

Notify(_string, _file := "") {
    if _ini.DiscordWebhookURL != "" {
        try {
            objParam := { content  : _string
                , username         : "Baya's Macro 🖱️⌨️"
                , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
            }
        
            if _file != "" {
                objParam := { content  : _string
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    , file          : [_file]  
                }
            }
        
            Webhook(_ini.DiscordWebhookURL, objParam) 
        } catch as e {
            error_amount += 1
            
            print("[Notify(" Format_Msec(A_TickCount - _status._start_script) ")] Error #" error_amount "!")

            if error_amount >= 3 {
                error_amount := 0
            } else {
                Notify(_string, _file)
            }

        } else {
            error_amount := 0
        }
    }
}

Format_Msec(ms) {
    VarSetStrCapacity(&t,256),DllCall("GetDurationFormat","uint",2048,"uint",0,"ptr",0,"int64",ms*10000,"wstr","hh':'mm':'ss","wstr",t,"int",256)
    return t
}

