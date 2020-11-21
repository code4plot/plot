# -*- coding: utf-8 -*-
"""
Created on Tue Oct  6 16:44:00 2020

@author: mbijlkh
"""
import MySQLdb
from sqlalchemy import create_engine
import pandas as pd

def write_to_sql(user, pwd, host, port, schema, df, tbl, **kwargs ):
    engine = create_engine('mysql+mysqldb://%s:%s@%s:%s/%s?charset=utf8'%(user,pwd,host,port,schema), echo = False)
    df.to_sql(tbl, engine, **kwargs)
    engine.dispose()
    
def update_sql_table(user, pwd, host, port, schema, df, tbl, **kwargs ):
    engine = create_engine('mysql+mysqldb://%s:%s@%s:%s/%s?charset=utf8'%(user,pwd,host,port,schema), echo = False)
    df.to_sql('temp_table', engine, if_exists = 'replace', dtype = kwargs['dtype'])
    sql = "UPDATE %s a \
            INNER JOIN temp_table b \
            ON a.klid  = b.klid \
            SET %s"%(tbl,kwargs['set_statement'])
    with engine.begin() as conn:
        conn.execute(sql)
    engine.dispose()