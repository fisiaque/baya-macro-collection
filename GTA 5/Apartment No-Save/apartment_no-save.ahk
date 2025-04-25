#Requires AutoHotkey v2.0 
#SingleInstance Force

SetKeyDelay(130, 1)
SetMouseDelay(70)
CoordMode("Pixel", "Window")
CoordMode("Mouse", "Window")
SetTitleMatchMode(2)

; Variables

; Global
global isHoldingNumpad6 := false
global numpad6PressTime := 0
global currentRun := 0
global totalRuns := 0
global debugMode := 1  ; 0 = off, 1 = on
global slowMode := 0 ; Global variable for slow mode (0 = off, 1 = on)
global slowModeDelay := 0 ; Default delay in milliseconds for slow mode (0 = no delay)

; Local

;==== STARTUP ====
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }

    MsgBox("This script requires administrator privileges; please run it again as administrator.", "Error", 48)

    ExitApp
}

;==== SLEEP WITH LOGGING ====
SleepWithLogging(funcName, msg, sleepTime) {
    if (sleepTime < 1000) {
        DebugLog(funcName . " : " . msg . " : Sleeping " . sleepTime . "ms")
        Sleep(sleepTime)
    } else {
        totalSeconds := floor(sleepTime / 1000)
        remainingMs := sleepTime - (totalSeconds * 1000)
        DebugLog(funcName . " : " . msg . " : Sleeping " . (sleepTime / 1000) . "s")
        Loop totalSeconds {
            DebugLog(funcName . " : " . msg . " : Sleeping " . (sleepTime / 1000) . "s : " . A_Index . "s")
            Sleep(1000)
        }
        if (remainingMs > 0) {
            DebugLog(funcName . " : " . msg . " : Sleeping additional " . remainingMs . "ms")
            Sleep(remainingMs)
        }
    }
}

;==== DEBUG LOGGING ====
DebugLog(msg) {
    if (debugMode) 
    {
      global totalRuns
      global currentRun

      msg := ((totalRuns = 0) ? "" : "[Run " currentRun "/" totalRuns "] : ") . msg
      
      ToolTip(msg, 500, 0)
      SetTimer(ToolTip, -3000)
    }
}


;==== MISC ====
QPC(R := 0) {
    ; By SKAN, http://goo.gl/nf7O4G, CD:01/Sep/2014 | MD:01/Sep/2014
    static P := 0, F := 0
    static Q := DllCall("QueryPerformanceFrequency", "Int64*", &F)
    DllCall("QueryPerformanceCounter", "Int64*", &Q)
    return R ? (P := Q) / F : (Q - P) / F
}

Click() {
  PressKey("LButton", 25, 1, 0)
}

MovingMouse(x, y, type, amount) {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  SendMode "Event"

  MouseGetPos &xpos, &ypos 
  MouseMove x - xpos, y - ypos, (slowMode = 0) ? 1 : 2, "R"  ; 1 = Fast, 2 = Slow
  MouseClick type, x, y, amount

  SleepWithLogging("MovingMouse()", "Delay after click", 200 + extraSleep)
}

;==== KEY FUNCTIONS ====
PressKey(button, presstime, presses, sleeptime)
{
  DebugLog("PressKey(" . button . ") : Entering Function")
  
  if (presses = 1) {
    SendInput("{" button " down}")
    SleepWithLogging("PressKey(" . button . ")", "Key press delay", presstime)

    SendInput("{" button " up}")
    SleepWithLogging("PressKey(" . button . ")", "Key release delay", sleeptime)
  } else {
    Loop presses {
      SendInput("{" button " down}")
      SleepWithLogging("PressKey(" . button . ")", "Key press delay", presstime)

      SendInput("{" button " up}")
      SleepWithLogging("PressKey(" . button . ")", "Delay between presses", 100)
      SleepWithLogging("PressKey(" . button . ")", "Post key delay", sleeptime)
    }
  }

  DebugLog("PressKey(" . button . ") : Exiting Function")
}

