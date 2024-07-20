; #variables
_ini := Object()

_ini.Version := GetVersion()
_ini.Name := "_baya's_macro_data_ER_" _ini.Version ".ini" 

; -- Default Data
_ini.Discord_String := (
    "discord_UserId = '' `r`n"
    "discord_WebhookURL = '' `r`n"
    "discord_Track = '' `r`n"
    "discord_Intervals = '' `r`n"
)
_ini.Data_String := (
    "data_AutoFarm = '' `r`n"
    "data_LogMethod = '' `r`n"
)

_ini.DiscordUserId := quoted(StrReadLine(_ini.Discord_String, 1)), 'Quoted', 'Iconi'
_ini.DiscordWebhookURL := quoted(StrReadLine(_ini.Discord_String, 2)), 'Quoted', 'Iconi'
_ini.DiscordTrack := quoted(StrReadLine(_ini.Discord_String, 3)), 'Quoted', 'Iconi'
_ini.DiscordIntervals := quoted(StrReadLine(_ini.Discord_String, 4)), 'Quoted', 'Iconi'
_ini.DataAutoFarm := quoted(StrReadLine(_ini.Data_String, 1)), 'Quoted', 'Iconi'
_ini.DataLogMethod := quoted(StrReadLine(_ini.Data_String, 2)), 'Quoted', 'Iconi'

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

    _ini.DiscordUserId := quoted(StrReadLine(discordString, 1)), 'Quoted', 'Iconi'
    _ini.DiscordWebhookURL := quoted(StrReadLine(discordString, 2)), 'Quoted', 'Iconi'
    _ini.DiscordTrack := quoted(StrReadLine(discordString, 3)), 'Quoted', 'Iconi'
    _ini.DiscordIntervals := quoted(StrReadLine(discordString, 4)), 'Quoted', 'Iconi'
    _ini.DataAutoFarm := quoted(StrReadLine(dataString, 1)), 'Quoted', 'Iconi'
    _ini.DataLogMethod := quoted(StrReadLine(dataString, 2)), 'Quoted', 'Iconi'
}

