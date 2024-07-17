;==================================================================================================================;
;========================================    made by fiziaque     =================================================;
;==================================================================================================================;

; #pre-set
#Requires AutoHotkey v2.0 
#SingleInstance Force
#MaxThreadsPerHotkey 2

Persistent
OnExit ExitFunc

; #includes
#Include modules\Webhook.ahk
#Include modules\FileReadLine.ahk
#Include modules\CaptureScreen.ahk

CoordMode "Pixel", "Window"
CoordMode "Mouse", "Window"

; #File install
if !(FileExist(A_Temp "\baya_macro_disconnected.png")) {
    FileInstall "images\baya_macro_disconnected.png", A_Temp "\baya_macro_disconnected.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_loading.png")) {
    FileInstall "images\baya_macro_loading.png", A_Temp "\baya_macro_loading.png", 1
} 
; equipment
if !(FileExist(A_Temp "\baya_macro_treadmill_auto_train.png")) {
    FileInstall "images\baya_macro_treadmill_auto_train.png", A_Temp "\baya_macro_treadmill_auto_train.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_later.png")) {
    FileInstall "images\baya_macro_later.png", A_Temp "\baya_macro_later.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_cross.png")) {
    FileInstall "images\baya_macro_cross.png", A_Temp "\baya_macro_cross.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_auto_load.png")) {
    FileInstall "images\baya_macro_auto_load.png", A_Temp "\baya_macro_auto_load.png", 1
} 
;gym_league icon
if !(FileExist(A_Temp "\gym_league_icon.ico")) {
    FileInstall "..\icons\gym_league_icon.ico", A_Temp "\gym_league_icon.ico", 1
} 
;stats
if !(FileExist(A_Temp "\baya_macro_abs.png")) {
    FileInstall "images\baya_macro_abs.png", A_Temp "\baya_macro_abs.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_back.png")) {
    FileInstall "images\baya_macro_back.png", A_Temp "\baya_macro_back.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_biceps.png")) {
    FileInstall "images\baya_macro_biceps.png", A_Temp "\baya_macro_biceps.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_calves.png")) {
    FileInstall "images\baya_macro_calves.png", A_Temp "\baya_macro_calves.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_chest.png")) {
    FileInstall "images\baya_macro_chest.png", A_Temp "\baya_macro_chest.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_forearm.png")) {
    FileInstall "images\baya_macro_forearm.png", A_Temp "\baya_macro_forearm.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_legs.png")) {
    FileInstall "images\baya_macro_legs.png", A_Temp "\baya_macro_legs.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_shoulder.png")) {
    FileInstall "images\baya_macro_shoulder.png", A_Temp "\baya_macro_shoulder.png", 1
} 
if !(FileExist(A_Temp "\baya_macro_triceps.png")) {
    FileInstall "images\baya_macro_triceps.png", A_Temp "\baya_macro_triceps.png", 1
} 
;words


; #objects
data := Object()
directories := Object()
images := Object()
status := Object()
machine := Object()

; #pre-variables
directories.Images := "images\"

status.Ready := 0
status.RegeneratingStamina := 0
status.Strikes := 0
status.ActiveMachine := "None"
status.StartTime := A_TickCount
status.UpdateTime := A_TickCount
status.BodyAlterTime := A_TickCount
status.StartMonitoring := 0
status.UpdateRepeated := 0
status.TreadmillOn := 0
status.ScreenCapturing := 0
status.MaxFindingStatTries := 9
status.GotTracked := 0
status.BodyAlterInterval := 900000 ; 15 mins

data.AutoLoad := "Yes"
data.WaitForFullStamina := "Yes"
data.StaminaDetection := "Newbie"
data.AutomaticCompetition := "No"
data.AutoMachine := "Random"
data.DiscordUserId := ""
data.DiscordWebhookURL := ""
data.DiscordUpdate := 5
data.DiscordTrack := "Calves"
data.LogMethod := "Do Nothing"

machine.Amount := 0

