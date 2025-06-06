import discord
from discord.ext import commands
import asyncio
from config.config import TOKEN, PREFIX
from cogs.music import MusicCog
from cogs.utility import UtilityCog  # Import UtilityCog

intents = discord.Intents.default()
intents.message_content = True

# Khởi tạo bot với prefix
bot = commands.Bot(command_prefix=PREFIX, intents=intents)

@bot.event
async def on_ready():
    print(f'Đã đăng nhập như {bot.user}')

# Thêm MusicCog vào bot
bot.add_cog(MusicCog(bot))
bot.add_cog(UtilityCog(bot))  # Thêm UtilityCog

bot.run(TOKEN)

