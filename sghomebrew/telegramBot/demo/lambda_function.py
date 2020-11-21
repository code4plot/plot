# -*- coding: utf-8 -*-
"""
Created on Sat Nov 21 14:41:57 2020

@author: mbijlkh
"""


import json
import telegram
import logging
from telegram.ext import Dispatcher, CommandHandler, MessageHandler, Filters

# Logging is cool!
logger = logging.getLogger()
if logger.handlers:
    for handler in logger.handlers:
        logger.removeHandler(handler)
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

OK_RESPONSE = {
    'statusCode': 200,
    'headers': {'Content-Type': 'application/json'},
    'body': json.dumps('ok')
}
ERROR_RESPONSE = {
    'statusCode': 400,
    'body': json.dumps('Oops, something went wrong!')
}

def start(update, context):
    context.bot.send_message(chat_id = update.message.chat_id, text = "I'm a test bot. Neat!")

def echo(update, context):
    update.message.reply_text(update.message.text)


def setup(token):
    # Create bot, update queue and dispatcher instances
    bot = telegram.Bot(token)
    dispatcher = Dispatcher(bot, None, workers=0)
    
    ##### Register handlers here #####
    dispatcher.add_handler(CommandHandler('start',start))
    dispatcher.add_handler(MessageHandler(Filters.text & ~Filters.command, echo))
    
    return dispatcher, bot

def lambda_handler(event, context):
    # TODO implement
    if event.get('httpMethod') == 'POST' and event.get('body'): 
        logger.info('Message received')
        TOKEN = 'YOUR BOT TOKEN HERE'
        dispatcher, bot = setup(TOKEN)
        update = telegram.Update.de_json(json.loads(event.get('body')), bot)
        dispatcher.process_update(update)
        logger.info('Message sent')
        return OK_RESPONSE
    return ERROR_RESPONSE
