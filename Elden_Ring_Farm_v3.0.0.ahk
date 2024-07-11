#Requires AutoHotkey v2.0
#Include misc.ahk
#Include CaptureScreen.ahk

SendMode 'Event'
CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

SetKeyDelay 0 50

Persistent
OnExit ExitFunc

; fileinstall
;icon
if !(FileExist(A_Temp "\.baya_icon.ico")) {
    FileInstall "C:\Users\ofhaq\Documents\.elden_ring\.imgs\.baya_icon.ico", A_Temp "\.baya_icon.ico", 1
} 
;settings
if !(FileExist(A_Temp "\.settings.png")) {
    FileInstall "C:\Users\ofhaq\Documents\.elden_ring\.imgs\.settings.png", A_Temp "\.settings.png", 1
} 
;next
if !(FileExist(A_Temp "\.next.png")) {
    FileInstall "C:\Users\ofhaq\Documents\.elden_ring\.imgs\.next.png", A_Temp "\.next.png", 1
} 
;compass_circle
if !(FileExist(A_Temp "\.compass_circle.png")) {
    FileInstall "C:\Users\ofhaq\Documents\.elden_ring\.imgs\.compass_circle.png", A_Temp "\.compass_circle.png", 1
} 
;x1
if !(FileExist(A_Temp "\.x1.png")) {
    FileInstall "C:\Users\ofhaq\Documents\.elden_ring\.imgs\.x1.png", A_Temp "\.x1.png", 1
} 

; objects
directories := Object()
images := Object()
data := Object()
status := Object()

; #pre-variables
directories.Images := "C:\Users\ofhaq\Documents\.elden_ring\.imgs\"

; images
images.Icon := A_Temp "\.baya_icon.ico" or directories.Images ".baya_icon.ico"

images.Settings := A_Temp "\.settings.png" or directories.Images ".settings.png"
images.Next := A_Temp "\.next.png" or directories.Images ".next.png"
images.CompassCircle := A_Temp "\.compass_circle.png" or directories.Images ".compass_circle.png"
images.x1 := A_Temp "\.x1.png" or directories.Images ".x1.png"

; variables
status.Ready := 0
status.ScreenCapturing := 0
status.MaxCaptureRunesRetry := 3
status.StartMonitoring := 0
status.UpdateTime := A_TickCount
status.UpdateRepeated := 0
status.PID := ""

autoFarmArray := ["Albinaurics", "Bird", "Skel-Band(Pilgrimage Church)"]
logArray := ["Stop Macro", "Close Game", "Shutdown PC", "Do Nothing"]
optionArray := ["Yes", "No"]

data.AutoFarmMethod := "Albinaurics"
data.LogMethod := "Stop Macro"
data.DiscordUserId := ""
data.DiscordWebhookURL := ""
data.DiscordTrack := "Yes"
data.DiscordInterval := 5

; #post-set
TraySetIcon(images.Icon) 

; #get-data
if (FileExist(A_WorkingDir "\Baya's Macro Settings.ini")) {
    try {
        settingsString := IniRead(A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName)

        settings := StrSplit(settingsString, "|")  
    
        data.AutoFarmMethod := settings[1]
        data.LogMethod := settings[2]
        data.DiscordUserId := settings[3]
        data.DiscordWebhookURL := settings[4]
        data.DiscordTrack := settings[5]
        data.DiscordInterval := settings[6]
    } catch as e {
        FileDelete(A_WorkingDir "\Baya's Macro Settings.ini")
    }
}

; #create-gui
myGui := Gui(, "Baya's Macro: Elden Ring Edition")
myGui.Opt("+AlwaysOnTop")
myGui.SetFont(, "Verdana")

myGui.AddGroupBox("Center xm5 ym+10 Section w200 h150", "Auto-Farm")
myGui.Add("Text","Center xs+10 ys+20 w180", "Which Auto Farming Method?")
myGui.AddDropDownList("Center w180 vAutoFarmMethod Choose" GetArrayValueIndex(autoFarmArray, data.AutoFarmMethod), autoFarmArray)

myGui.Add("Text","Center w180", "Auto Log?")
myGui.AddDropDownList("Center w180 vLogMethod Choose" GetArrayValueIndex(logArray, data.LogMethod), logArray)

