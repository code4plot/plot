# -*- coding: utf-8 -*-
"""
Created on Tue Nov  3 10:52:43 2020

@author: mbijlkh
"""


import pandas as pd
import glob
import matplotlib.pyplot as plt 
import numpy as np

def clean_currency(x, symbol = '$'):
    """x is a string
    replaces $ by default to blank
    also replaces ',' to blank
    """
    if isinstance(x, str):
        return(x.replace('$','').replace(',',''))
    return(x)

def abline(slope, intercept, ax = plt.gca()):
    """Plot a line from slope and intercept"""
    axes = ax
    x_vals = np.array(axes.get_xlim())
    y_vals = intercept + slope * x_vals
    plt.plot(x_vals, y_vals, '--')

fileList = glob.glob("./201102*.xlsx")

df = pd.concat((pd.read_excel(f) for f in fileList))

df.head()
df.SKU = df.SKU.apply(lambda x: x.split(",")[0])
df.SKU = df.SKU.str.replace(" ","")
df.to_csv("201102.csv", index = False)

df2 = pd.read_csv("./KLorder2.csv")
df2 = df2[df2["SUM of Qty"] != 0]

df2.unitprice = df2.unitprice.apply(clean_currency)



df2 = df2.astype({'unitprice':float})
df2["shipping"] = df2.unitprice * 0.2
df2 = df2.rename(columns = {"SKU#":"SKU"})


df3 = pd.merge(df, df2, how = 'inner', on = "SKU")

df3.columns
df3.plot.scatter(x='unitprice', y='cost')
fig, ax = plt.subplots()
ax.scatter(x = df3.unitprice, y = df3.cost)
plt.scatter(x = df3.unitprice, y = df3.cost)
xvals = np.array(max(df3.unitprice, df3.cost))
yvals = xvals
plt.plot(xvals, yvals, '--')
abline(1,0, ax = ax)
plt.show()

len(df3)
