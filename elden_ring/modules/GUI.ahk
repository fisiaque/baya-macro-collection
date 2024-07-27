; #variables
_gui := Object()

_user_inputs := Object()
_indexes := Object()
_options := Object()

_options.AutoFarmMethods := ["Albinaurics", "Bird", "Skel-Band(Pilgrimage Church)"]
_options.LogMethods := ["Stop Macro", "Close Game", "Shutdown PC", "Do Nothing"]
_options.Decisions := ["Yes", "No"]

_ini := Object()

_ini.Version := GetVersion()
_ini.Name := GetIniName() 

_lowest_Interval := 5
_highest_Interval := 60

; -- indexes | default
_indexes.DataTrack := 1

_indexes.AutoFarmMethod := 1
_indexes.LogMethod := 1

; -- Default Data
_ini.Discord_String := (
    "discord_UserId = '' `r`n"
    "discord_RoleId = '' `r`n"
    "discord_WebhookURL = '' `r`n"
    
)
_ini.Data_String := (
    "data_AutoFarm = '" _options.AutoFarmMethods[_indexes.AutoFarmMethod] "' `r`n"
    "data_LogMethod = '" _options.LogMethods[_indexes.LogMethod] "' `r`n"
    "data_Track = '" _options.Decisions[_indexes.DataTrack] "' `r`n"
    "data_Interval = '" _lowest_Interval "' `r`n"
)

; -- discord | default
_ini.DiscordUserId := quoted(StrReadLine(_ini.Discord_String, 1))
_ini.DiscordRoleId := quoted(StrReadLine(_ini.Discord_String, 2))
_ini.DiscordWebhookURL := quoted(StrReadLine(_ini.Discord_String, 3))

; -- data | default
_ini.DataAutoFarm := quoted(StrReadLine(_ini.Data_String, 1))
_ini.DataLogMethod := quoted(StrReadLine(_ini.Data_String, 2))
_ini.DataTrack := quoted(StrReadLine(_ini.Data_String, 3))
_ini.DataInterval := Integer(quoted(StrReadLine(_ini.Data_String, 4)))

; -- variables
_gui.Ready := 0

