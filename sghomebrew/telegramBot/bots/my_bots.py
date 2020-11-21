# -*- coding: utf-8 -*-
"""
Created on Thu Nov 19 17:35:22 2020

@author: mbijlkh
"""
from collections import defaultdict
import pickle

class my_bots():
    """
    class to handle my telegram
    bots's access keys
    """
    def __init__(self):
        try:
            bot_file = open('bots.pkl', "rb")
            self.bots = pickle.load(bot_file)
            bot_file.close()
        except:
            self.bots = defaultdict(str)
    def get_bot_key(self, botname):
        """
        
        Parameters
        ----------
        botname : str
            name of bot to retrieve key

        Returns
        -------
        str
            key

        """
        return self.bots[botname]
    def update_bots(self, name, key):
        """
        
        Parameters
        ----------
        name : str
            name of new bot
        key : str
            key

        Returns
        -------
        None.

        """
        self.bots[name] = key
        self.update_bot_file()
    
    def update_bot_file(self):
        """
        writes bots dictionary to file
        """
        bot_file = open('bots.pkl', "wb")
        pickle.dump(self.bots, bot_file)
        bot_file.close()
            
            