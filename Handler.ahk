#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

#Include Elden_Ring_Farm_v3.0.0.ahk

; hotkeys
;test
F1::{
    
}

;stops
SC01B::ExitApp ; #]

#HotIf WinActive("ELDEN RING™") ; following hotkey will only run if elden ring is open!

;play/pause
SC01A:: ;#[ 
{
    PID := RetrievePID()
    Ready := RetrieveReady()

    if Ready != 0 {
        static toggle := 0

        toggle := !toggle  

        if (toggle != 0) { ; # PLAY
            AutoFarmMethod := RetrieveAutoFarmMethod()

            if AutoFarmMethod = "Albinaurics" {
                UpdateStatsToDiscord()
                AutoAlbinaurics()
            } else if AutoFarmMethod = "Bird" {
                UpdateStatsToDiscord()
                AutoBird()
            } else if AutoFarmMethod = "Skel-Band(Pilgrimage Church)" {
                AutoSkeleton()
            }
        } else if (toggle != 1) { ; # PAUSE
            Reload
        }
    
    }
}

; checks
SetTimer CheckDied, 1000 ; check if died every second