#Requires AutoHotkey v2.0

#Include "..\modules\Version.ahk"

; going to make this into a seperate ahk file macro, no persistent or anything, from main script will run exe version of this script and can kill this script to ensure fast
; https://www.autohotkey.com/docs/v2/lib/Goto.htm
; make use of GoTo and save pause on data .ini

_options := Object()

_options.Goto := ["Start"]

_ini := Object()

_ini.Version := GetVersion()
_ini.Name := GetIniName() 

; -- Default Data
_ini.Macro_String := (
    "Goto = '" _options.Goto[1] "' `r`n"
)

IniWrite _ini.Macro_String, "..\" _ini.Name, "Macro"
FileSetAttrib "+H", "..\" _ini.Name