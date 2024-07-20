; #variables
_user_inputs := Object()
_indexes := Object()
_options := Object()

_options.AutoFarmMethods := ["Albinaurics", "Bird", "Skel-Band(Pilgrimage Church)"]
_options.LogMethods := ["Stop Macro", "Close Game", "Shutdown PC", "Do Nothing"]
_options.Decisions := ["Yes", "No"]

_ini := Object()

_ini.Version := GetVersion()
_ini.Name := "_baya's_macro_data_ER_" _ini.Version ".ini" 

_lowest_Interval := 5
_highest_Interval := 60

; -- Default Data
_ini.Discord_String := (
    "discord_UserId = '' `r`n"
    "discord_WebhookURL = '' `r`n"
    "discord_Track = '" _options.Decisions[1] "' `r`n"
    "discord_Intervals = '" _lowest_Interval "' `r`n"
)
_ini.Data_String := (
    "data_AutoFarm = '" _options.AutoFarmMethods[1] "' `r`n"
    "data_LogMethod = '" _options.LogMethods[1] "' `r`n"
)

; -- discord | default
_ini.DiscordUserId := quoted(StrReadLine(_ini.Discord_String, 1))
_ini.DiscordWebhookURL := quoted(StrReadLine(_ini.Discord_String, 2))
_ini.DiscordTrack := quoted(StrReadLine(_ini.Discord_String, 3))
_ini.DiscordIntervals := Integer(quoted(StrReadLine(_ini.Discord_String, 4)))

; -- data | default
_ini.DataAutoFarm := quoted(StrReadLine(_ini.Data_String, 1))
_ini.DataLogMethod := quoted(StrReadLine(_ini.Data_String, 2))

; -- get|check save file
if !(FileExist(".\" _ini.Name)) {
    Loop Files, ".\*.ini" {
        print("[GUI] Deleting Old Data Save")
        FileDelete A_LoopFileFullPath
    }

    print("[GUI] Writing New Data Save")

    IniWrite _ini.Discord_String, ".\" _ini.Name, "Discord"
    IniWrite _ini.Data_String, ".\" _ini.Name, "Data"

    FileSetAttrib "+H", ".\" _ini.Name
} else {
    print("[GUI] Found Data Save")

    discordString := IniRead(".\" _ini.Name, "Discord")
    dataString := IniRead(".\" _ini.Name, "Data")

    ; -- get index from array
    _indexes.DiscordTrack := GetArrayValueIndex(_options.Decisions, quoted(StrReadLine(discordString, 3)))

    _indexes.AutoFarmMethod := GetArrayValueIndex(_options.AutoFarmMethods, quoted(StrReadLine(dataString, 1)))
    _indexes.LogMethod := GetArrayValueIndex(_options.LogMethods, quoted(StrReadLine(dataString, 2)))

    ;-- check discord id and url
    _retrieved_Discord_Id := quoted(StrReadLine(discordString, 1))
    _retrieved_Discord_URL := quoted(StrReadLine(discordString, 2))

    ; remove spaces 
    _retrieved_Discord_Id := StrReplace(_retrieved_Discord_Id, A_Space)
    _retrieved_Discord_URL := StrReplace(_retrieved_Discord_URL, A_Space)

    ; checks if discord user id is numbers
    if !(IsInteger(_retrieved_Discord_Id)) {
        _retrieved_Discord_Id := ""
    }

    ; check if discord URL is valid
    if SubStr(_retrieved_Discord_URL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            _webhook_Request := ComObject("WinHttp.WinHttpRequest.5.1")
            _webhook_Request.Open("GET", _retrieved_Discord_URL, true)
        } catch as e {
            _retrieved_Discord_URL := ""
        }
    } else {
        _retrieved_Discord_URL := ""
    }

    ; -- get user inputted discord values
    _ini.DiscordUserId := _retrieved_Discord_Id
    _ini.DiscordWebhookURL := _retrieved_Discord_URL
    _ini.DiscordTrack := IsInteger(_indexes.DiscordTrack) and _options.Decisions[_indexes.DiscordTrack] or _ini.DiscordTrack
    _ini.DiscordIntervals := (IsInteger(quoted(StrReadLine(discordString, 4))) and WithinRange(Integer(quoted(StrReadLine(discordString, 4))), _lowest_Interval, _highest_Interval) == 1 and Integer(quoted(StrReadLine(discordString, 4)))) or _ini.DiscordIntervals 
   
    ; -- make sure the correct values are inputted from the array to avoid errors
    _ini.DataAutoFarm := IsInteger(_indexes.AutoFarmMethod) and _options.AutoFarmMethods[_indexes.AutoFarmMethod] or _ini.DataAutoFarm
    _ini.DataLogMethod := IsInteger(_indexes.LogMethod) and _options.LogMethods[_indexes.LogMethod] or _ini.DataLogMethod
}

; #functions
StartUserInput(*)
{
    _inputs := myGui.Submit()

    ; userinputted values
    _user_inputs.DiscordUserId := _inputs.DiscordUserId
    _user_inputs.DiscordURL := _inputs.DiscordWebhookURL
    _user_inputs.DiscordTrack := _inputs.DiscordTrack
    _user_inputs.DiscordInterval := _inputs.DiscordInterval

    _user_inputs.AutoFarmMethod := _inputs.AutoFarmMethod
    _user_inputs.LogMethod := _inputs.LogMethod

    ; remove spaces 
    _user_inputs.DiscordUserId := StrReplace(_user_inputs.DiscordUserId, A_Space)
    _user_inputs.DiscordURL := StrReplace(_user_inputs.DiscordURL, A_Space)

    ; checks if discord user id is numbers
    if !(IsInteger(_user_inputs.DiscordUserId)) {
        _user_inputs.DiscordUserId := ""
    }

    ; check if discord URL is valid
    if SubStr(_user_inputs.DiscordURL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            _webhook_Request := ComObject("WinHttp.WinHttpRequest.5.1")
            _webhook_Request.Open("GET", _user_inputs.DiscordURL, true)
        } catch as e {
            _user_inputs.DiscordURL := ""
        }
    } else {
        _user_inputs.DiscordURL := ""
    }

    _new_Discord_String := (
        "discord_UserId = '" _user_inputs.DiscordUserId "' `r`n"
        "discord_WebhookURL = '" _user_inputs.DiscordURL "' `r`n"
        "discord_Track = '" _user_inputs.DiscordTrack "' `r`n"
        "discord_Intervals = '" _user_inputs.DiscordInterval "' `r`n"
    )
    _new_Data_String := (
        "data_AutoFarm = '" _user_inputs.AutoFarmMethod "' `r`n"
        "data_LogMethod = '" _user_inputs.LogMethod "' `r`n"
    )

    print("[GUI] Rewriting Data Save")

    IniWrite _new_Discord_String, ".\" _ini.Name, "Discord"
    IniWrite _new_Data_String, ".\" _ini.Name, "Data"

    FileSetAttrib "+H", ".\" _ini.Name

    ; #update values
    _ini.DiscordUserId := _user_inputs.DiscordUserId
    _ini.DiscordWebhookURL := _user_inputs.DiscordURL
    _ini.DiscordTrack := _user_inputs.DiscordTrack
    _ini.DiscordIntervals := Integer(_user_inputs.DiscordInterval)
   
    _ini.DataAutoFarm := _user_inputs.AutoFarmMethod
    _ini.DataLogMethod := _user_inputs.LogMethod

    status.Ready := 1
}

TestUserPing(*) {
    _inputs := myGui.Submit(0) ; 0 ensures the window doesn't close

    _discord_User_Id := StrReplace(_inputs.DiscordUserId, A_Space)
    _discord_URL := StrReplace(_inputs.DiscordWebhookURL, A_Space)

    ; check if valid discord url
    if SubStr(_inputs.DiscordWebhookURL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            _params := { content: "Test Ping? <@" _discord_User_Id ">"
                , username      : "Baya's Macro 🖱️⌨️"
                , avatar_url    : "https://i.imgur.com/rTHyKfI.png"
            }

            Webhook(_discord_URL, _params)
        } catch as e {
            print("[TestUserPing] Error!")
        } else {
            print("[TestUserPing] Sent!")
        }
    } else {
        print("[TestUserPing] Invalid Webhook URL!")
    }
}