machinesRaw := "Random|Wrist Curl|Triceps Curl|Crunch|Chest Press|Pushups|Treadmill|Abs|Dead Lift|Leg Press|Front Squat|Lat Pulldown|Barfix|Hammer Curl|Push Press|Bench Press"
machines := StrSplit(machinesRaw, "|")

; #post-variables
;arrays
imageFilePaths := []

machineArray := []
trackArray := ["Calves", "Legs", "Back", "Biceps", "Chest", "Shoulders", "Triceps", "Abs", "Forearm"]
optionArray := ["Yes", "No"]
detectionArray := ["Newbie", "Advanced"]
competitionArray := ["No", "Gym 5"]
logArray := ["Do Nothing", "Close Roblox", "Shutdown PC"]

for _, name in machines {
    machineArray.Push(name)
    machine.Amount += 1
}

for _, stat in trackArray {
    imageFilePaths.Push(A_Temp "\." stat ".png" or directories.Images "." stat ".png")
}

images.Disconnected := A_Temp "\baya_macro_disconnected.png" or directories.Images "baya_macro_disconnected.png"
images.Loading := A_Temp "\baya_macro_loading.png" or directories.Images "baya_macro_loading.png"
images.TreadmillAutoTrain := A_Temp "\baya_macro_treadmill_auto_train.png" or directories.Images "baya_macro_treadmill_auto_train.png"
images.RateLater := A_Temp "\baya_macro_later.png" or directories.Images "baya_macro_later.png"
images.CrossPopups := A_Temp "\baya_macro_cross.png" or directories.Images "baya_macro_cross.png"
images.WeightAutoLoad := A_Temp "\baya_macro_auto_load.png" or directories.Images "baya_macro_auto_load.png"
images.Icon := A_Temp "\gym_league_icon.ico" or directories.Images "gym_league_icon.ico"
imagesabs := A_Temp "\baya_macro_abs.png" or directories.Images "baya_macro_abs.png"
imagesback := A_Temp "\baya_macro_back.png" or directories.Images "baya_macro_back.png"
imagesbiceps := A_Temp "\baya_macro_biceps.png" or directories.Images "baya_macro_biceps.png"
imagescalves := A_Temp "\baya_macro_calves.png" or directories.Images "baya_macro_calves.png"
imageschest := A_Temp "\baya_macro_chest.png" or directories.Images "baya_macro_chest.png"
imagesforearm := A_Temp "\baya_macro_forearm.png" or directories.Images "baya_macro_forearm.png"
imageslegs := A_Temp "\baya_macro_legs.png" or directories.Images "baya_macro_legs.png"
imagesshoulder := A_Temp "\baya_macro_shoulder.png" or directories.Images "baya_macro_shoulder.png"
imagestriceps := A_Temp "\baya_macro_triceps.png" or directories.Images "baya_macro_triceps.png"

weightAutoLoadTime := 60000 ; -- 60 seconds
maxRetryCounter := 50

; #post-set
TraySetIcon(images.Icon) 

; #get-data
if (FileExist(A_WorkingDir "\Baya's Macro Settings.ini")) {
    settingsString := IniRead(A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName)

    settings := StrSplit(settingsString, "|")  

    data.AutoLoad := settings[1]
    data.WaitForFullStamina := settings[2]
    data.StaminaDetection := settings[3]
    data.AutomaticCompetition := settings[4]
    data.AutoMachine := settings[5]
    data.DiscordUserId := settings[6]
    data.DiscordWebhookURL := settings[7]
    data.DiscordUpdate := settings[8]
    data.DiscordTrack := settings[9]
    data.LogMethod := settings[10]
} 

; #create-gui
myGui := Gui(, "Baya's Macro: Gym League Edition")
myGui.Opt("+AlwaysOnTop")

