if !(A_IsCompiled) && A_LineFile == A_ScriptFullPath { ; if ran directly open main
    #Warn All, Off

    SetWorkingDir("../")

    Run A_WorkingDir "/main.ahk"
    ExitApp
}

_battery_percent_limit := 15 ;percent left i.e 

OnMessage(0x0218,WM_POWERBROADCAST)

DllCall("ole32\CLSIDFromString","WStr","{A7AD8041-B45A-4CAE-87A3-EECBB468A9E1}","Ptr",GUID_BATTERY_PERCENTAGE_REMAINING:=Buffer(16))
DllCall("RegisterPowerSettingNotification","Ptr",A_ScriptHwnd,"Ptr",GUID_BATTERY_PERCENTAGE_REMAINING,"Uint",0) ;DEVICE_NOTIFY_WINDOW_HANDLE

WM_POWERBROADCAST(wParam, lParam, msg, hwnd) {
    if getPowerStatus().BatteryFlag == 255 || getPowerStatus().BatteryFlag == 128 { ; -- unknown status || no system battery
        return
    }

    switch (wParam) {
        case 0x8013: ;PBT_POWERSETTINGCHANGE
        guid:=GuidToStr(lParam)

        switch (guid) {
            case "{A7AD8041-B45A-4CAE-87A3-EECBB468A9E1}": ;GUID_BATTERY_PERCENTAGE_REMAINING
            percent:=NumGet(lParam,0x14,"Uint")
        
            print("[BatteryLife] Charge is currently at:" percent "%")
            
            if (getPowerStatus().BatteryFlag == 2 || getPowerStatus().BatteryFlag == 6) && (percent == 30 || percent == 25 || percent == 20) { ; if not charging : Low Battery + Critical Battery i.e 5%
                charge := getPowerStatus().BatteryFlag == 2 and "Low" or "Critically Low"
                notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> " charge " Charge! Battery Percent: " percent "%" or charge " Charge! Battery Percent: " percent "%"

                Notify(notification)
            } else if (getPowerStatus().BatteryFlag == 2 || getPowerStatus().BatteryFlag == 6) && (percent <= _battery_percent_limit) {
                notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> Attempting to Force Shutdown PC, Battery Percent Too Low: " percent "%" or "Attempting to Force Shutdown PC, Battery Percent Too Low: " percent "%"

                Notify(notification)

                macro.force_shutdown := 1
            }

            if getPowerStatus().BatteryFlag == 9 && (percent == 80 || percent == 100) { ; if charging + high power
                notification := _ini.DiscordUserId != "" and "<@" _ini.DiscordUserId "> High Charge! Battery Percent: " percent "%" or "High Charge! Battery Percent: " percent "%"
    
                Notify(notification)
            }
        }
    }
}

GuidToStr(GUID) {
    VarSetStrCapacity(&sGUID, 78)
    DllCall('Ole32\StringFromGUID2', 'Ptr', GUID, 'Str', sGUID, 'Int', 39)
    return sGUID
}

GetPowerStatus()    {
    systemPowerStatus:={ACLineStatus:"",BatteryFlag:"",BatteryLifePercent:"",SystemStatusFlag:"",BatteryLifeTime:"",BatteryFullLifeTime:""}
    ,buf:=buffer(1*4+4+4,0)
    if (dllCall("Kernel32.dll\GetSystemPowerStatus", "Ptr",buf.Ptr))    {
         systemPowerStatus.ACLineStatus         := numGet(buf,0,"UChar")
        ,systemPowerStatus.BatteryFlag          := numGet(buf,1,"UChar")
        ,systemPowerStatus.BatteryLifePercent   := numGet(buf,2,"UChar")
        ,systemPowerStatus.SystemStatusFlag     := numGet(buf,3,"UChar")
        ,systemPowerStatus.BatteryLifeTime      := numGet(buf,4,"UInt")
        ,systemPowerStatus.BatteryFullLifeTime  := numGet(buf,8,"UInt")
    }
    return systemPowerStatus
}