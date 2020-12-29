# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 14:07:16 2020

@author: mbijlkh
"""


from bs4 import BeautifulSoup
import urllib

#with open('https://www.propertyguru.com.sg/condo-directory/search-condo-project/1') as page:
 #   soup = BeautifulSoup(page, 'html.parser')
class AppURLopener(urllib.request.FancyURLopener):
    version = "Mozilla/5.0"

opener = AppURLopener()
response = opener.retrieve(url, filename='tmp')
open('tmp').read()

agent = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:77.0) Gecko/20100101 Firefox/77.0'}
url = "https://www.propertyguru.com.sg/condo-directory/search-condo-project"

req = urllib.request.Request(url = url, headers = agent)
req = urllib.request.Request(url = url)
test = urllib.request.urlopen(req).read()
soup = BeautifulSoup(test, "html.parser")

projects = []
for i in soup.body.find_all(class_="nav-link"):
#    print(i.string)
    if i.string != None:
        projects += [i.string]
    #if i.has_attr('title'):
     #   count += 1
        