; -- get|check save file
if !(FileExist(".\" _ini.Name)) {
    Loop Files, ".\*.ini" {
        print("[GUI(" Format_Msec(A_TickCount - _status._start_script) ")] Deleting Old Data Save")
        FileDelete A_LoopFileFullPath
    }

    print("[GUI(" Format_Msec(A_TickCount - _status._start_script) ")] Writing New Data Save")

    IniWrite _ini.Discord_String, ".\" _ini.Name, "Discord"
    IniWrite _ini.Data_String, ".\" _ini.Name, "Data"

    FileSetAttrib "+H", ".\" _ini.Name
} else {
    print("[GUI(" Format_Msec(A_TickCount - _status._start_script) ")] Found Data Save")

    discordString := IniRead(".\" _ini.Name, "Discord")
    dataString := IniRead(".\" _ini.Name, "Data")

    ; -- get index from array
    _indexes.AutoFarmMethod := GetArrayValueIndex(_options.AutoFarmMethods, quoted(StrReadLine(dataString, 1)))
    _indexes.LogMethod := GetArrayValueIndex(_options.LogMethods, quoted(StrReadLine(dataString, 2)))
    _indexes.DataTrack := GetArrayValueIndex(_options.Decisions, quoted(StrReadLine(dataString, 3)))

    ;-- check discord id and url
    _retrieved_Discord_User_Id := quoted(StrReadLine(discordString, 1))
    _retrieved_Discord_Role_Id := quoted(StrReadLine(discordString, 2))
    _retrieved_Discord_URL := quoted(StrReadLine(discordString, 3))

    ; remove spaces 
    _retrieved_Discord_User_Id := StrReplace(_retrieved_Discord_User_Id, A_Space)
    _retrieved_Discord_Role_Id := StrReplace(_retrieved_Discord_Role_Id, A_Space)
    _retrieved_Discord_URL := StrReplace(_retrieved_Discord_URL, A_Space)

    ; checks if discord user & role ids are numbers
    if !(IsInteger(_retrieved_Discord_User_Id)) {
        _retrieved_Discord_User_Id := ""
    }

    if !(IsInteger(_retrieved_Discord_Role_Id)) {
        _retrieved_Discord_Role_Id := ""
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
    _ini.DiscordUserId := _retrieved_Discord_User_Id
    _ini.DiscordRoleId := _retrieved_Discord_Role_Id
    _ini.DiscordWebhookURL := _retrieved_Discord_URL
   
    ; -- make sure the correct values are inputted from the array to avoid errors
    _ini.DataAutoFarm := IsInteger(_indexes.AutoFarmMethod) and _options.AutoFarmMethods[_indexes.AutoFarmMethod] or _ini.DataAutoFarm
    _ini.DataLogMethod := IsInteger(_indexes.LogMethod) and _options.LogMethods[_indexes.LogMethod] or _ini.DataLogMethod
    _ini.DataTrack := IsInteger(_indexes.DataTrack) and _options.Decisions[_indexes.DataTrack] or _ini.DataTrack
    _ini.DataInterval := (IsInteger(quoted(StrReadLine(dataString, 4))) and WithinRange(Integer(quoted(StrReadLine(dataString, 4))), _lowest_Interval, _highest_Interval) == 1 and Integer(quoted(StrReadLine(dataString, 4)))) or _ini.DataInterval 
}

; #functions
StartUserInput(*)
{
    _inputs := myGui.Submit()

    ; userinputted values
    _user_inputs.DiscordUserId := _inputs.DiscordUserId
    _user_inputs.DiscordRoleId := _inputs.DiscordRoleId
    _user_inputs.DiscordURL := _inputs.DiscordWebhookURL

    _user_inputs.AutoFarmMethod := _inputs.AutoFarmMethod
    _user_inputs.LogMethod := _inputs.LogMethod
    _user_inputs.DataTrack := _inputs.DataTrack
    _user_inputs.DataInterval := _inputs.DataInterval

    ; remove spaces 
    _user_inputs.DiscordUserId := StrReplace(_user_inputs.DiscordUserId, A_Space)
    _user_inputs.DiscordRoleId := StrReplace(_user_inputs.DiscordRoleId, A_Space)
    _user_inputs.DiscordURL := StrReplace(_user_inputs.DiscordURL, A_Space)

    ; checks if discord user & role ids are numbers
    if !(IsInteger(_user_inputs.DiscordUserId)) {
        _user_inputs.DiscordUserId := ""
    }

    if !(IsInteger(_user_inputs.DiscordRoleId)) {
        _user_inputs.DiscordRoleId := ""
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
        "discord_RoleId = '" _user_inputs.DiscordRoleId "' `r`n"
        "discord_WebhookURL = '" _user_inputs.DiscordURL "' `r`n"
        
    )
    _new_Data_String := (
        "data_AutoFarm = '" _user_inputs.AutoFarmMethod "' `r`n"
        "data_LogMethod = '" _user_inputs.LogMethod "' `r`n"
        "data_Track = '" _user_inputs.DataTrack "' `r`n"
        "data_Interval = '" _user_inputs.DataInterval "' `r`n"
    )

    print("[GUI(" Format_Msec(A_TickCount - _status._start_script) ")] Rewriting Data Save")

    IniWrite _new_Discord_String, ".\" _ini.Name, "Discord"
    IniWrite _new_Data_String, ".\" _ini.Name, "Data"

    FileSetAttrib "+H", ".\" _ini.Name

    ; #update values
    _ini.DiscordUserId := _user_inputs.DiscordUserId
    _ini.DiscordRoleId := _user_inputs.DiscordRoleId
    _ini.DiscordWebhookURL := _user_inputs.DiscordURL
   
    _ini.DataAutoFarm := _user_inputs.AutoFarmMethod
    _ini.DataLogMethod := _user_inputs.LogMethod
    _ini.DataTrack := _user_inputs.DataTrack
    _ini.DataInterval := Integer(_user_inputs.DataInterval)

    _gui.Ready := 1
}

TestUserPing(*) {
    _inputs := myGui.Submit(0) ; 0 ensures the window doesn't close

    _discord_User_Id := StrReplace(_inputs.DiscordUserId, A_Space)
    _discord_Role_Id := StrReplace(_inputs.DiscordRoleId, A_Space)
    _discord_URL := StrReplace(_inputs.DiscordWebhookURL, A_Space)

    ; check if valid discord url
    if SubStr(_inputs.DiscordWebhookURL, 1, 33) = "https://discord.com/api/webhooks/" {
        try {
            if _discord_User_Id != "" {
                _params := { content: "Test User Ping? <@" _discord_User_Id ">"
                    , username      : "Baya's Macro 🖱️⌨️"
                    , avatar_url    :  "https://i.imgur.com/rTHyKfI.png"
                }

                Webhook(_discord_URL, _params)
            }

        ;    if _discord_Role_Id != "" {
        ;        _params := { content: "Test Role Ping? <@&" _discord_Role_Id ">"
        ;            , username      : "Baya's Macro 🖱️⌨️"
        ;            , avatar_url    :  "https://i.imgur.com/rTHyKfI.png"
        ;        }
        ;        Webhook(_discord_URL, _params)
        ;    }

        } catch as e {
            print("[GUI|TestUserPing(" Format_Msec(A_TickCount - _status._start_script) ")] Error!")
        } else {
            print("[GUI|TestUserPing(" Format_Msec(A_TickCount - _status._start_script) ")] Sent!")
        }
    } else {
        print("[GUI|TestUserPing(" Format_Msec(A_TickCount - _status._start_script) ")] Invalid Webhook URL!")
    }
}

GuiClose(*) {
    ExitApp
}

; #create-gui
myGui := Gui(, "Baya's Macro: Elden Ring Edition")
myGui.Opt("+AlwaysOnTop")
myGui.SetFont(, "Verdana")

myGui.AddGroupBox("Center xm5 ym+10 Section w200 h160", "Auto-Farm")
myGui.Add("Text","Center xs+10 ys+20 w180", "Which Auto Farming Method?")
myGui.AddDropDownList("Center w180 vAutoFarmMethod Choose" _indexes.AutoFarmMethod, _options.AutoFarmMethods)

myGui.Add("Text","Center w180", "Auto Log?")
myGui.AddDropDownList("Center w180 vLogMethod Choose" _indexes.LogMethod, _options.LogMethods)

myGui.Add("Text","Center w90", "Track Runes?")
myGui.AddDropDownList("Center w90 vDataTrack Choose" _indexes.DataTrack, _options.Decisions)
myGui.Add("Text","Center xs+102 ys+111 w90", "Every ?min")
myGui.AddEdit("Center w90")
myGui.AddUpDown("vDataInterval Range5-60", _ini.DataInterval)

myGui.AddButton("Center xs+0", "Save Settings").OnEvent("Click", StartUserInput)

myGui.AddGroupBox("Center xm+210 ym+10 Section w260 h175", "Discord Settings")
myGui.Add("Text","Center xs+10 ys+20 w240", "UserId (for Pings | Commands)")
myGui.AddEdit("Center w240 vDiscordUserId r1", _ini.DiscordUserId)
myGui.Add("Text","Center w240", "RoleId (for Commands)")
myGui.AddEdit("Center w240 vDiscordRoleId r1", _ini.DiscordRoleId)
myGui.Add("Text","Center w240", "Webhook URL")
myGui.AddEdit("Center w240 vDiscordWebhookURL r1", _ini.DiscordWebhookURL)

myGui.AddButton("Center xs+90 ys+153 w75 h20", "Test Ping").OnEvent("Click", TestUserPing)

myGui.OnEvent("Close", GuiClose)

myGui.Show