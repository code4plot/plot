# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 14:07:16 2020

@author: mbijlkh
"""


from bs4 import BeautifulSoup
import urllib

#with open('https://www.propertyguru.com.sg/condo-directory/search-condo-project/1') as page:
 #   soup = BeautifulSoup(page, 'html.parser')
session = HTMLSession()

agent = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36'}
url = "https://www.propertyguru.com.sg/condo-directory/search-condo-project/1"

req = urllib.request.Request(url = url, headers = agent)
test = urllib.request.urlopen(req).read()
soup = BeautifulSoup(test, "html.parser")

projects = []
for i in soup.body.find_all(class_="nav-link"):
#    print(i.string)
    if i.string != None:
        projects += [i.string]
    #if i.has_attr('title'):
     #   count += 1