myGui.AddButton("Center xs+0", "Save Settings").OnEvent("Click", StartUserInput)

myGui.AddGroupBox("Center xm+210 ym+10 Section w260 h175", "Discord Settings")
myGui.Add("Text","Center xs+10 ys+20 w240", "UserId")
myGui.AddEdit("Center w240 vDiscordUserId r1", data.DiscordUserId)
myGui.Add("Text","Center w240", "Webhook URL")
myGui.AddEdit("Center w240 vDiscordWebhookURL r1", data.DiscordWebhookURL)
myGui.Add("Text","Center w120", "Track Runes?")
myGui.AddDropDownList("Center w120 vDiscordTrack Choose" GetArrayValueIndex(optionArray, data.DiscordTrack), optionArray)
myGui.Add("Text","Center xs+133 ys+111 w120", "Intervals (mins)")
myGui.AddEdit("Center w120")
myGui.AddUpDown("vDiscordInterval Range5-60", data.DiscordInterval)

myGui.AddButton("Center xs+90 ys+160 w75 h20", "Test Ping").OnEvent("Click", TestUserPing)

myGui.OnEvent("Close", GuiClose)

myGui.Show

;settings
GuiClose(*) {
    ExitApp
}

StartUserInput(*)
{
    inputs := myGui.Submit()

    ; remove spaces
    fixDiscordURL := StrReplace(inputs.DiscordWebhookURL, A_Space)
    fixDiscordUserid := StrReplace(inputs.DiscordUserId, A_Space)

    inputs.DiscordWebhookURL := fixDiscordURL
    inputs.DiscordUserId := fixDiscordUserid

    ; check if valid discord url
    if SubStr(inputs.DiscordWebhookURL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("GET", inputs.DiscordWebhookURL, true)
        } catch as e {
            inputs.DiscordWebhookURL := ""
        }
    } else {
        inputs.DiscordWebhookURL := ""
    }

    settingsString := inputs.AutoFarmMethod "|" inputs.LogMethod "|" inputs.DiscordUserId "|" inputs.DiscordWebhookURL "|" inputs.DiscordTrack "|" inputs.DiscordInterval 

    IniWrite settingsString, A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName

    settings := StrSplit(settingsString, "|")  

    data.AutoFarmMethod := settings[1]
    data.LogMethod := settings[2]
    data.DiscordUserId := settings[3]
    data.DiscordWebhookURL := settings[4]
    data.DiscordTrack := settings[5]
    data.DiscordInterval := settings[6]

    status.Ready := 1
}
TestUserPing(*) {
    inputs := myGui.Submit()

    discordUserId := StrReplace(inputs.DiscordUserId, A_Space)
    discordWebhookId := StrReplace(inputs.DiscordWebhookURL, A_Space)

    ; check if valid discord url
    if SubStr(inputs.DiscordWebhookURL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            objParam := { content       : "Hello? <@" discordUserId ">"
                , username      : "Baya's Macro 🖱️⌨️"
                , avatar_url    : "https://i.imgur.com/rTHyKfI.png"
            }

            Webhook(discordWebhookId, objParam)
        } catch as e {
            MsgBox "Error!"
        } else {
            MsgBox "Test Ping Sent!"
        }
    } else {
        MsgBox "Make Sure it is a Discord Webhook!"
    }
          
    myGui.Show
}

; functions
Unbind() {
    Send("{Blind}{w Up}")
    Send("{Blind}{a Up}")
    Send("{Blind}{s Up}")
    Send("{Blind}{d Up}")

    Send("{Blind}{Numpad8 Up}")
    Send("{Blind}{Numpad4 Up}")
    Send("{Blind}{Numpad2 Up}")
    Send("{Blind}{Numpad6 Up}")

    Send("{Blind}{LShift Up}")
}

ExitFunc(ExitReason, ExitCode) {
    Unbind()

    if FileExist(A_Temp "\.runes.png") {
        FileDelete A_Temp "\.runes.png"
    }   

    for name, file in images.OwnProps() {
        if InStr(file, "\AppData\Local\Temp\") and FileExist(file) {
            FileDelete file
        }
    }
}

