#!/bin/python

"""annotates bed regions with ensembl gene"""

import argparse, sys, ensemblGET, time
from bs4 import BeautifulSoup
from collections import defaultdict

parser = argparse.ArgumentParser(description = "annotates bed regions with ensembl gene")

parser.add_argument("-f", nargs = "?", type = argparse.FileType('r'), required = True, help = "input file with BED-format coordinate, ie X:1-1000")

args = parser.parse_args()
outFile = args.f.name
outFile = open(outFile + ".out", 'w')

n=0
for i in args.f:
    dict = defaultdict(list)
    e = "feature"
    s = "region"
    S = "zebrafish"
    r = i.split()[0]
    o = ["gene",]
    out = ensemblGET.fetchEns(e,s,S,r,feature=o)
    soup = BeautifulSoup(out)
    for j in soup.find_all("data"):
        if j["biotype"] == "protein_coding":
            keyList = list(k.encode() for k in j.attrs.keys())
            for k in j.attrs.keys():
                if j[k] not in dict[k.encode()]:
                    dict[k.encode()].append(j[k])
    if n == 0:
        outFile.write("\t".join(["#region",] + keyList + ["total_entries",]) + "\n")
        n += 1
    writeList = []
    for j in keyList:
        writeList.append(";".join(dict[j]).encode())
    outFile.write("\t".join([r,] + writeList) + "\t%d"%(len(dict["external_name"])) +  "\n")
    time.sleep(1/3)


        
    

