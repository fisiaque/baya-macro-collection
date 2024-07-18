#Requires AutoHotkey v2.0
#SingleInstance Force

; objects
arrays := Object()

; variable
title := "Baya's Console"
arrays.Position := []
gui_Width := 216
gui_Height := 68

; status
Global Status := "[OutputConsole] Baya's Console Initialized!"

; functions
GetLine(Text, var) {
    StrReplace(Text, var, , "Off", , -1)
    Return ( ( (var = "`n" || var = "`r") && (Text) ) ? -1 + 1 : -1 )
}

WinGetPos(,,, &_h_, "ahk_class Shell_TrayWnd")

arrays.Position := [(A_ScreenWidth) - gui_Width, (A_ScreenHeight) - (gui_Height + _h_)]

consoleGui := Gui("+AlwaysOnTop -Caption +ToolWindow") ; +Disabled 
consoleGui.Title := title
consoleGui.SetFont("cBlack")

consoleGui.AddText("xm-8 ym Center", "Baya's Macro '[' to Start ']' to Stop")
consoleGui.AddEdit("xm-8 ym+18 +Wrap +ReadOnly +r3 W214 h43 vStatus", Status)
consoleGui.AddGroupBox("xm-10 ym-12 w300 h30")

consoleGui.Show("w" gui_Width " h" gui_Height " x" arrays.Position[1] " y" arrays.Position[2]) ;

print(NewMessage) {
    global Status := Status "`r`n" NewMessage 
    If (GetLine(Status, "`n") > 4)
        Status := SubStr(Status, InStr(Status,"`n") + 1)
        
    consoleGui['Status'].Text := Status
    consoleGui.Submit(false)
    
    SendMessage(0x0115, 7, 0, "Edit1", title)
}