WaitForNextCome() {
    LoopSkip := A_TickCount
    Tried := 1

    while !ImageSearch(&FoundX, &FoundY, 0, 800, 800, 1080, "*50 " images.Next) {
        Sleep 100

        if A_TickCount - LoopSkip >= 2000 and Tried != 1 {
            Send("{Blind}{Esc Down}")
            Sleep 20
            Send("{Blind}{Esc Up}")
            
            Sleep 350
        }
        
        Tried := 0

        if ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) {
            Send("{Blind}{Esc Down}")
            Sleep 20
            Send("{Blind}{Esc Up}")

            Sleep 350

            Send("{Blind}{m Down}")
            Sleep 20
            Send("{Blind}{m Up}")

            Sleep 350

            LoopSkip := A_TickCount

            Tried := 1
        }

        if ImageSearch(&FoundX, &FoundY, 1787, 83, 1822, 117, "*50 " images.CompassCircle) {
            Send("{Blind}{f Down}")
            Sleep 20
            Send("{Blind}{f Up}")

            Sleep 350

            Send("{Blind}{Enter Down}")
            Sleep 20
            Send("{Blind}{Enter Up}")

            Sleep 350

            Send("{Blind}{Enter Down}")
            Sleep 20
            Send("{Blind}{Enter Up}")

            Sleep 350

            LoopSkip := A_TickCount

            Tried := 1
        }
    }
}

WaitForNextGone() {
    LoopSkip := A_TickCount

    while ImageSearch(&FoundX, &FoundY, 0, 800, 800, 1080, "*50 " images.Next) and A_TickCount - LoopSkip < 5000 { ; skips loop after 5 seconds
        Sleep 100
    }

    Sleep 2000
}

WaitLoading() {
    WaitForNextCome()
    WaitForNextGone()
}

ResetGrace() {
    LoopSkip := A_TickCount

    while !ImageSearch(&FoundX, &FoundY, 1787, 83, 1822, 117, "*50 " images.CompassCircle) {
        if A_TickCount - LoopSkip >= 30000 { ; skips loop after 30 seconds
            Notify("<@" data.DiscordUserId "> Cannot open map... `nTried for 30 seconds, closing Baya's Macro!")

            ExitApp
        }

        Send("{Blind}{m Down}")
        Sleep 20
        Send("{Blind}{m Up}")

        Sleep 350
    }

    Send("{Blind}{f Down}")
    Sleep 20
    Send("{Blind}{f Up}")

    Sleep 350

    Send("{Blind}{Enter Down}")
    Sleep 20
    Send("{Blind}{Enter Up}")

    Sleep 350

    Send("{Blind}{Enter Down}")
    Sleep 20
    Send("{Blind}{Enter Up}")
}

GoToAlbinaurics() {
    Send("{Blind}{LShift Down}") ; start sprinting

    Send("{Blind}{w Down}")
    Sleep 1500
    Send("{Blind}{w Up}")

    Send("{Blind}{Numpad4 Down}")
    Sleep 225
    Send("{Blind}{Numpad4 Up}")

    Send("{Blind}{w Down}")
    Sleep 2000
    Send("{Blind}{w Up}")

    Send("{Blind}{LShift Up}") ; stop sprinting

    Send("{Blind}{Numpad2 Down}")
    Sleep 75
    Send("{Blind}{Numpad2 Up}")

    Send("{Blind}{f Down}")
    Sleep 20
    Send("{Blind}{f Up}")

    Sleep 6000
}

GoToBird() {
    Send("{Blind}{Numpad4 Down}")
    Sleep 460
    Send("{Blind}{Numpad4 Up}")

    Send("{Blind}{w Down}")
    Sleep 1800
    Send("{Blind}{w Up}")

    Send("{Blind}{Numpad4 Down}")
    Sleep 50
    Send("{Blind}{Numpad4 Up}")

    Send("{Blind}{Numpad2 Down}")
    Sleep 300
    Send("{Blind}{Numpad2 Up}")

    Send("{Blind}{MButton Down}")
    Sleep 20
    Send("{Blind}{MButton Up}")

    Sleep 250
    
    Send("{Blind}{f Down}")
    Sleep 250
    Send("{Blind}{Click Left}")
    Sleep 250
    Send("{Blind}{f Up}")

    Sleep 6000
}

