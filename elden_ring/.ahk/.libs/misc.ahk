
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
Webhook(URL, objParam) {
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", URL, true)
    
        ;objParam := { content       : "Hello? <@" 400783672980144128 ">"
        ;            , username      : "Baya's Macro 🖱️⌨️"
        ;            , avatar_url    : "https://i.imgur.com/rTHyKfI.png"
        ;            , file          : [A_WorkingDir "\.imgs\.later.png"]  
        ;        }
        
    CreateFormData(&PostData, &hdr_ContentType, objParam)
    
    whr.SetRequestHeader("Content-Type", hdr_ContentType)
    whr.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko")
    ; whr.Option(6) := False ; No auto redirect
        
    whr.Send(PostData)
    whr.WaitForResponse()
    
    ;MsgBox whr.ResponseText
}

; get array
GetArrayValueIndex(arr, val) {
	Loop arr.Length {
		if (InStr(arr[A_Index], val))
			return A_Index
	}
}

MovingMouse(x, y, type, amount) {
    MouseGetPos &xpos, &ypos 

    SendMode 'Event'
    MouseMove x - xpos, y - ypos, 2, "R"
    MouseClick type, x, y, amount
}