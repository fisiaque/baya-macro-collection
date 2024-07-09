#Requires AutoHotkey v2.0
#SingleInstance Force

#Include misc.ahk

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

; variables
status.Ready := 0

autoFarmArray := ["Albinaurics", "Bird"]
logArray := ["Do Nothing", "Close Game", "Shutdown PC"]
optionArray := ["Yes", "No"]

data.AutoFarmMethod := "Bird"
data.LogMethod := "Do Nothing"
data.DiscordUserId := ""
data.DiscordWebhookURL := ""
data.DiscordTrack := "No"

; #post-set
TraySetIcon(images.Icon) 

; #get-data
if (FileExist(A_WorkingDir "\Baya's Macro Settings.ini")) {
    settingsString := IniRead(A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName)

    settings := StrSplit(settingsString, "|")  

    data.AutoFarmMethod := settings[1]
    data.LogMethod := settings[2]
    data.DiscordUserId := settings[3]
    data.DiscordWebhookURL := settings[4]
    data.DiscordTrack := settings[5]
}

; #create-gui
myGui := Gui(, "Baya's Macro: Elden Ring Edition")
myGui.Opt("+AlwaysOnTop")

myGui.AddGroupBox("Center xm5 ym+10 Section w140 h150", "Auto-Farm")
myGui.Add("Text","Center xs+10 ys+20 w120", "Which Auto Farming Method?")
myGui.AddDropDownList("Center w120 vAutoFarmMethod Choose" GetArrayValueIndex(autoFarmArray, data.AutoFarmMethod), autoFarmArray)

myGui.Add("Text","Center w120", "Auto Log?")
myGui.AddDropDownList("Center w120 vLogMethod Choose" GetArrayValueIndex(logArray, data.LogMethod), logArray)

myGui.AddButton("Center xs+50", "Save Settings").OnEvent("Click", StartUserInput)

myGui.AddGroupBox("Center xm+160 ym+10 Section w140 h175", "Discord Settings")
myGui.Add("Text","Center xs+10 ys+20 w120", "UserId")
myGui.AddEdit("Center w120 vDiscordUserId r1", data.DiscordUserId)
myGui.Add("Text","Center w120", "Webhook URL")
myGui.AddEdit("Center w120 vDiscordWebhookURL r1", data.DiscordWebhookURL)
myGui.Add("Text","Center w120", "Track Runes?")
myGui.AddDropDownList("Center w120 vDiscordTrack Choose" GetArrayValueIndex(optionArray, data.DiscordTrack), optionArray)

myGui.AddButton("Center xs+35 ys+160 w75 h20", "Test Ping").OnEvent("Click", TestUserPing)

myGui.Show

;settings
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

    settingsString := inputs.AutoFarmMethod "|" inputs.LogMethod "|" inputs.DiscordUserId "|" inputs.DiscordWebhookURL "|" inputs.DiscordTrack 

    IniWrite settingsString, A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName

    settings := StrSplit(settingsString, "|")  

    data.AutoFarmMethod := settings[1]
    data.LogMethod := settings[2]
    data.DiscordUserId := settings[3]
    data.DiscordWebhookURL := settings[4]
    data.DiscordTrack := settings[5]

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
ExitFunc(ExitReason, ExitCode) {
    for name, file in images.OwnProps() {
        if InStr(file, "\AppData\Local\Temp\") {
            FileDelete file
        }
    }
}

WaitLoading() {
    while !PixelSearch(&_, &_, 959, 134, 960, 135, 0xA5A38B, 3) {
        Sleep 250
    }

    Sleep 500
}

ResetGrace() {
    Send("{Blind}{m Down}")
    Sleep 20
    Send("{Blind}{m Up}")

    CheckDied()

    Sleep 350

    CheckDied()

    Send("{Blind}{f Down}")
    Sleep 20
    Send("{Blind}{f Up}")

    CheckDied()

    Sleep 350

    CheckDied()

    Send("{Blind}{Enter Down}")
    Sleep 20
    Send("{Blind}{Enter Up}")

    CheckDied()

    Sleep 350

    CheckDied()

    Send("{Blind}{Enter Down}")
    Sleep 20
    Send("{Blind}{Enter Up}")
}

GoToAlbinaurics() {
    Send("{Blind}{w Down}")
    Sleep 2500
    Send("{Blind}{w Up}")

    CheckDied()

    Send("{Blind}{Numpad4 Down}")
    Sleep 225
    Send("{Blind}{Numpad4 Up}")

    CheckDied()

    Send("{Blind}{w Down}")
    Sleep 3000
    Send("{Blind}{w Up}")

    CheckDied()

    Send("{Blind}{MButton Down}")
    Sleep 20
    Send("{Blind}{MButton Up}")

    Send("{Blind}{Numpad6 Down}")
    Sleep 20
    Send("{Blind}{Numpad6 Up}")

    Send("{Blind}{Numpad6 Down}")
    Sleep 20
    Send("{Blind}{Numpad6 Up}")

    Send("{Blind}{f Down}")
    Sleep 20
    Send("{Blind}{f Up}")

    CheckDied()

    Sleep 3000

    CheckDied()

    Sleep 3000

    CheckDied
}

