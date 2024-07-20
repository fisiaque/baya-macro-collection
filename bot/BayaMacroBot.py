# python
# imports
import os, sys
import pyperclip
import discord
from discord.ext import commands
from discord import Interaction
from dotenv import load_dotenv

#main
load_dotenv()

TOKEN = os.getenv('discord_Token')

if TOKEN != None and TOKEN != "":
    try:
        intents = discord.Intents.default()
        intents.message_content = True

        client = commands.Bot(command_prefix="/", intents=intents)

        @client.event
        async def on_ready():
            pyperclip.copy('success')
            print("Baya's Macro Bot has been successfully Activated! \n -'Minimize' Console if you wish for the bot to stay active \n -'Close' Console if you wish the bot to be deactivated")

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
    except: # NameError: #debugs
        pyperclip.copy('fail')
        #print(NameError)
        print("Invalid Discord Token")
    
