# -*- coding: utf-8 -*-
"""
Created on Thu Oct 22 10:54:33 2020

@author: mbijlkh
"""


import pandas as pd
import codecs

doc = codecs.open('dimension201021.csv', 'r', 'cp437')
df = pd.read_csv(doc)

df.columns

df = df.iloc[:,:10]
df.columns = ['klid','name','moq','unitspercarton','size','l','w','h','volume','gw']
df = df.drop_duplicates().iloc[:-1,:]
df.unitspercarton = df.unitspercarton.astype('str')

df.unitspercarton = df.unitspercarton.str.replace(r'[^0-9]+',"")

df.loc[df.unitspercarton == '','unitspercarton'] = df[df.unitspercarton == ''].unitspercarton.str.replace('','1')
df.unitspercarton = df.unitspercarton.astype('int')
df.to_csv('dimension201021.csv', index = False)