myGui.AddGroupBox("Center xm5 ym+10 Section w140 h200", "Machines")
myGui.Add("Text","Center xs+10 ys+20 w120", "Allow Weights to Auto Load?")
myGui.AddDropDownList("Center w120 vAutoLoad Choose" GetArrayValueIndex(optionArray, data.AutoLoad), optionArray)
myGui.Add("Text","Center w120", "Wait for Full Stamina?")
myGui.AddDropDownList("Center w120 vWaitForFullStamina Choose" GetArrayValueIndex(optionArray, data.WaitForFullStamina), optionArray)
myGui.Add("Text","Center w120", "Which Stamina Detection Type would you like?")
myGui.AddDropDownList("Center w120 vStaminaDetection Choose" GetArrayValueIndex(detectionArray, data.StaminaDetection), detectionArray)

myGui.AddGroupBox("Center xm+160 ym+10 Section w140 h150", "Auto-Competition Farm")
myGui.Add("Text","Center xs+10 ys+20 w120", "Allow Automatic Competition?")
myGui.AddDropDownList("Center w120 vAutomaticCompetition Choose" GetArrayValueIndex(competitionArray, data.AutomaticCompetition), competitionArray)
myGui.Add("Text","Center w120", "Allow Auto-Walk to Machine? (Only works After Competition)")
myGui.AddDropDownList("Center w120 vAutoMachine Choose" GetArrayValueIndex(machineArray, data.AutoMachine), machineArray)

myGui.AddGroupBox("Center xm+160 ym+160 Section w140 h50", "Auto Log")
myGui.AddDropDownList("Center xs+10 ys+20 w120 vLogMethod Choose" GetArrayValueIndex(logArray, data.LogMethod), logArray)

myGui.AddGroupBox("Center xm+310 ym+10 Section w200 h200", "Discord Settings")
myGui.Add("Text","Center xs+10 ys+20 w180", "        User Id        |   Webhook URL")
myGui.AddEdit("Center w90 vDiscordUserId r1", data.DiscordUserId)
myGui.AddEdit("Center xs+100 ys+39 w180 w90 vDiscordWebhookURL r1", data.DiscordWebhookURL)
myGui.AddButton("Center xs+50 ys+62 w100 h35", "Test Ping").OnEvent("Click", TestUserPing)

myGui.Add("Text","Center xs+10 ys+100 w180", "Auto Update (in mins)")
myGui.AddEdit("Center w180")
myGui.AddUpDown("vDiscordUpdate Range5-60", data.DiscordUpdate)

myGui.Add("Text","Center w180", "Track Stat")
myGui.AddDropDownList("Center w180 vDiscordTrack Choose" GetArrayValueIndex(trackArray, data.DiscordTrack), trackArray)

myGui.AddButton("Center xs+50", "Save Settings").OnEvent("Click", StartUserInput)

myGui.Show

; #functions
ExitFunc(ExitReason, ExitCode) {
    for name, file in images.OwnProps() {
        if InStr(file, "\AppData\Local\Temp\") and (name "*png" or name "*ico") {
            FileDelete file
        }
    }
}
    
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

    settingsString := inputs.AutoLoad "|" inputs.WaitForFullStamina "|" inputs.StaminaDetection "|" inputs.AutomaticCompetition "|" inputs.AutoMachine "|" inputs.DiscordUserId "|" inputs.DiscordWebhookURL "|" inputs.DiscordUpdate "|" inputs.DiscordTrack "|" inputs.LogMethod

    IniWrite settingsString, A_WorkingDir "\Baya's Macro Settings.ini", "Settings", A_ComputerName

    settings := StrSplit(settingsString, "|")  

    data.AutoLoad := settings[1]
    data.WaitForFullStamina := settings[2]
    data.StaminaDetection := settings[3]
    data.AutomaticCompetition := settings[4]
    data.AutoMachine := settings[5]
    data.DiscordUserId := settings[6]
    data.DiscordWebhookURL := settings[7]
    data.DiscordUpdate := settings[8]
    data.DiscordTrack := settings[9]
    data.LogMethod := settings[10]

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
;miscs
GetArrayValueIndex(arr, val) {
	Loop arr.Length {
		if (InStr(arr[A_Index], val))
			return A_Index
	}
}
Jump() {
    Send("{Blind}{Space Down}")
    Sleep 20
    Send("{Blind}{Space Up}")
}

