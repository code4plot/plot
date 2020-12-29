# -*- coding: utf-8 -*-
"""
Created on Mon Dec  7 18:17:30 2020

@author: mbijlkh
"""
import urllib, hashlib, requests

api_url = "https://cn-ezseller-openapi.ezbuy.sg/api/open/router"
app_key = "c4339c0730175faba1284b7acb24c9db"
app_secret = "45CAC98AF0F736A3AB2087CE26970674"

args = {"app_key":app_key,
    "method":"ezbuy.product.get",
    "sign_method":"md5",
    "timestamp":"2020-12-07 18:36:00",
    "version":"1.0",
    "product_id":"10096",
    "fields":"product_id,name,name_en,is_onsale"}

token = ""

for i in sorted(args.keys()):
    token += i + args[i]

token = urllib.parse.quote_plus(token)
#print(token)

token = app_secret + token + app_secret

sign = hashlib.md5(token.encode())  

args['sign'] = sign.hexdigest().upper()

url = api_url + "?" + urllib.parse.urlencode(args)

r = requests.get(url)

r.status_code

r.text