;==== PHONE/WEB FUNCTIONS ====
PullUpPhone() {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled
  
  DebugLog("PullUpPhone() : Entering Function")

  Loop { ; Infinite Loop to make sure the phone is actually pulled up
    ; Spam MButton for up to 5 seconds to open the phone
    Loop 50 {
      PressKey("MButton", 1, 1, 50) ; Try to open the phone
      color := PixelGetColor(1000, 559)
      if (color = 0x6A86B5) {
        DebugLog("PullUpPhone() : Successfully opened phone")
        Return ; Exit the function only when the phone is successfully opened
      }

      SleepWithLogging("PullUpPhone()", "Delay in phone search", 100 + extraSleep)
    }

     ; If the phone is not open after 5 seconds, reset it using MenuMapChecker
    MenuMapChecker() ; Ensure the pause menu is open
    PressKey("Esc", 50, 1, 370) ; Close the pause menu to reset the phone
    SleepWithLogging("PullUpPhone()", "Delay after menu map checker", 200 + extraSleep)
  }

   DebugLog("PullUpPhone() : Exiting Function")
}

;==== MAIN FUNCTIONS ====
saveBlocKEnable() {
  DebugLog("saveblockEnable() : Entering Function")

  RunWait(A_ComSpec " /c netsh advfirewall firewall add rule name='GTAOSAVEBLOCK' dir=out action=block remoteip=192.81.241.170-192.81.241.171 enable=yes", "", "Hide")

  if (debugMode) {
    DebugLog("saveblockEnable() : No-save mode enabled")
  }

  DebugLog("saveblockEnable() : Exiting Function")
}

saveBlockDisable() {
  DebugLog("saveBlockDisable() : Entering Function")

  RunWait(A_ComSpec " /c netsh advfirewall firewall delete rule name='GTAOSAVEBLOCK'", "", "Hide")

   if (debugMode) {
    DebugLog("saveBlockDisable() : No-save mode enabled")
  }

  DebugLog("saveBlockDisable() : Exiting Function")
}

; Optimized EnterBrowser function with timeout
EnterBrowser() {
  DebugLog("EnterBrowser() : Entering Function")
  
  Loop { ; Infinite loop to ensure the browser is entered
    PressKey("Down", 50, 1, 50) ; Navigate down in the phone menu

    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\browser_tile.png")) {
      SleepWithLogging("EnterBrowser()", "Short delay before Enter", 50)
      PressKey("Enter", 50, 1, 600) ; Enter the browser
      DebugLog("EnterBrowser() : Exiting Function (Browser Entered!)")
      Return
    }
  }
} ;function to enter phone's browser

EnterDynastyEstate() {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("EnterDynastyEstate() : Entering Function")

  SleepWithLogging("EnterDynastyEstate()", "Initial delay", 250 + extraSleep)

  MovingMouse(255, 590, "Left", 1)
  MovingMouse(310, 450, "Left", 1)

  DebugLog("EnterDynastyEstate() : Exiting Function")
} ;function to enter dynasty 8 website and then property listings

ExitBrowser(){
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("ExitBrowser() : Entering Function")

  MovingMouse(842, 108, "Left", 1)

  SleepWithLogging("ExitBrowser()", "Delay after exit click", 200 + extraSleep)

  DebugLog("ExitBrowser() : Exiting Function")
} ;function to exit phone's browser

TradeInChecker() {  ; Function that checks for 5 seconds if the Trade-In menu is found
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("TradeInChecker() : Entering Function")

  Loop 50 { ; 50 iterations with 100ms pause each (total 5 seconds)
    if (ImageSearch(&FoundX, &FoundY, 8, 31, 152, 59, "*100 " A_WorkingDir "\images\trade_in_property_menu.bmp")) {
      DebugLog("TradeInChecker() : Menu found")
      return 0
    }

    SleepWithLogging("TradeInChecker()", "Delay in trade-in check", 100 + extraSleep)
  }

  DebugLog("TradeInChecker() : Exiting Function (Timeout)")

  return 1 ; Timeout after 5 seconds
}

