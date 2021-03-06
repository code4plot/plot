#!/bin/python

import argparse, time, sys, os
from ensemblGET import fetchEns
from bs4 import BeautifulSoup
from collections import defaultdict
from GeneSymbol2GeneEnsembl import GeneSymbol2Ensembl
from EnsemblGene2GeneSymbol import Ensembl2GeneSymbol

parser = argparse.ArgumentParser(description = "searches Ensembl database for ortholog gene names")

parser.add_argument("-f", nargs = 1, required = True, type = argparse.FileType('r'), help = "input file. one line per NCBI Gene Symbol")
parser.add_argument("-db", nargs = 1, required = True, type = argparse.FileType('r'), help = "ortholog database downloaded from Ensembl BioMart. The header should contain the following fields in order: query_species_ensemblGeneID, target_species1_ensemblGeneID, target_species1_orthologConfidence, target_species2_ensemblGeneID, target_species2_orthologConfidence,...")
parser.add_argument("-qs", nargs = 1, required = True, type = str, help = "query species. List of valid strings can be found http://www.ensembl.org/info/about/species.html")
parser.add_argument("-ts", nargs = 1, required = True, type = str, help = "list of target species to lookup and fetch relevant orthologous gene names. comma-delimited. Please arrange in same order as dbFile fields.")

args = parser.parse_args()

inFile = args.f[0]
dbFile = args.db[0]
outFile = open(inFile.name + ".out", "w")
qs = args.qs[0]
ts = args.ts[0].split(",")

class TaxonIDError(Exception):
    """raised when input qs and ts are not ensembl-specified taxon ID"""

header = 1
for i in inFile:
    gene = i.split()[0]
    EnGene = GeneSymbol2Ensembl(gene,qs)
    tempFileName = "%s.tmp"%inFile.name
    os.system("grep -w \"%s\" %s > %s"%(EnGene, dbFile.name, tempFileName))
    dict = defaultdict(list)
    tempFile = open(tempFileName,'r')
    for j in tempFile:
        line = j.rstrip("\n").split("\t")
        n = 1
        for k in ts:
            if line[n+1] == "1":
                if line[n] not in dict[k]:
                    dict[k].append(line[n])
            n += 2
    tempFile.close()
    result = defaultdict(list)
    for j in dict.keys():
        for k in dict[j]:
            result[j].append(Ensembl2GeneSymbol(k))
    if header == 1:
        outFile.write("#" + qs + "\t" + "\t".join(ts) + "\n")
        header = 0
    outFile.write(gene)
    for j in ts:
        outFile.write("\t" + ";".join(result[j]))
    outFile.write("\n")

os.system("rm %s"%tempFileName)
inFile.close()
outFile.close()

    
            
    
