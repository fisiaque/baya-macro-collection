# python

# imports
import os
import discord
from dotenv import find_dotenv, load_dotenv

from discord import app_commands
from discord.ext import commands

def run_bot():
    load_dotenv()
    TOKEN = os.getenv('discord_token')
    
    intents = discord.Intents.default()
    client = discord.Client(intents=intents)

    tree = app_commands.CommandTree(client)

    @client.event
    async def on_ready():
        print("Bot is running")

        try:
            await tree.sync()
            
        except Exception as e:
            print(e)

    @tree.command(name='hello')
    async def hello(interaction: discord.Integration):
        await interaction.response.send_message(f"Hey! {interaction.user.mention} Hello!")

    client.run(token=TOKEN)

run_bot()