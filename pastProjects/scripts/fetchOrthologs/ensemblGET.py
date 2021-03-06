#!/bin/python

"""This script fetches data from ensembl REST request"""

import argparse,httplib2,sys,bs4

def fetchEns(endpoint,subendpoint,*args,**kwargs):
    """
    fetches Ensembl REST
    """
    http = httplib2.Http(".cache")
    server = "http://beta.rest.ensembl.org/"
    ext = "/" + "/".join([endpoint,subendpoint] + list(args)) + "?"
    if len(kwargs) != 0:
        for k,v in kwargs.items():
            if type(v) == list or type(v) == tuple:
                for vi in v:
                    ext = ext + "=".join([k,vi]) + ";"
            else:
                for vi in v.split(","):
                    ext = ext + "=".join([k,vi]) + ";"
    ext = ext + "content-type=text/xml"
    resp, xml_content = http.request(server+ext, method="GET")
    if not resp.status == 200:
        print "Invalid response: ", resp.status
        sys.exit()
    return xml_content

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "python script to fetch data from ensembl REST")

    parser.add_argument("-e", "--endpoint", type = str, nargs = 1, required = True, choices = ['archive','alignment','genetree','homology','xrefs','feature','assembly','info','lookup','map','ontology','taxonomy','sequence','vep'],help = 'choose endpoint data to fetch')
    parser.add_argument("-s", "--subendpoint", type = str, nargs = 1, required = True, choices = ['id','region','info','analysis'], help = "choose subendpoint data to fetch")
    parser.add_argument("-S", "--Species", type = str, nargs = 1, choices = ['human','zebrafish'], help = "choose species. Required in some endpoint queries.")
    parser.add_argument("-r", "--region", type = str, nargs = 1, help = "select genomic region to query in this format [X:1-1000 | X:1-1000:1 | X:1-1000:-1]. required in some endpoint queries.")
    parser.add_argument("-o", "--other", type = str, nargs = 1, help = "additional parameters for 'feature' subendpoint. If using -s feature, this parameter must be present. comma-delimited string")


    args = parser.parse_args()

    def misOptArgs(arg):
        """handles missing optional arguments
        if arg is missing, return None
        """
        try:
            return arg[:]
        except TypeError:
            return None

    e = args.endpoint[0]
    s = args.subendpoint[0]
    S = args.Species[0]
    r = args.region[0]
    o = "feature=" + args.other[0].replace(",",";feature=")


 