MovingMouse(x, y, type, amount) {
    MouseGetPos &xpos, &ypos 

    SendMode 'Event'
    MouseMove x - xpos, y - ypos, 2, "R"
    MouseClick type, x, y, amount
}
Rand(x, y) {
    var := Random(x, y)
    return var
}
CameraTurn(direction) {
    if direction = "Right" {
        Send("{Blind}{Right Down}")
        Sleep 750
        Send("{Blind}{Right Up}")
    } else if direction = "Left" {
        Send("{Blind}{Left Down}")
        Sleep 750
        Send("{Blind}{Left Up}")
    } else if direction = "Up" {
        Send "{LShift}"
        Sleep 500
        MouseMove(0, -1000, 0, "R")
        Sleep 500
        Send "{LShift}"
    } else if direction = "Down" {
        Send "{LShift}"
        Sleep 250
        MouseMove(0, 1000, 0, "R")
        Sleep 250
        Send "{LShift}"
    }
}
ClosePopups() {
    if ImageSearch(&FoundX, &FoundY, 0, 0, 800, 599, "*30 " images.RateLater) {
        MovingMouse(FoundX, FoundY, "left", 2)
    } ; this closes rate game thing

    if ImageSearch(&FoundX, &FoundY, 0, 0, 800, 599, "*TransAD1D29 *30 " images.CrossPopups) {
        MovingMouse(FoundX, FoundY, "left", 2)
    } ; this closes popups
}
; #Discord
ScreenCaptureStats() {
    if status.ScreenCapturing != 1 {
        status.ScreenCapturing := 1
        status.GotTracked := 0

        try {
            OpenStats()
            
            Sleep 250

            CheckBodyAlter()

            statPosition := GetArrayValueIndex(imageFilePaths, data.DiscordTrack)
            tried := 0
        
            while !(ImageSearch(&FoundX, &FoundY, 274, 410, 370, 425, "*TransWhite *30 " imageFilePaths[statPosition])) and tried < status.MaxFindingStatTries {
                CheckDisconnected()
                MovingMouse(380, 419, "left", 1)
                tried += 1
            }
        
            if ImageSearch(&FoundX, &FoundY, 274, 410, 370, 425, "*TransWhite *30 " imageFilePaths[statPosition]) {
                status.GotTracked := 1
        
                outfile := A_Temp "\baya_macro_stats.png"
                CaptureScreen( "400, 265, 566, 335", 0, outfile)
            
                Sleep 500
            } else { ; if tracked image stat not found
                outfile := A_Temp "\baya_macro_stats.png"
                CaptureScreen( "240, 225, 575, 435", 0, outfile)
            
                Sleep 500
            }
            
            CloseStats()
        }
        catch as e  {
            status.ScreenCapturing := 0

            ScreenCaptureStats()
        } else {
            status.ScreenCapturing := 0
        }
    }
}

