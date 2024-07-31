if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

; objects
arrays := Object()
status := Object()

; variable
gui_Width := 216
gui_Height := 68

title := "Baya's Console"

arrays.Position := Array()

WinGetPos(,,, &_h_, "ahk_class Shell_TrayWnd")

arrays.Position := [(A_ScreenWidth) - gui_Width, (A_ScreenHeight) - (gui_Height + _h_)]

; status
status.String := "[OutputConsole(" Format_Msec(A_TickCount - _status._start_script) ")] Initiated`r`n" 
status.MaxMessage := 7  ; last 5 messages show up

; functions
GetLine(Text, var) {
    StrReplace(Text, var, Text, "Off", &Output)
    Return ( ( (var = "`n" || var = "`r") && (Text) ) ? Output + 1 : Output )
}

print(NewMessage) {
    status.String .= NewMessage "`r`n" 

    if (GetLine(status.String, "`n") > status.MaxMessage) {
        status.String := SubStr(status.String, InStr(status.String, "`n") + 1)
    }

    consoleGui['Status'].Text := status.String
    consoleGui.Submit(false)
    
    SendMessage(0x0115, 7, 0, "Edit1", title)
}

; gui
consoleGui := Gui("+AlwaysOnTop -Caption +ToolWindow") ; +Disabled 
consoleGui.Title := title
consoleGui.SetFont("cBlack")

consoleGui.AddText("xm-8 ym Center", "Baya's Macro '[' to Start ']' to Stop")
consoleGui.AddEdit("xm-8 ym+18 +Multi +Wrap +ReadOnly +r3 W214 h43 vStatus", status.String)
consoleGui.AddGroupBox("xm-10 ym-12 w300 h30")

consoleGui.Show("w" gui_Width " h" gui_Height " x" arrays.Position[1] " y" arrays.Position[2]) ;
