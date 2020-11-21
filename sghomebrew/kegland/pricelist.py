# -*- coding: utf-8 -*-
"""
Created on Sat Oct 24 12:26:41 2020

@author: mbijlkh
"""


import pandas as pd
import codecs
from utils import config, pricelist_functions

def clean_currency(x, symbol = '$'):
    """x is a string
    replaces $ by default to blank
    also replaces ',' to blank
    """
    if isinstance(x, str):
        return(x.replace('$','').replace(',',''))
    return(x)


##load some parameters
#columns of prices
prices = ['largeprice','mediumprice','smallprice']
#input param
user = config.user
pwd = config.pwd
host = config.host
port = config.port
schema = 'kegland'
date = input('Enter Date (YYYYMMDD): ')
fileName = 'pricelist201021.csv'

#read pricelist
doc = codecs.open(fileName, 'r', 'cp437')
df = pd.read_csv(doc)
df = df.iloc[:,:8] #only keep the first 8 columns
df.columns = ['klid','name','unitspercarton','mediumqty','largeqty'] + prices #rename columns
df.dropna(subset = prices + ['klid'], inplace = True) #drop rows with no prices
#convert currency to float
for i in prices:
    df[i] = df[i].apply(clean_currency).astype(float)
#converty qty to int
for i in ['mediumqty','largeqty']:
    df[i] = df[i].apply(clean_currency).astype(int)
df = df.astype({'klid':str,'name':str,'mediumqty':int,'largeqty':int}) #assign dtypes
df.set_index('klid', inplace = True)

carton_df = df.loc[:,['unitspercarton']] #carton information dealt separately
catalog_df = df.loc[:,['name']] #catalog df
price_df = df.drop(columns = ['name','unitspercarton']) #catalog pricing
    
pricelist_functions.pricetable(price_df, date, user = user, pwd = pwd, host = host, port = port, schema = schema)
pricelist_functions.cattable(catalog_df, user = user, pwd = pwd, host = host, port = port, schema = schema)
pricelist_functions.cartonboxtable(carton_df, user = user, pwd = pwd, host = host, port = port, schema = schema)