GoToSkeleton() {
    if data.AutoFarmMethod = "Skel-Band(Pilgrimage Church)" {
        Send("{Blind}{LShift Down}")

        Send("{Blind}{w Down}")
        Sleep 3000
        Send("{Blind}{w Up}")

        Send("{Blind}{Numpad4 Down}")
        Sleep 500
        Send("{Blind}{Numpad4 Up}")

        Send("{Blind}{w Down}")
        Sleep 3475
        Send("{Blind}{w Up}")

        Send("{Blind}{Numpad4 Down}")
        Sleep 570
        Send("{Blind}{Numpad4 Up}")

        Sleep 150

        Send("{Blind}{MButton Down}")
        Sleep 20
        Send("{Blind}{MButton Up}")

        Send("{Blind}{w Down}")
        Sleep 725
        Send("{Blind}{Space Down}")
        Send("{Blind}{w Up}")
        Send("{Blind}{LControl Down}")
        Sleep 20
        Send("{Blind}{Space Up}")
        Send("{Blind}{Click Left 2}")
        Send("{Blind}{LControl Up}")

        Send("{Blind}{MButton Down}")
        Sleep 20
        Send("{Blind}{MButton Up}")
        Send("{Blind}{LShift Up}")

        Sleep 3000

        Send("{Blind}{Numpad4 Down}")
        Sleep 50
        Send("{Blind}{Numpad4 Up}")
        
        Send("{Blind}{w Down}")
        Sleep 20
        Send("{Blind}{LShift Down}")
        Sleep 20
        Send("{Blind}{LShift Up}")
        Sleep 20
        Send("{Blind}{w Up}")

        Sleep 1000
        Send("{Blind}{Click Left}")

        Send("{Blind}{Numpad2 Down}")
        Sleep 250
        Send("{Blind}{Numpad2 Up}")

        Sleep 3500
        Send("{e 3}")

        LoopSkip := A_TickCount

        while !ImageSearch(&FoundX, &FoundY, 1489, 818, 1909, 882, "*50 " images.x1) and A_TickCount - LoopSkip < 1500 {
            Sleep 100
        }

        if ImageSearch(&FoundX, &FoundY, 1489, 818, 1909, 882, "*50 " images.x1) {
            MsgBox "ITEM COLLECTED"
        }
        
    }
}

AutoAlbinaurics() {
    Loop {
        ResetGrace()
        WaitLoading()
        GoToAlbinaurics()

        status.UpdateRepeated += 1

        UpdateStatsToDiscord()
    }
}
AutoBird() {
    Loop {
        ResetGrace()
        WaitLoading()
        GoToBird()

        status.UpdateRepeated += 1

        UpdateStatsToDiscord()
    }
}

AutoSkeleton() {
    Loop {
        ResetGrace()
        WaitLoading()
        GoToSkeleton()

        status.UpdateRepeated += 1
    }
}

ReturnToDesktop() {
    LoopSkip := A_TickCount

    while !ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) {
        if A_TickCount - LoopSkip >= 30000 { ; skips loop after 30 seconds
            Notify("<@" data.DiscordUserId "> Cannot find settings... `nTried for 30 seconds, closing Baya's Macro!")

            ExitApp
        }

        Send("{Blind}{Esc Down}")
        Sleep 20
        Send("{Blind}{Esc Up}")

        Sleep 250
    }

    MovingMouse(FoundX, FoundY, "left", 2)

    Sleep 250

    Send("{Blind}{z Down}")
    Sleep 20
    Send("{Blind}{z Up}")

    Sleep 250

    MovingMouse(1161, 745, "left", 2)

    Sleep 250

    MovingMouse(748, 569, "left", 2)
}