UpdateStatsToDiscord() {
    if data.DiscordWebhookURL != "" {
        if status.StartMonitoring != 1 {
            status.StartMonitoring := 1 ; Monitor Started

            MovingMouse(27, 600, "left", 0)
            Send "{WheelUp 5}"
            CameraTurn("Up")
    
            ; ss
            ScreenCaptureStats()

            MovingMouse(27, 600, "left", 0)
            Send "{WheelDown 1}"
            CameraTurn("Down")
            
            try {
                TimeString := FormatTime(, "dddd MMMM d, yyyy hh:mm:ss tt")

                contentText := "**Monitoring Started**`n➼  *Total Repeat:* __indefinite__`n➼  *Interval:* __every " data.DiscordUpdate " minutes__`n➼  *Tracked Stat:* __" data.DiscordTrack "__`n➼  *Tracked Time:* __" TimeString "__"

                if status.GotTracked != 1 { ; if not tracked or coudn't find
                    contentText := "**Monitoring Started**`n➼  *Total Repeat:* __indefinite__`n➼  *Interval:* __every " data.DiscordUpdate " minutes__`n➼  *Tracked Stat:* __Error Retrieving Tracked Image__`n➼  *Tracked Time:* __" TimeString "__" 
                }

                objParam := { content  : contentText
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    , file             : [A_Temp "\baya_macro_stats.png"]
                }
        
                Webhook(data.DiscordWebhookURL, objParam)
            }
             
            
            if FileExist(A_Temp "\baya_macro_stats.png") {
                FileDelete A_Temp "\baya_macro_stats.png"
            }
        } else if A_TickCount - status.UpdateTime >= (data.DiscordUpdate * 60000) {
            status.UpdateTime := A_TickCount
            status.UpdateRepeated += 1
        
            ; ss
            ScreenCaptureStats()
    
            try {
                TimeString := FormatTime(, "dddd MMMM d, yyyy hh:mm:ss tt")

                contentText := "**Interval Report**`n➼  *Repeated:* __" status.UpdateRepeated "__`n➼  *Interval:* __every " data.DiscordUpdate " minutes__`n➼  *Tracked Stat:* __" data.DiscordTrack "__`n➼  *Tracked Time:* __" TimeString "__"

                if status.GotTracked != 1 { ; if not tracked or coudn't find
                    contentText := "**Interval Report**`n➼  *Repeated:* __" status.UpdateRepeated "__`n➼  *Interval:* __every " data.DiscordUpdate " minutes__`n➼  *Tracked Stat:* __Error Retrieving Tracked Image__`n➼  *Tracked Time:* __" TimeString "__"
                }

                objParam := { content  : contentText
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    , file             : [A_Temp "\baya_macro_stats.png"]
                }
                        
                Webhook(data.DiscordWebhookURL, objParam) 
            }
                 
            if FileExist(A_Temp "\baya_macro_stats.png") {
                FileDelete A_Temp "\baya_macro_stats.png"
            }            
        }
    }
}
;mains
MainCheck() {
    if WinExist("Roblox") {
        WinActivate
        WinWaitActive

        WinMove 0,0,800,599 ; Moves window to top left
    } else {
        MsgBox "Roblox.exe not running!"
        return
    }

    if data.DiscordWebhookURL = "" and A_TickCount - status.CheckBodyAlter >= (status.BodyAlterInterval) {
        status.CheckBodyAlter := A_TickCount

        OpenStats()
        CheckBodyAlter()
        CloseStats()
    }

    ClosePopups()

    isAvailable := CheckCompetition()
    if isAvailable != 0 {
        JoinCompetition()
    } else if PixelSearch(&_, &_, 189, 542, 190, 543, 0x050505, 1) {
        Compete()
    } else{
        checkMachine := MachineCheck()

        if (checkMachine = "Off") {
            Send("{Blind}{e Down}")
            Sleep 2000
            Send("{Blind}{e Up}")

            if status.RegeneratingStamina != 1 {
                status.ActiveMachine := "None"

                if data.AutomaticCompetition != "No" {
                    status.Strikes += 1
                    CheckStrikes()
                }

                MainCheck()
            }

        } else if (checkMachine = "Weights") and status.ActiveMachine != "Weights" and status.RegeneratingStamina != 1 {
            status.Strikes := 0
            status.ActiveMachine := "Weights"
            
            UpdateStatsToDiscord()

            LoopWeights()
        } else if (checkMachine = "Treadmill") and status.ActiveMachine != "Treadmill" and status.RegeneratingStamina != 1 {
            status.Strikes := 0
            status.ActiveMachine := "Treadmill"

            UpdateStatsToDiscord()
            
            LoopTreadmill()
        }    
    }
}