GuiClose(*) {
    ExitApp
}

; #create-gui
myGui := Gui(, "Baya's Macro: Elden Ring Edition")
myGui.Opt("+AlwaysOnTop")
myGui.SetFont(, "Verdana")

myGui.AddGroupBox("Center xm5 ym+10 Section w200 h150", "Auto-Farm")
myGui.Add("Text","Center xs+10 ys+20 w180", "Which Auto Farming Method?")
myGui.AddDropDownList("Center w180 vAutoFarmMethod Choose" _indexes.AutoFarmMethod, _options.AutoFarmMethods)

myGui.Add("Text","Center w180", "Auto Log?")
myGui.AddDropDownList("Center w180 vLogMethod Choose" _indexes.LogMethod, _options.LogMethods)

myGui.AddButton("Center xs+0", "Save Settings").OnEvent("Click", StartUserInput)

myGui.AddGroupBox("Center xm+210 ym+10 Section w260 h175", "Discord Settings")
myGui.Add("Text","Center xs+10 ys+20 w240", "UserId")
myGui.AddEdit("Center w240 vDiscordUserId r1", _ini.DiscordUserId)
myGui.Add("Text","Center w240", "Webhook URL")
myGui.AddEdit("Center w240 vDiscordWebhookURL r1", _ini.DiscordWebhookURL)
myGui.Add("Text","Center w120", "Track Runes?")
myGui.AddDropDownList("Center w120 vDiscordTrack Choose" _indexes.DiscordTrack, _options.Decisions)
myGui.Add("Text","Center xs+133 ys+111 w120", "Intervals (mins)")
myGui.AddEdit("Center w120")
myGui.AddUpDown("vDiscordInterval Range5-60", _ini.DiscordIntervals)

myGui.AddButton("Center xs+90 ys+160 w75 h20", "Test Ping").OnEvent("Click", TestUserPing)

myGui.OnEvent("Close", GuiClose)

myGui.Show