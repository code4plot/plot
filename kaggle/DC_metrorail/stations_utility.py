# -*- coding: utf-8 -*-
"""
Created on Wed Oct 14 19:33:36 2020

@author: mbijlkh
"""
from collections import defaultdict
import pandas as pd

def getFootTraffic(df):
    """
    this method compiles the foot traffic
    of each station
    Takes in a pandas df
    Returns a pandas df with station names as index
    followed by respective foot count
    """
    footCount = defaultdict(int)
    for i in df.index:
        if df.enter[i] == df.exit[i]:
                footCount[df.enter[i]] += df.avgrider[i]
        else:
            footCount[df.enter[i]] += df.avgrider[i]
            footCount[df.exit[i]] += df.avgrider[i]
    footCount = pd.DataFrame.from_dict(footCount, orient = 'index', columns = ['rider'])
    return footCount
    
