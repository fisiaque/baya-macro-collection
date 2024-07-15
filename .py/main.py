# python
# pre-imports
import os, sys
from modules import *

# get current directory
dir_path = os.path.dirname(os.path.realpath(__file__))

print("Current Directory", dir_path)

#post-imports

sys.path.insert(1, "/".join(os.path.realpath(__file__).split("/")[0:-2]) + "/lib")

#print(os.path.dirname(os.path.expanduser('~/lib')))

BayaMacroBot.run_bot()