MachineCheck() {
    if ImageSearch(&_, &_, 715, 395, 777, 410, "*50 " images.TreadmillAutoTrain) {
        return "Treadmill"      
    } 
    else if ImageSearch(&_, &_, 616, 319, 725, 405, "*50 " images.WeightAutoLoad) {
        return "Weights"
    }
    else {
        return "Off"
    }
}

CheckStrikes() {
    if data.LogMethod != "Do Nothing" and status.Strikes >= maxRetryCounter { ; exceeds 50 tries
        if data.LogMethod = "Close Roblox" {
            if WinExist("Roblox") {
                WinClose 
                WinClose
                WinClose

                try {
                    objParam := { content  : "<@" data.DiscordUserId "> 50+ Strikes Recieved. Closing Roblox!"
                        , username         : "Baya's Macro 🖱️⌨️"
                        , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                    }
                        
                    Webhook(data.DiscordWebhookURL, objParam)
                }

                ExitApp
            }
        }
        
        if data.LogMethod = "Shutdown PC" {

            try {
                objParam := { content  : "<@" data.DiscordUserId "> 50+ Strikes Recieved. Shutting Down!"
                    , username         : "Baya's Macro 🖱️⌨️"
                    , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
                }

                Webhook(data.DiscordWebhookURL, objParam) 
            }
                
            Shutdown 9
        }
    }
}
OpenStats() {
    if !PixelSearch(&_, &_, 245, 227, 272, 250, 0xFCF238, 3) {
        MovingMouse(34, 311, "left", 1)
    }
}
CloseStats() {
    if PixelSearch(&_, &_, 245, 227, 272, 250, 0xFCF238, 3) {
        MovingMouse(34, 311, "left", 1)
    }
}

CheckBodyAlter() {
    if PixelSearch(&_, &_, 403, 264, 564, 286, 0x2B6D00, 3) {
        MovingMouse(487, 274, "left", 3)
    }
}

CheckDisconnected() {
    if ImageSearch(&_, &_, 0, 0, 800, 599, "*50 " images.Disconnected) {
        status.Strikes += 50

        try {
            objParam := { content  : "<@" data.DiscordUserId "> You've Been Disconnected, Adding 50 Strikes!"
                , username         : "Baya's Macro 🖱️⌨️"
                , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
            }

            Webhook(data.DiscordWebhookURL, objParam) 
        }     
        
        CheckStrikes()
    }

    if ImageSearch(&_, &_, 340, 550, 475, 576, "*50 " images.Loading) {
        status.Strikes += 50

        try {
            objParam := { content  : "<@" data.DiscordUserId "> Game Rejoined/Updated, Adding 50 Strikes!"
                , username         : "Baya's Macro 🖱️⌨️"
                , avatar_url       : "https://i.imgur.com/rTHyKfI.png"
            }

            Webhook(data.DiscordWebhookURL, objParam) 
        } 

        CheckStrikes()
    }
}

CheckCompetition() {
    if data.AutomaticCompetition != "No" and PixelSearch(&_, &_, 396, 400, 473, 413, 0xA3FF63, 3) {
        return 1
    }

    return 0
}

; wait
WaitToAttend() {
    while PixelSearch(&_, &_, 396, 400, 473, 413, 0xA3FF63, 3) {
        CheckDisconnected()
        Jump()
        MovingMouse(440, 407, "left", 1)
    }
}

WaitForStage() {
    color := PixelGetColor(189, 542)

    while !(color = 0x050505) {
        CheckDisconnected()
        color := PixelGetColor(189, 542)
    }
}

; comp
Compete() {
    while PixelSearch(&_, &_, 189, 542, 190, 543, 0x050505, 1) {
        CheckDisconnected()
        if PixelSearch(&ContinueX, &ContinueY, 459, 450, 460, 451, 0x3A7916, 50) {
            MovingMouse(ContinueX - 30, ContinueY - 30, "left", 1)
        } else {
            Send "{Space}"
        }
    }

    WalkToMachineFromCompetition()
}

