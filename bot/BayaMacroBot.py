# python
# imports
import random
import tempfile 
import os, sys
import discord
from discord.ext import commands
from discord import Interaction

import array, struct, win32con, win32gui
import ctypes 
import sys

#variables
hello_messages = [
    "Hola amigo!",  # Spanish
    "Bonjour mon ami!",  # French
    "Hallo mein Freund!",  # German
    "Ciao amico mio!",  # Italian
    "Olá meu amigo!",  # Portuguese
    "Привет мой друг!",  # Russian
    "こんにちは、友よ！",  # Japanese
    "你好，我的朋友！",  # Chinese (Simplified)
    "안녕 내 친구!",  # Korean
    "مرحبا يا صديقي!",  # Arabic
    "हैलो मेरे दोस्त!",  # Hindi
    "Merhaba arkadaşım!",  # Turkish
    "Hej min vän!",  # Swedish
    "Hei ystäväni!",  # Finnish
    "Ahoj můj příteli!",  # Czech
    "Hej min ven!",  # Danish
    "Sveiki mano drauge!",  # Lithuanian
    "Tere mu sõber!",  # Estonian
    "Pozdrav moj prijatelju!",  # Croatian
    "Γεια σου φίλε μου!",  # Greek
    "Hallo mijn vriend!",  # Dutch
    "Salve amice!",  # Latin
    "Szia barátom!",  # Hungarian
    "Bună prietene!",  # Romanian
    "Salam dostum!",  # Azerbaijani
    "Halo sobatku!",  # Indonesian
    "Sawubona umngane wami!",  # Zulu
    "Kumusta kaibigan ko!",  # Filipino
    "Halò mo charaid!",  # Scottish Gaelic
    "Aloha e kuʻu hoa!",  # Hawaiian
    "Saluton mia amiko!",  # Esperanto
    "Selam arkadaşım!",  # Kurdish
    "Kamusta higala!",  # Cebuano
    "Bongu sieħbi!",  # Maltese
    "Mbote moninga!",  # Lingala
    "Sannu aboki!",  # Hausa
    "Dumela tsala!",  # Tswana
    "Kaixo lagun!",  # Basque
    "Moien meng Frënd!",  # Luxembourgish
    "Pozdrav prijatelju!",  # Serbian
    "Здравей приятелю!",  # Bulgarian
    "Aloha au iā ʻoe e ke hoa!",  # Hawaiian
    "Bonjour ami!",  # Haitian Creole
    "Olá meu camarada!",  # Galician
    "Sveiks mans draugs!",  # Latvian
    "Halo kawanku!",  # Malay
    "Hola amic meu!",  # Catalan
    "Zdravo prijatelju!",  # Bosnian
    "Yassou file mou!"  # Greek (informal)
]
    
pfp_path = tempfile.gettempdir() + "/BayaMacroImage.png"
banner_path = tempfile.gettempdir() + "/BayaMacroBanner.png"

bp = open(banner_path, 'rb')
fp = open(pfp_path, 'rb')

pfp = fp.read()
bner = bp.read()

hwnd = sys.argv[1]
TOKEN = sys.argv[2]
DISCORD_DATA = sys.argv[3].split(",")

DISCORD_USER_ID = DISCORD_DATA[0] != "" and int(DISCORD_DATA[0]) or 0
DISCORD_ROLE_ID = DISCORD_DATA[1] != "" and int(DISCORD_DATA[1]) or 0

#functions
def Mbox(text, title, style):
    return ctypes.windll.user32.MessageBoxW(0, text, title, style)

def copy_data(hwnd, message, dwData = 0):
    buffer = array.array('u', message + '\x00')
    buffer_address, buffer_length = buffer.buffer_info()

    copy_struct = struct.pack('PLP', dwData, buffer_length * buffer.itemsize, buffer_address)
    
    return win32gui.SendMessage(hwnd, 0x004A, None, copy_struct) # 0x004A is WM_COPYDATA 

def can_use_commands(ctx):
    role = discord.utils.get(ctx.guild.roles, id=DISCORD_ROLE_ID)

    if ctx.message.author.id == ctx.guild.owner_id or ctx.message.author.id == DISCORD_USER_ID or role in ctx.message.author.roles: 
        return True
    
    return False

print("Discord User Id:", DISCORD_USER_ID) # Discord User Id
print("Discord Role Id:", DISCORD_ROLE_ID) # Discord Role Id

#main
if TOKEN != None and TOKEN != "":
    try:
        intents = discord.Intents.default()
        intents.message_content = True

        client = commands.Bot(command_prefix="!", intents=intents)

        @client.event
        async def on_ready():
            print('Logged in as')
            print(client.user.name)
            print(client.user.id)
            print('------')

            print("Baya's Macro Bot has been successfully Activated! \n -'Minimize' Console if you wish for the bot to stay active \n -'Close' Console if you wish the bot to be deactivated")

            copy_data(hwnd, 'DiscordBotCheck|success')

            await client.user.edit(username="Baya's Macro 🖱⌨", avatar=pfp, banner=bner)

        @client.hybrid_command()
        async def sync(ctx: commands.Context):
            print("Syncing in progress...")
            await client.tree.sync()

        @client.command()
        async def hello(ctx):
            hello = random.choice(hello_messages)
            await ctx.send(f"{hello} {ctx.message.author.mention}")

        @client.command()
        async def shutdown(ctx):
            if can_use_commands(ctx) == True:  
                print("Shutdown Command Recieved")
                await ctx.send(f"{ctx.message.author.mention} Attempting to shutdown PC!")

                copy_data(hwnd, 'Command|Shutdown')

        @client.command()
        async def check(ctx):
            if can_use_commands(ctx) == True:  
                print("Check Command Recieved")
                await ctx.send(f"{ctx.message.author.mention} Attempting to send update!")

                copy_data(hwnd, 'Command|Check')

        client.run(token=TOKEN)
    except:
        print("Failed to Activate Bot!")

        copy_data(hwnd, 'DiscordBotCheck|fail')
        