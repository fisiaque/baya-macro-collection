# python
# imports
import os 
from dotenv import load_dotenv

import discord
from discord.ext import commands
from discord import Interaction

#main
load_dotenv()
intents = discord.Intents.default()
intents.message_content = True
TOKEN = os.getenv('discord_token')

client = commands.Bot(command_prefix="!", intents=intents)

@client.event
async def on_ready():
    print("Baya's Macro Bot has been successfully Activated!")

@client.hybrid_command()
async def sync(ctx: commands.Context):
    await ctx.send("Syncing...")
    await client.tree.sync()

@client.command()
async def hello(ctx):
    await ctx.send(f"Hola Amigo! {ctx.message.author.mention}")

@client.command()
async def shutdown(ctx):
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
