# python
# imports
import os 
from dotenv import load_dotenv

import discord
from discord.ext import commands
from discord import Interaction

load_dotenv()
intents = discord.Intents.default()
intents.message_content = True
TOKEN = os.getenv('discord_token')

client = commands.Bot(command_prefix="!", intents=intents)

@client.event
async def on_ready():
    print(f"{client.user.name} is ready")

@client.hybrid_command()
async def sync(ctx: commands.Context):
    await ctx.send("Syncing...")
    await client.tree.sync()

@client.command()
async def hello(ctx):
    await ctx.send(f"Hola Amigo! {ctx.message.author.mention}")

@client.command()
async def shutdown(ctx):
    await ctx.send(f"{ctx.message.author.mention} Shutting down PC!")

client.run(token=TOKEN)