JoinCompetition() {
    status.RegeneratingStamina := 0

    WaitToAttend()

    status.ActiveMachine := "None"

    WaitForStage()

    Compete()
}

WalkToMachineFromCompetition() {
    chosenMachine := data.AutoMachine
    chosenGym := data.AutomaticCompetition

    if chosenMachine = "Random" {
        rng := Rand(2, machine.Amount) ; 
        chosenMachine := machines[rng]
    }

    if chosenGym = "Gym 5" {
        if chosenMachine = "Barfix" {
            Send("{Blind}{s Down}")
            Sleep 5750
            Send("{Blind}{s Up}")
        
            Send("{Blind}{a Down}")
            Sleep 1000
            Send("{Blind}{a Up}")
        
            CameraTurn("Left")

        } else if chosenMachine = "Hammer Curl" {
            Send("{Blind}{s Down}")
            Sleep 2750
            Send("{Blind}{s Up}")
    
            Send("{Blind}{a Down}")
            Sleep 1000
            Send("{Blind}{a Up}")

            CameraTurn("Left")

        } else if chosenMachine = "Push Press" {
            Send("{Blind}{s Down}")
            Sleep 3000
            Send("{Blind}{s Up}")
    
            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Bench Press" {
            Send("{Blind}{s Down}")
            Sleep 2000
            Send("{Blind}{s Up}")
    
            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Lat Pulldown" {
            Send("{Blind}{s Down}")
            Sleep 3850
            Send("{Blind}{s Up}")

            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 
            
        } else if chosenMachine = "Front Squat" {
            Send("{Blind}{s Down}")
            Sleep 4850
            Send("{Blind}{s Up}")

            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Leg Press" {
            Send("{Blind}{s Down}")
            Sleep 5750
            Send("{Blind}{s Up}")

            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Dead Lift" {
            Send("{Blind}{s Down}")
            Sleep 6600
            Send("{Blind}{s Up}")

            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Abs" {
            Send("{Blind}{s Down}")
            Sleep 7300
            Send("{Blind}{s Up}")

            Send("{Blind}{d Down}")
            Sleep 1250
            Send("{Blind}{d Up}")

            CameraTurn("Right")

        } else if chosenMachine = "Treadmill" {
            Send("{Blind}{s Down}")
            Sleep 7750
            Send("{Blind}{s Up}")

            CameraTurn("Right") 
            CameraTurn("Right")

        } else if chosenMachine = "Pushups" {
            Send("{Blind}{s Down}")
            Sleep 7300
            Send("{Blind}{s Up}")

            Send("{Blind}{a Down}")
            Sleep 2000
            Send("{Blind}{a Up}")

            CameraTurn("Right") 
            CameraTurn("Right")

        } else if chosenMachine = "Chest Press" {
            Send("{Blind}{s Down}")
            Sleep 7300
            Send("{Blind}{s Up}")

            Send("{Blind}{a Down}")
            Sleep 2950
            Send("{Blind}{a Up}")

            CameraTurn("Right") 
            CameraTurn("Right")

        } else if chosenMachine = "Crunch" {
            Send("{Blind}{a Down}")
            Sleep 2100
            Send("{Blind}{a Up}")

            Send("{Blind}{s Down}")
            Sleep 5750
            Send("{Blind}{s Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Triceps Curl" {
            Send("{Blind}{a Down}")
            Sleep 2100
            Send("{Blind}{a Up}")

            Send("{Blind}{s Down}")
            Sleep 2900
            Send("{Blind}{s Up}")

            CameraTurn("Right") 

        } else if chosenMachine = "Wrist Curl" {
            Send("{Blind}{a Down}")
            Sleep 3750
            Send("{Blind}{a Up}")

            Send("{Blind}{s Down}")
            Sleep 900
            Send("{Blind}{s Up}")

            CameraTurn("Left")
        }
    }

    MainCheck()
}

;LOOPS
LoopStamina() {
    status.RegeneratingStamina := 1

    while data.WaitForFullStamina = "Yes" and (!(PixelSearch(&_, &_, 624, 537, 625, 550, 0x0076C0, 30)) or !(PixelSearch(&_, &_, 449, 537, 450, 550, 0x0076C0, 30))) {
        CheckDisconnected()

        if data.DiscordWebhookURL = "" and A_TickCount - status.CheckBodyAlter >= (status.BodyAlterInterval) {
            status.CheckBodyAlter := A_TickCount

            OpenStats()
            CheckBodyAlter()
            CloseStats()
        }
        
        UpdateStatsToDiscord()
        
        if !(PixelSearch(&_, &_, 226, 537, 228, 550, 0x0076C0, 30)) {
            Jump()
        }

        MainCheck()
    }

    status.RegeneratingStamina := 0
}

LoopWeights() {
    while status.ActiveMachine = "Weights" {
        CheckDisconnected()

        if data.DiscordWebhookURL = "" and A_TickCount - status.CheckBodyAlter >= (status.BodyAlterInterval) {
            status.CheckBodyAlter := A_TickCount
            
            OpenStats()
            CheckBodyAlter()
            CloseStats()
        }

        UpdateStatsToDiscord()

        isAvailable := CheckCompetition()
        if isAvailable != 0 {
            JoinCompetition()
            return
        }

        ClosePopups()

        if status.RegeneratingStamina != 1 and ((data.StaminaDetection = "Newbie" and !PixelSearch(&_, &_, 350, 537, 450, 550, 0x0076C0, 30)) or !PixelSearch(&_, &_, 250, 537, 332, 550, 0x0076C0, 30)) {   

            LoopStamina()
    
        } else if (status.RegeneratingStamina != 1) {
    
            MovingMouse(600, 375, "left", 1)
    
            if (data.AutoLoad = "Yes") and A_TickCount - status.StartTime >= weightAutoLoadTime and ImageSearch(&FoundX, &FoundY, 616, 319, 725, 405, "*50 " images.WeightAutoLoad) {
                status.StartTime := A_TickCount ; updates timer 
    
                MovingMouse(FoundX, FoundY, "left", 2)
            }
        }
    }
}

LoopTreadmill() {
    while status.ActiveMachine = "Treadmill" {
        CheckDisconnected()

        if data.DiscordWebhookURL = "" and A_TickCount - status.CheckBodyAlter >= (status.BodyAlterInterval) {
            status.CheckBodyAlter := A_TickCount
            
            OpenStats()
            CheckBodyAlter()
            CloseStats()
        }

        UpdateStatsToDiscord()
        
        isAvailable := CheckCompetition()
        if isAvailable != 0 {
            JoinCompetition()
            return
        }

        ClosePopups()

        if status.RegeneratingStamina != 1 and ((data.StaminaDetection = "Newbie" and !PixelSearch(&_, &_, 450, 537, 350, 550, 0x0076C0, 30)) or !PixelSearch(&_, &_, 332, 537, 250, 550, 0x0076C0, 30)) {   

            status.TreadmillOn := 0

            MovingMouse(725, 340, "left", 4)

            LoopStamina()
    
        } else if (status.RegeneratingStamina != 1) {
    
            MovingMouse(600, 375, "left", 1)
    
            if (status.TreadmillOn != 1) {
                status.TreadmillOn := 1

                MovingMouse(775, 340, "left", 4)
            } else {
                MovingMouse(600, 375, "left", 1)
            }
        }
    }
}

; #hotkeys 264, 375, 350, 398
;
^t:: {
    MouseClickDrag("Right", 27, 600, 27, -600, 50)
}
;stops
SC01B:: ; #]
m:: ;#m
{
    ExitApp 
}

;play/pause
SC01A:: ;#[ 
l:: ;#l
{
    if status.Ready != 0 {

        static toggle := 0

        toggle := !toggle  

        if (toggle != 0) { ; # PLAY
            MainCheck()
        } else if (toggle != 1) { ; # PAUSE
            Reload
        }
    
    }
}