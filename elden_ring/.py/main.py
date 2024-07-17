# python | checks if ran directly
if __name__ == "__main__":
    # imports
    import os, sys
    import time

    from modules import *
    import threading

    #start discord bot
    threading.Thread(target=BayaMacroBot.Start).start()

    print("Before!")
    time.sleep(20)
    print("START STOPPING")
    os._exit(0)




