# -*- coding: utf-8 -*-
"""
Created on Sat Oct 24 15:16:59 2020

@author: mbijlkh
"""

from utils import helper
from sqlalchemy.types import VARCHAR
import pandas as pd
from collections import defaultdict

def pricetable(x, date, **kwargs):
    """takes in processed pricelist, x, a pandas df
    and upload to SQL DB
    date will record date of entry in %Y%m%d format
    kwargs to """
    x['date'] = pd.to_datetime(date, format = '%Y%m%d')
    key_length = x.index.get_level_values('klid').str.len().max()
    helper.write_to_sql(**kwargs, df = x, tbl = 'pricetable', if_exists = 'append', dtype = {'klid':VARCHAR(key_length)})

def cattable(x, **kwargs):
    """
    takes in catalog_df, x, a pandas df
    and upload to SQL DB
    discontinued items will go to discont_table
    """
    discont_df = x[x.name.str.contains('discontinued', case = False)]
    avail_df = x[~x.index.isin(discont_df.index)]
    key_length = x.index.get_level_values('klid').str.len().max()
    try:
        helper.write_to_sql(**kwargs, #authentication parameters
                            df = discont_df, tbl = 'discontinued', #from df to table
                            if_exists = 'fail', dtype = {'klid':VARCHAR(key_length)}) #other params
    except:
        helper.update_sql_table(**kwargs,
                                df = discont_df, tbl = 'discontinued',
                                dtype = {'klid':VARCHAR(key_length)},
                                set_statement = 'a.name = b.name')
    try:
        helper.write_to_sql(**kwargs, #authentication parameters
                            df = avail_df, tbl = 'catalog', #from df to table
                            if_exists = 'fail', dtype = {'klid':VARCHAR(key_length)}) #other params
    except:
        helper.update_sql_table(**kwargs,
                                df = avail_df, tbl = 'catalog',
                                dtype = {'klid':VARCHAR(key_length)},
                                set_statement = 'a.name = b.name')

def cartonboxtable(x, **kwargs):
    """
    takes in carton_df, x, a pandas df
    and upload to SQL DB

    Parameters
    ----------
    x : pandas df
        carton_df about number of items per carton/box
    **kwargs : kwargs
        authentication param for SQL DB

    Returns
    -------
    None.

    """
    x.unitspercarton = x.unitspercarton.str.replace('nan','1')
    x.unitspercarton = x.unitspercarton.fillna('1')
    x.unitspercarton = x.unitspercarton.astype(str)
    cartonbox = defaultdict(list)
    for i in range(len(x)):
        temp = x.unitspercarton[i].split('/')
        if len(temp) == 1:
            cartonbox['carton'].append(temp[0])
            cartonbox['box'].append(temp[0])
        else:
            cartonbox['carton'].append(temp[0])
            cartonbox['box'].append(temp[1])
    cartonbox_df = pd.DataFrame(cartonbox, index = x.index)
    key_length = x.index.get_level_values('klid').str.len().max()
    try:
        helper.write_to_sql(**kwargs, #authentication parameters
                            df = cartonbox_df, tbl = 'cartonbox', #from df to table
                            if_exists = 'fail', dtype = {'klid':VARCHAR(key_length)}) #other params
    except:
        helper.update_sql_table(**kwargs,
                                df = cartonbox_df, tbl = 'cartonbox',
                                dtype = {'klid':VARCHAR(key_length)},
                                set_statement = 'a.carton = b.carton,\
                                a.box = b.box')
    