BuyTrash() {
  DebugLog("BuyTrash() : Entering Function")

  MovingMouse(310, 270, "Left", 1)
  MovingMouse(240, 270, "Left", 1)
  MovingMouse(300, 400, "Left", 1)
  MovingMouse(750, 600, "Left", 1)

  DebugLog("BuyTrash() : Exiting Function")
} ;function to buy cheapest apartment available for character

BuyTrashBlocker() {
  DebugLog("BuyTrashBlocker() : Entering Function")

  BuyTrash()

  Critical "On"
  saveblockEnable()
  SleepWithLogging("BuyTrashBlocker()", "Delay after enabling no-save", 300)
  Critical "Off"

  DebugLog("BuyTrashBlocker() : Exiting Function")
} ;function to buy cheapest apartment available for character (modified version for "preparation phase" - this one enables blocker before swap so trade-in value of most expensive apartment will stay but actual cheapest building will be used, resulting in some cheap house in paleto (for example) being worth as much as eclipse tower apartment

; Optimized ReturnToMapChecker function with timeout
ReturnToMapChecker() {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("ReturnToMapChecker() : Entering Function")

  Loop { ; Infinite loop to ensure the "return to map" button is found
    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\return_to_map_button.bmp")) {
      DebugLog("ReturnToMapChecker() : Button found")
      SleepWithLogging("ReturnToMapChecker()", "Delay confirmation", 100 + extraSleep)
      return 0
    }
  }

  DebugLog("ReturnToMapChecker() : Exiting Function")
} ;state checker - checks presence of "return to map" button using image recognition

ReturnToMapPress()
{
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("ReturnToMapPress() : Entering Function")

  MovingMouse(500, 630, "Left", 1)

  SleepWithLogging("ReturnToMapPress()", "Delay after map press", 50 + extraSleep)

  DebugLog("ReturnToMapPress() : Exiting Function")
}

UnbreakMenu() {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("UnbreakMenu() : Entering Function")
  PressKey("Esc", 50, 1, 150)

  SleepWithLogging("UnbreakMenu()", "Delay after Esc", 100 + extraSleep)
  PressKey("Up", 50, 1, 150)

  SleepWithLogging("UnbreakMenu()", "Delay after Up", 100 + extraSleep)
  
  Loop 5 {
    PressKey("Esc", 50, 1, 150)
    SleepWithLogging("UnbreakMenu()", "Delay in loop", 100 + extraSleep)
  }

  DebugLog("UnbreakMenu() : Exiting Function")
}

MenuMapChecker() {
  DebugLog("MenuMapChecker() : Entering")
  failedAttempts := 0

  Loop {
    PressKey("Esc", 50, 1, 370)

    if !(ImageSearch(&FoundX, &FoundY, 57, 155, 210, 192, "*100 " A_WorkingDir "\images\map_button.bmp")) {
      failedAttempts += 1

      DebugLog("MenuMapChecker() : Attempt #" failedAttempts " Failed")

      if (failedAttempts >= 10) {
        UnbreakMenu()
        failedAttempts := 0
      }
    } else {
      failedAttempts := 0
      break
    }
  }

  DebugLog("MenuMapChecker() : Exiting Function")
}

fromOnlineToSingle() {
  DebugLog("fromOnlineToSingle() : Entering Function")

  SendInput("{Alt down}")
  PressKey("F6", 500, 1, 0)
  SendInput("{Alt up}")
  SleepWithLogging("fromOnlineToSingle()", "Initial delay after Alt+F6", 50)

  Loop {
    color := PixelGetColor(831, 747)
    if (color = 0x000000) {
      PressKey("Enter", 500, 1, 0)
      DebugLog("fromOnlineToSingle() : Transition to Single complete at count " A_Index)
      break
    }

    SleepWithLogging("fromOnlineToSingle()", "Waiting for pixel check", 100)
  }

  DebugLog("fromOnlineToSingle() : Exiting Function")
} ;function that goes from gta online to story mode(franklin by default)