GoToBird() {
    Send("{Blind}{Numpad4 Down}")
    Sleep 475
    Send("{Blind}{Numpad4 Up}")

    CheckDied()

    Send("{Blind}{w Down}")
    Sleep 1750
    Send("{Blind}{w Up}")

    CheckDied()

    Send("{Blind}{Numpad2 Down}")
    Sleep 250
    Send("{Blind}{Numpad2 Up}")

    CheckDied()

    Send("{Blind}{Numpad4 Down}")
    Sleep 45
    Send("{Blind}{Numpad4 Up}")

    Send("{Blind}{MButton Down}")
    Sleep 20
    Send("{Blind}{MButton Up}")

    CheckDied()

    Send("{Blind}{f Down}")
    Sleep 250
    Send("{Blind}{Click Left}")
    Sleep 250
    Send("{Blind}{f Up}")

    CheckDied()

    Sleep 3000

    CheckDied()

    Sleep 3000

    CheckDied
}

AutoAlbinaurics() {
    Loop {
        ResetGrace()
        WaitLoading()
        GoToAlbinaurics()
    }
}
AutoBird() {
    Loop {
        ResetGrace()
        WaitLoading()
        GoToBird()
    }
}

ReturnToDesktop() {
    if !ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) {
        Send("{Blind}{Esc Down}")
        Sleep 20
        Send("{Blind}{Esc Up}")

        Sleep 250
    }
    
    if ImageSearch(&FoundX, &FoundY, 38, 773, 137, 872, "*50 " images.Settings) {
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
}

CheckDied() {
    if PixelSearch(&_, &_, 162, 51, 163, 52, 0x9A8422, 3) or PixelSearch(&_, &_, 162, 51, 163, 52, 0x100A0F, 3) { 
        try {
            objParam := { content  : "<@" data.DiscordUserId "> You have Died!"
                , username         : "Baya's Macro 🖱️⌨️"
                , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
            }

            Webhook(data.DiscordWebhookURL, objParam) 
        }

        if data.LogMethod != "Do Nothing" {
            if data.LogMethod = "Shutdown PC" {
                try {
                    objParam := { content  : "Returning to Desktop to Avoid Data Corrupting...`n(Process will take around 1 minute to finalize)"
                        , username         : "Baya's Macro 🖱️⌨️"
                        , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    }
            
                    Webhook(data.DiscordWebhookURL, objParam) 
                }

                ReturnToDesktop()

                Sleep 60000 ; sleeps for 60 seconds for elden ring to fully close

                if WinExist("ELDEN RING™") {
                    try {
                        objParam := { content  : "FAIL"
                            , username         : "Baya's Macro 🖱️⌨️"
                            , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                        }
        
                        Webhook(data.DiscordWebhookURL, objParam) 
                    }

                    WinClose
                } else {
                    try {
                        objParam := { content  : "SUCCESS"
                            , username         : "Baya's Macro 🖱️⌨️"
                            , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                        }
        
                        Webhook(data.DiscordWebhookURL, objParam) 
                    }
                }
                    
                try {
                    objParam := { content  : "<@" data.DiscordUserId "> Shutting Down PC NOW!"
                        , username         : "Baya's Macro 🖱️⌨️"
                        , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    }
    
                    Webhook(data.DiscordWebhookURL, objParam) 
                }

                Shutdown 9
            }
            if data.LogMethod = "Close Game" {
                try {
                    objParam := { content  : "Returning to Desktop to Avoid Data Corrupting...`n(Process will take around 1 minute to finalize)"
                        , username         : "Baya's Macro 🖱️⌨️"
                        , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    }
            
                    Webhook(data.DiscordWebhookURL, objParam) 
                }

                ReturnToDesktop()

                Sleep 60000 ; sleeps for 60 seconds for elden ring to fully close

                if WinExist("ELDEN RING™") {
                    try {
                        objParam := { content  : "FAIL"
                            , username         : "Baya's Macro 🖱️⌨️"
                            , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                        }
        
                        Webhook(data.DiscordWebhookURL, objParam) 
                    }

                    WinClose
                } else {
                    try {
                        objParam := { content  : "SUCCESS"
                            , username         : "Baya's Macro 🖱️⌨️"
                            , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                        }
        
                        Webhook(data.DiscordWebhookURL, objParam) 
                    }
                }
            }
        }
    }
}

; hotkeys
;stops
SC01B:: ; #]
{
    ExitApp 
}

#HotIf WinActive("ELDEN RING™")
;play/pause
SC01A:: ;#[ 
{
    if status.Ready != 0 {
        static toggle := 0

        toggle := !toggle  

        if (toggle != 0) { ; # PLAY
            if data.AutoFarmMethod = "Albinaurics" {
                AutoAlbinaurics()
            } else if data.AutoFarmMethod = "Bird" {
                AutoBird()
            }
        } else if (toggle != 1) { ; # PAUSE
            Reload
        }
    
    }
}

