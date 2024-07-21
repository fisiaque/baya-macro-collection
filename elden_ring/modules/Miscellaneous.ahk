;#objects
check := Object()

;#variables
check.bot_tries := 0

;#global
global file_extensions := ['jpg','jpeg','png','gif','ico']
 
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
        print("[WithinRange] Not Given Number")
    }

    return 0
}

CheckBotNotActive() {
    check.bot_tries += 1

    if !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
        return 1
    } else {
        try {
            RunWait '*RunAs taskkill.exe /F /T /IM BayaMacroBot.exe',, 'Hide'
           
            ProcessWaitClose("BayaMacroBot.exe", 15)
            
            if !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
                return 1
            } else {
                if check.bot_tries < 3 {
                    CheckBotNotActive()
                } else {
                    return 0
                }
            }
            
        } catch as e {
            if check.bot_tries < 3 {
                CheckBotNotActive()
            } else {
                return 0
            }
        } 
    }
}

ExitFunction(ExitReason, ExitCode) {
    SoundBeep(250)

    print("[ExitFunction] Processing Closure...")

    SetTimer(Checks, 0)
    
    _status._running := 0
    
    ; checks if bot is not active before delete exe
    if CheckBotNotActive() == 1 {
        ; delete bot exe
        if FileExist(A_WorkingDir "\BayaMacroBot.exe") and !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
            FileDelete A_WorkingDir "\BayaMacroBot.exe"
            print("[ExitFunction] BayaMacroBot.exe Deleted")
        }
    }

    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
            print("[ExitFunction] " A_LoopFileName " Deleted")
        }
    }
} 

DiscordBotCheck(discord_Token) {
    if discord_Token != "" and CheckBotNotActive() == 1 {
        print("[DiscordBotCheck] Loading... (Timeout in 10s)")
    
        A_Clipboard := "" ;Empty Clipboard
    
        Run(EnvGet("BayaMacroBot"))
        
        ClipWait(10)

        if A_Clipboard == "success" {
            print("[DiscordBotCheck] Successfully Activated!")
        } else {
            print("[DiscordBotCheck] Failed to Activate")
        }

        A_Clipboard := "" ;Empty Clipboard
    } else if discord_Token == "" {
        print("[DiscordBotCheck] Empty Discord Token")
    }
}

GithubUpdate() {
    ; #check macro version
    latestObj := Github.latest("bayamacro", "Baya-Macro-Elden-Ring-Edition")

    if GetVersion() != latestObj.version {
        print("[GithubUpdate] Update Macro?")
        Result := MsgBox("Update Baya's Macro? (" latestObj.version ") `r`n- new file will be available at the same file directory `r`n- old file will be deleted after a few seconds", "Auto-Update", "YesNo T10 0x40000")

        if Result = "Yes"{
            print("[GithubUpdate] Updated | Check Directory")
            Github.Download(latestObj.downloadURLs[1], A_ScriptDir "\Baya's Macro Elden Ring Edition")

            if A_IsCompiled != 0 { ; if compiled
                print("[GithubUpdate] Deleting this executable...")

                Run A_ComSpec ' /c ping -n 3 127.0.0.1>nul & Del ' A_ScriptName,, 'Hide'
                ExitApp
            }
        } else {
            print("[GithubUpdate] Cancelled")
        }     
    }
}