fromSingleToOnline() {
  DebugLog("fromSingleToOnline() : Entering Function")

  DebugLog("fromSingleToOnline() : Calling MenuMapChecker()")
  MenuMapChecker()

  DebugLog("fromSingleToOnline() : Moving mouse to 913,172 and clicking")

  MovingMouse(910, 185, "Left", 1)
  
  SleepWithLogging("fromSingleToOnline()", "Delay after click", 700)

  DebugLog("fromSingleToOnline() : Pressing Up")
  PressKey("Up", 50, 1, 150)

  DebugLog("fromSingleToOnline() : Pressing Enter")
  PressKey("Enter", 50, 1, 150)

  DebugLog("fromSingleToOnline() : Pressing Up again")
  PressKey("Up", 50, 1, 150)

  DebugLog("fromSingleToOnline() : Disabling save block")
  Critical "On"
  saveblockDisable()
  Critical "Off"

  DebugLog("fromSingleToOnline() : Pressing Enter twice")
  PressKey("Enter", 60, 2, 100)

  DebugLog("fromSingleToOnline() : Exiting Function")
}

forceSave() {
  DebugLog("forceSave() : Entering Function")

  Loop { ; Infinite loop to force save
    SendInput("{Alt down}") 
    PressKey("F4", 500, 1, 0)
    SendInput("{Alt up}")

    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\quit.png")) {
      SleepWithLogging("forceSave()", "Short delay before ESC", 50)
      PressKey("Esc", 50, 1, 600) 
      DebugLog("forceSave() : Found Quit Screen")

      break
    }
  }

  SleepWithLogging("forceSave()", "Short delay after F4", 50)

  Loop {
    if !(PixelSearch(&FoundX, &FoundY, 830, 746, 832, 748, 0x000000)) {
      break
    }

    PressKey("Esc", 50, 1, 0)
    SleepWithLogging("forceSave()", "Delay while waiting for screen change #2", 100)
  }

  DebugLog("forceSave() : Exiting Function")
}

ApartmentsExchange() {
  global slowMode
  global slowModeDelay
  extraSleep := slowMode ? slowModeDelay : 0 ; Use custom delay if slow mode is enabled

  DebugLog("ApartmentsExchange() : Entering Function")

  tradebutton_y := 70 ; Selects first property from the list of trades

  PullUpPhone() ; use phone now

  EnterBrowser()
  EnterDynastyEstate()

  ; Start of no save first property || Important

  Loop {
    BuyTrashBlocker()
    if (TradeInChecker() = 0)
      break

    MovingMouse(250, 95, "Left", 1)

    EnterDynastyEstate()
  }

  Loop {
    PressKey("Enter", 50, 2, 0)
    if (ReturnToMapChecker() = 0)
      break
  }

  ReturnToMapPress()

  Loop 9 { ; Rest of the properties
    counter := A_Index + 1
    Loop { ; Infinite loop to ensure BuyTrash and TradeInChecker succeed
      BuyTrash()

      ; 5-second check for TradeInChecker with fallback
      if (TradeInChecker() = 0) ; Trade-In menu successfully found
        break

      ; Fallback: Return to the homepage and try again
      MovingMouse(260, 110, "Left", 1)

      EnterDynastyEstate() ; Return to Dynasty 8 website
    }

    tradebutton_y += 27

    MovingMouse(250, tradebutton_y, "Left", 1)

    Loop { ; Infinite loop to ensure "Enter" key was successfully pressed
      PressKey("Enter", 50, 2, 0)
      if (ReturnToMapChecker() = 0) ; "Return to map" button successfully found
        break
    }

    if (A_Index < 9) ; Skip ReturnToMapPress on the last iteration
      ReturnToMapPress()
  }

  ExitBrowser()
  SleepWithLogging("ApartmentsExchange()", "Delay after exit browser", 150 + extraSleep)

  DebugLog("ApartmentsExchange() : Exiting Function")
}

