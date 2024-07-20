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
	Loop arr.Length {
		if (InStr(arr[A_Index], val))
			return A_Index
	}
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
    SoundBeep(1500)

    print("[ExitFunction] Processing Closure...")
    
    ; loop through temp files
    Loop Files, A_Temp "\*.*" { 
        if (InStr(A_LoopFileName, "baya") or IsFileExtenstion(A_LoopFileExt) == 1) {
            FileDelete A_LoopFileFullPath
            print("[ExitFunction] " A_LoopFileName " Deleted")
        }
    }

    ; checks if bot is not active before delete exe
    if CheckBotNotActive() == 1 {
        ; delete bot exe
        if FileExist(A_WorkingDir "\BayaMacroBot.exe") and !(ProcessExist("BayaMacroBot.exe")) and !(WinExist("BayaMacroBot.exe")) {
            FileDelete A_WorkingDir "\BayaMacroBot.exe"
            print("[ExitFunction] BayaMacroBot.exe Deleted")
        }
    }
} 

DiscordBotCheck(discord_Token) {
    if discord_Token != "" and CheckBotNotActive() == 1 {
        print("[DiscordBotCheck] Activating Discord Command Bot...")
    
        A_Clipboard := "" ;Empty Clipboard
    
        Run(EnvGet("BayaMacroBot"))
    
        if ClipWait(10) and A_Clipboard == "success" {
            
            print("[DiscordBotCheck] success")
        } else {
            print("[DiscordBotCheck] fail")
        }

        A_Clipboard := "" ;Empty Clipboard
    }
}

GithubUpdate() {
    ; #check macro version
    latestObj := Github.latest("fiziaque", "Baya-Macro-Elden-Ring-Edition")

    if GetVersion() != latestObj.version {
        print("[GithubUpdate] Update Macro?")
        Result := MsgBox("Update Baya's Macro? (" latestObj.version ") `r`n- new file will be available at the same file directory `r`n- old file will be deleted after a few seconds", "Auto-Update", "YesNo T10")

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