RunAsTask(SingleInstance := 0, Shortcut := "") ; RunAsTask() v0.23 - Auto-elevates script without UAC prompt
{                                              ;    By SKAN for ah2 on D67M/D683 @ autohotkey.com/r?t=119710
    Global A_Args

    Local  TaskSchd,  TaskRoot,  TaskName,  RunAsTask,  TaskExists
        ,  CmdLine,  PathCrc,  Args,  XML,  AhkPath,  Description
        ,  STMM  :=  A_TitleMatchMode
        ,  DHW   :=  A_DetectHiddenWindows
        ,  SWD   :=  A_WinDelay
        ,  QUO   :=  '"'

    A_TitleMatchMode      :=  1
    A_DetectHiddenWindows :=  1
    A_WinDelay            :=  0

    Try    TaskSchd  :=  ComObject("Schedule.Service")
      ,    TaskSchd.Connect()
      ,    TaskRoot  :=  TaskSchd.GetFolder("\")
    Catch
           Return

    Loop Files A_AhkPath
         AhkPath  :=  A_LoopFileFullPath

    CmdLine  :=  A_IsCompiled ? QUO A_ScriptFullpath QUO :  QUO AhkPath QUO A_Space QUO A_ScriptFullpath QUO
    PathCrc  :=  DllCall("ntdll\RtlComputeCrc32", "int",0, "wstr",CmdLine, "uint",StrLen(CmdLine)*2, "uint")
    TaskName :=  Format("RunAsTask\{1:}_{2:}@{3:08X}", A_ScriptName, A_PtrSize=8 ? "64" : "32", PathCrc)

      Try  RunAsTask  :=  TaskRoot.GetTask(TaskName)
        ,  TaskExists :=  1
    Catch
           TaskExists :=  0


    If ( A_IsAdmin = False )
    {
         If ( A_Args.Length > 0 )
              Args := Format(StrReplace(Format("{:" A_Args.Length "}",""), "`s", "`n{}"), A_Args*)  ; Join()
          ,   WinSetTitle(TaskName Args , A_ScriptHwnd)

         If ( TaskExists = True )
              Try    RunAsTask.Run(0)
              Catch
                     MsgBox("Task launch failed (disabled?):`n" TaskName, "RunAsTask", " 0x40000 Iconx")
                  ,  ExitApp()

         If ( TaskExists = False )
              Try    Run("*RunAs " CmdLine, A_ScriptDir)
              Catch
                     MsgBox("Task not created..`nChoose 'Yes' in UAC",    "RunAsTask", " 0x40000 Iconx T4")
                  ,  ExitApp()

         If ( A_Args.Length > 0 )
              WinWait("Exit_" TaskName " ahk_class AutoHotkey",, 5)

         ExitApp()
    }


    If ( A_IsAdmin = True )
    {
        If ( TaskExists = False )
             XML :=  Format('
                           ( LTrim
                             <?xml version="1.0" ?>
                             <Task xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
                                 <Principals>
                                     <Principal>
                                         <LogonType>InteractiveToken</LogonType>
                                         <RunLevel>HighestAvailable</RunLevel>
                                     </Principal>
                                 </Principals>
                                 <Settings>
                                     <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
                                     <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
                                     <AllowHardTerminate>true</AllowHardTerminate>
                                     <AllowStartOnDemand>true</AllowStartOnDemand>
                                     <Enabled>true</Enabled>
                                     <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
                                 </Settings>
                                 <Actions>
                                     <Exec>
                                         <Command>{1:}</Command>
                                         <Arguments>{2:}</Arguments>
                                         <WorkingDirectory>{3:}</WorkingDirectory>
                                     </Exec>
                                 </Actions>
                             </Task>
                          )'
                          ,  A_IsCompiled = 1  ?  QUO A_ScriptFullpath QUO  :  QUO AhkPath QUO
                          ,  A_IsCompiled = 0  ?  QUO A_ScriptFullpath QUO  :  ""
                          ,  A_ScriptDir
                          )
         ,   TaskRoot.RegisterTask( TaskName
                                  , XML
                                  , 0x2  ; TASK_CREATE
                                  , ""
                                  , ""
                                  , 3    ; TASK_LOGON_INTERACTIVE_TOKEN
                                  )

        If ( StrLen(Shortcut) )
             Try   FileGetShortcut(Shortcut,,,, &Description)
             Catch
                   Description := ""
             Finally
              If ( Description != Taskname )
                   FileCreateShortcut("schtasks.exe", Shortcut, A_WorkingDir
                                    , "/run /tn " QUO TaskName QUO, TaskName,,,,7)

        If ( SingleInstance )
             DllCall( "User32\ChangeWindowMessageFilterEx"
                    , "ptr",  A_ScriptHwnd
                    , "uint", 0x44       ;  WM_COMMNOTIFY
                    , "uint", 1          ;  MSGFLT_ALLOW
                    , "ptr",  0
                    )

        If ( WinExist(TaskName " ahk_class AutoHotkey") )
             Args   :=  WinGetTitle()
         ,   WinSetTitle("Exit_" TaskName)
         ,   Args   :=  SubStr(Args, InStr(Args, "`n") + 1)
         ,   A_Args :=  StrSplit(Args, "`n")
    }

    A_WinDelay            :=  SWD
    A_DetectHiddenWindows :=  DHW
    A_TitleMatchMode      :=  STMM

    Return TaskName
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

Checks() {
    if _status._running == 1 {
        static _notified := A_TickCount

        ;-- window checks
        if WinExist("ELDEN RING™") {
            WinGetClientPos &_, &_, &_game_Width, &_game_Height, "ELDEN RING™"

            if _game_Width != 800 && _game_Height != 450 { 
                _status._macro := 0 ; macro stops it wrong resolution 

                if A_TickCount - _notified >= 10000 { ; prints out every 10 seconds
                    _notified := A_TickCount

                    _time_String := FormatTime("hm", "Time")
                    print("[Checks] (" _time_String ") : In-game resolution must be 800x450 'Windowed'")

                    SoundBeep(1000)
                }
                
                return
            }

            WinActivate
            WinWaitActive

            WinMove 0,0

            _status._macro := 1 ; macro starts when everything works
        } else {
            _status._macro := 0 ; when elden ring doesn't exist macro stops
        }
    } else {
        _status._macro := 0 ; when macro paused macro stops
    }
}