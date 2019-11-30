#!/usr/bin/env python

import urllib,sys

inValues = open(sys.argv[1],'r')

inValues = inValues.readline().split()[0]

url="http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.xml?method=db2db&format=row&input=agilentid&inputValues=%s&outputs=genesymbol&taxonId=7955"%inValues

u = urllib.urlopen(url)

response = u.read()

outFile = open("retrieve.test",'w')
outFile.write(response)
