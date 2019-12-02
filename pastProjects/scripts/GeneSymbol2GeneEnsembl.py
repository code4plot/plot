#!/bin/python

import argparse, sys, time
from ensemblGET import fetchEns
from bs4 import BeautifulSoup

def GeneSymbol2Ensembl(gene, species):
    """converts gene (NCBI GeneSymbol) to Ensembl Gene ID for a given species"""
    fetch = fetchEns("lookup","symbol",species,gene,expand = "0")
    time.sleep(1/3)
    soup = BeautifulSoup(fetch)
    data = soup.find(biotype = "protein_coding")
    return data["id"].encode()
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "converts NCBI GeneSymbol to Ensemble Gene ID.")

    parser.add_argument("-f", nargs = 1, required = True, type = argparse.FileType("r"), help = "one GeneSymbol per line")
    parser.add_argument("-s", nargs = 1, required = True, type = str, help = "Ensembl taxon ID.")

    args = parser.parse_args()

    sp = args.s[0]
    outFile = open(args.f.name + ".out","w")

    for i in args:
        gene = i.split()
        outFile.write(gene + "\t" + GeneSymbol2Ensembl(gene,sp) + "\n")
    args.f.close()
    outFile.close()
    