WaitForLoading() 
{
  DebugLog("WaitForLoading() : Entering Function")

  Loop {
    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\joining_online_button.bmp")) 
      {
        DebugLog("WaitForLoading() : Found Quit Screen")
        break
      }
  }
  DebugLog("WaitForLoading() : Waiting for black screen")
  Loop {
    color := PixelGetColor(831, 747)
    if (color = 0x000000) {
      DebugLog("WaitForLoading() : Successfully found black screen")
      break 
    }
  }
  DebugLog("WaitForLoading() : Waiting for Joining Online Button Text")
  Loop {
    if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\joining_online_button.bmp")) 
      {
        DebugLog("WaitForLoading() : Joining Online Appeared")
        break
      }
  }
  DebugLog("WaitForLoading() : Waiting for Joining Online Button Text to GO")
  Loop {
    if (!ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*100 " A_WorkingDir "\images\joining_online_button.bmp")) 
      {
        DebugLog("WaitForLoading() : Joining Online Gone")
        break
      }
  }

  DebugLog("WaitForLoading() : Exiting Function")
}

ApartmentsRun() {
  global totalRuns
  global currentRun

  DebugLog("ApartmentsRun() : Entering Function")

  userInput := InputBox("How many runs?", "How many runs?",,)
  
  if !(IsInteger(userInput.Value)) { ; Check if the users input is actually an integer
    MsgBox "Must be a whole number!"
    DebugLog("ApartmentsRun() : Cancelled Function")
    return
  }

  ; Calculates the estimated earnings + times taken
  runsNum := Integer(userInput.Value)
  totalRuns := runsNum
  totaltime := Format("{1:.2f}", (runsNum * 90) / 60)
  totaltime2 := Format("{1:.2f}", totaltime / 60.0)
  totalpayout := RegExReplace((runsNum*5200000), "(\d)(?=(?:\d{3})+(?:\.|$))", "$1,")
  cashperminute := "3,900,000"

  ; Confirmation as to whether to continue or not
  Result := MsgBox("The whole process will take " . runsNum . " runs - around " . totaltime . " minutes (" . totaltime2 . " hours).`n`nYou'll earn around $" . totalpayout . ".`n`nEstimated $/minute profit: $" . cashperminute . ".`n`nDo you want to continue?`n`nWARNING: Don't press anything after choosing 'Yes'!",, "YesNo")
  
  if Result != "Yes" {
    DebugLog("ApartmentsRun() : Cancelled Function")
    return
  }

  ; Start the ApartmentsRun!
  WinActivate("Grand Theft Auto V")
  QPC(1)

  ;Starting Loop
  Loop runsNum {
    currentRun := A_Index ; Update currentrun

    DebugLog("ApartmentsRun() : Starting new loop run")

    fromSingleToOnline()
    WaitForLoading() 
    forceSave()
    ApartmentsExchange()
    fromOnlineToSingle()

    DebugLog("ApartmentsRun() : Run complete")
  }

  MenuMapChecker()
  timer := Round(QPC(0), 2)
  perRun := Round(timer/runsNum, 2)
  saveblockDisable()
  MsgBox "End of the line. Rounds passed: " . runsNum . ". Time passed: " . timer . "s. Cash earned: $" . totalpayout . ". Time per run: " . perRun . "s."
 
  DebugLog("ApartmentsRun() : Exiting Function")
}

;==== KEYBINDS ====
Numpad0::SleepWithLogging("Hello()", "Message Here", 2000)  ; testing Purposes for now

Numpad1:: {
  Hotkey("Numpad0", "Off") ; Disables Numpad0 (Preparation)

  Result := MsgBox("You're about to start the 'Payback Phase'.`n`nWARNING:`nEnsure that you've prepared the apartment slots!",, "YesNo")
  if Result != "Yes"
    Hotkey("Numpad0", "On")
  else
    ApartmentsRun()
    Hotkey("Numpad0", "On")  
}

Numpad2::saveBlocKEnable()

Numpad3::saveBlockDisable()

Numpad4:: {
  saveBlockDisable()
  Reload
}
  
Numpad5:: {
  saveBlockDisable() 
  ExitApp
}
