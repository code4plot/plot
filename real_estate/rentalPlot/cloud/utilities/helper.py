# -*- coding: utf-8 -*-
"""
Created on Tue Oct  6 16:44:00 2020

@author: mbijlkh
"""
import MySQLdb
from sqlalchemy import create_engine
import pandas as pd

def write_to_sql(user, pwd, host, port, schema, df, tbl, **kwargs ):
    user = user
    pwd = pwd
    host = host
    port = port
    schema = schema
    engine = create_engine('mysql+mysqldb://%s:%s@%s:%s/%s'%(user,pwd,host,port,schema), echo = False)
    df.to_sql(tbl, engine, **kwargs)
    engine.dispose()