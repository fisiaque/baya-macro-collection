# python
# imports
import tempfile 
import os, sys
import discord
from discord.ext import commands
from discord import Interaction

import array, struct, win32con, win32gui
import ctypes 
import sys

#variables
pfp_path = tempfile.gettempdir() + "/BayaMacroImage.png"
banner_path = tempfile.gettempdir() + "/BayaMacroBanner.png"

bp = open(banner_path, 'rb')
fp = open(pfp_path, 'rb')

pfp = fp.read()
bner = bp.read()

hwnd = sys.argv[1]
TOKEN = sys.argv[2]
msgNum = sys.argv[3]

#functions
def Mbox(text, title, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)

def copy_data(hwnd, message, dwData = 0):
    buffer = array.array('u', message + '\x00')
    buffer_address, buffer_length = buffer.buffer_info()

    copy_struct = struct.pack('PLP', dwData, buffer_length * buffer.itemsize, buffer_address)
    
    return win32gui.SendMessage(hwnd, int(msgNum), None, copy_struct)

#main
if TOKEN != None and TOKEN != "":
    try:
        intents = discord.Intents.default()
        intents.message_content = True

        client = commands.Bot(command_prefix="/", intents=intents)

        @client.event
        async def on_ready():
            client.user.edit(username="Baya's Macro 🖱⌨", avatar=pfp, banner=bner)

            #for guild in client.guilds:

                #guild = client.get_guild(guild)
                #print(guild.get_member(client.user.id))
            #    if guild.get_member(client.user.id).status is not discord.Status.offline: 
            #        print("BOT ONLINE ELSEWHERE")
            

            print('Logged in as')
            print(client.user.name)
            print(client.user.id)
            print('------')

            print("Baya's Macro Bot has been successfully Activated! \n -'Minimize' Console if you wish for the bot to stay active \n -'Close' Console if you wish the bot to be deactivated")

            copy_data(hwnd, 'DiscordBotCheck|success')
        @client.hybrid_command()
        async def sync(ctx: commands.Context):
            print("Syncing in progress...")
            await ctx.send("Syncing...")
            await client.tree.sync()

        @client.command()
        async def hello(ctx):
            print("Sending Hello Command Reply")
            await ctx.send(f"Hola Amigo! {ctx.message.author.mention}")

        @client.command()
        async def shutdown(ctx):
            print("Shutdown Command Recieved")
            await ctx.send(f"{ctx.message.author.mention} Attempting to shutdown PC!")

            if os.name == 'nt':
                # For Windows operating system
                await ctx.send("Success")
                os.system('shutdown /s /t 0')
            elif os.name == 'posix':
                # For Unix/Linux/Mac operating systems
                await ctx.send("Success")
                os.system('sudo shutdown now')
            else:
                await ctx.send("Failed")
                print('Unsupported operating system.')

        client.run(token=TOKEN)
    except:
        print("Failed to Activate Bot!")

        copy_data(hwnd, 'DiscordBotCheck|fail')
        

    
