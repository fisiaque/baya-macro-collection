# python

# imports
import time
import keyboard
import pyautogui

# variables
key_w = 'w'
key_a = 'a'
key_s = 's'
key_d = 'd'

key_aow = 'f'
key_interact = 'e'
key_map = 'm'

delay_short = 0.2
delay_aow = 5 
delay_load = 5 

start_loop = 0

# functions
def SelectProcess(_name): 
    try:
        window = pyautogui.getWindowsWithTitle(_name)[0]

        print("Successfull connection to ELDEN RING™")

        return window
    except IndexError:
        print("Failed connection to ELDEN RING™")

        return None
    
def PressDuration(key, delay):
    start_time = time.time()
    end_time = start_time + delay

    while time.time() < end_time:
        keyboard.press(key)
        time.sleep(0.1) 
        keyboard.release(key)

def hotkey_pressed():
    elden_farm = SelectProcess("ELDEN RING™")
    # wait_for_enter()

    elden_farm.activate()
    time.sleep(1)

    start_loop = 1

def hotkey_pressed2():
    print("Script Terminated")
    start_loop = 0

listener = keyboard.GlobalHotKeys({
        '[': hotkey_pressed,
        ']': hotkey_pressed2})

listener.start()


while 1:
        if start_loop == 1:   
            PressDuration(key_w, 1.75)
            PressDuration(key_a, 0.5)
            PressDuration(key_w, 0.75)
            PressDuration(key_a, 0.25)
            PressDuration(key_w, 1.5)
            PressDuration(key_a, 0.025)
            PressDuration(key_w, 1.5)

            # ash of war activation
            PressDuration(key_aow, 0.25)
            time.sleep(delay_aow)

            #reset grace
            PressDuration(key_map, 0.1)
            time.sleep(delay_short)
            PressDuration(key_s, 0.05)
            time.sleep(delay_short)
            PressDuration(key_interact, 0.25)
            time.sleep(delay_short)
            PressDuration(key_interact, 0.25)
            time.sleep(delay_short)
            time.sleep(delay_load)     