CheckDied() {
    if PixelSearch(&_, &_, 157, 48, 163, 56, 0x9A8422, 3) { 
        Notify("<@" data.DiscordUserId "> `nYou have Died!`nEnding Baya's Macro: Elden Ring Edition Momentarily...")

        if data.LogMethod != "Do Nothing" {

            if data.LogMethod = "Shutdown PC" {
                Notify("Returning to Desktop to Avoid Data Corrupting...`n(Process will take around 1 minute to finalize, you will be notified with the results)")

                WaitLoading()

                ReturnToDesktop()

                ProcessWaitClose(status.PID, 60)

                if WinExist("ELDEN RING™") {
                    Notify(":negative_squared_cross_mark:")

                    WinClose
                } else {
                    Notify(":white_check_mark:")
                }
                  
                Notify("<@" data.DiscordUserId "> Shutting Down PC NOW!")

                Shutdown 9

                ExitApp
            }
            if data.LogMethod = "Close Game" {
                Notify("Returning to Desktop to Avoid Data Corrupting...`n(Process will take around 1 minute to finalize, you will be notified with the results)")

                WaitLoading()

                ReturnToDesktop()

                ProcessWaitClose(status.PID, 60)

                if WinExist("ELDEN RING™") {
                    Notify(":negative_squared_cross_mark:")

                    WinClose
                } else {
                    Notify(":white_check_mark:")
                }

                ExitApp
            }
            if data.LogMethod = "Stop Macro" {
                Notify("Macro will be stopped now`nCollect your lost runes!")

                ExitApp
            }
        }
    }
}

Notify(text) {
    try {
        objParam := { content  : text
            , username         : "Baya's Macro 🖱️⌨️"
            , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
        }

        Webhook(data.DiscordWebhookURL, objParam) 
    }
}

CaptureRunes() {
    if status.ScreenCapturing != 1 {
        status.ScreenCapturing := 1

        try {
            tried := 0
        
            while !ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) and tried < status.MaxCaptureRunesRetry {
                Send("{Blind}{Esc Down}")
                Sleep 20
                Send("{Blind}{Esc Up}")

                Sleep 500

                tried += 1
            }
        
            if ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) {
                outfile := A_Temp "\.runes.png"
                CaptureScreen( "1672, 1017, 1869, 1052", 0, outfile)

                Sleep 500
            } 
            
            Send("{Blind}{Esc Down}")
            Sleep 20
            Send("{Blind}{Esc Up}")
        }
        catch as e  {
            status.ScreenCapturing := 0

            CaptureRunes()
        } else {
            status.ScreenCapturing := 0
        }
    }
}

UpdateStatsToDiscord() {
    if data.DiscordWebhookURL != "" and data.DiscordTrack = "Yes" {
        if status.StartMonitoring != 1 {
            status.StartMonitoring := 1 ; Monitor Started
    
            ; ss
            CaptureRunes()
            
            try {
                TimeString := FormatTime(, "dddd MMMM d, yyyy hh:mm:ss tt")

                contentText := "**Monitoring Started**`n➼  *Total Repeat:* __indefinite__`n➼  *Interval:* __every " data.DiscordInterval " minutes__`n➼  *Farming Method:* __" data.AutoFarmMethod "__`n➼  *Tracked Time:* __" TimeString "__"

                objParam := { content  : contentText
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    , file             : [A_Temp "\.runes.png"]
                }
        
                Webhook(data.DiscordWebhookURL, objParam)
            }
             
            
            if FileExist(A_Temp "\.runes.png") {
                FileDelete A_Temp "\.runes.png"
            }
        } else if A_TickCount - status.UpdateTime >= (data.DiscordInterval * 60000) {
            status.UpdateTime := A_TickCount
        
            ; ss
            CaptureRunes()
    
            try {
                TimeString := FormatTime(, "dddd MMMM d, yyyy hh:mm:ss tt")

                contentText := "**Interval Report**`n➼  *Repeated:* __" status.UpdateRepeated "__`n➼  *Interval:* __every " data.DiscordInterval " minutes__`n➼  *Farming Method:* __" data.AutoFarmMethod "__`n➼  *Tracked Time:* __" TimeString "__"

                objParam := { content  : contentText
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    , file             : [A_Temp "\.runes.png"]
                }
                        
                Webhook(data.DiscordWebhookURL, objParam) 
            }
                 
            if FileExist(A_Temp "\.runes.png") {
                FileDelete A_Temp "\.runes.png"
            }            
        }
    }
}

; HANDLER ________________________________________________________________
;retrieve
RetrievePID() {
    if WinExist("ELDEN RING™") {
        status.PID := WinGetPID("ELDEN RING™")
        return status.PID
    }
}

RetrieveReady() {
    return status.Ready
}

RetrieveAutoFarmMethod() {
    return data.AutoFarmMethod
}