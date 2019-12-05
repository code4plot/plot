#!/bin/python

import argparse, sys, time
from ensemblGET import fetchEns
from bs4 import BeautifulSoup

def Ensembl2GeneSymbol(gene):
    """converts gene (NCBI GeneSymbol) to Ensembl Gene ID for a given species"""
    fetch = fetchEns("feature","id",gene,feature = "gene")
    time.sleep(1/3)
    soup = BeautifulSoup(fetch)
    data = soup.find(biotype = "protein_coding")
    return data["external_name"].encode()
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "converts Ensembl Gene ID to NCBI GeneSymbol")

    parser.add_argument("-f", nargs = 1, required = True, type = argparse.FileType("r"), help = "one Ensembl Gene ID per line")

    args = parser.parse_args()
    outFile = open(args.f.name + ".out","w")

    for i in args:
        gene = i.split()
        outFile.write(gene + "\t" + Ensembl2GeneSymbol(gene) + "\n")
    args.f.close()
    outFile.close()
    
