# -*- coding: utf-8 -*-
"""
Created on Thu Nov 19 17:59:48 2020

@author: mbijlkh
"""

from bots.my_bots import my_bots
from telegram.ext import Updater
#import logging
from telegram.ext import CommandHandler

#setup logging
#logging.basicConfig(format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
#                    level = logging.INFO)

#start command
def start(update, context):
    context.bot.send_message(chat_id = update.effective_chat.id, text = "I'm a test bot. Neat!")

def test_image_sender(update, context):
    context.bot.send_photo(chat_id = update.effective_chat.id, photo = 'https://media.karousell.com/media/photos/products/2020/10/26/ice_freezer_box_1603732607_bf54ae4c_progressive_thumbnail.jpg')
    
#command handler

def main():
    #load up token key of bot
    mybots = my_bots()
    key = mybots.get_bot_key('brewsgBot')

    #create updater
    updater = Updater(token = key, use_context = True)

    dispatcher = updater.dispatcher

    start_handler = CommandHandler('start', start)
    dispatcher.add_handler(start_handler) #add new handler
    test_handler = CommandHandler('test', test_image_sender)
    dispatcher.add_handler(test_handler)
    updater.start_polling() #start the bot
    # Run the bot until you press Ctrl-C or the process receives SIGINT,
    # SIGTERM or SIGABRT. This should be used most of the time, since
    # start_polling() is non-blocking and will stop the bot gracefully.
    updater.idle()

if __name__ == '__main__':
    main()

