library(jsonlite)
library(curl)

#read token
tok <- read_json("token.txt")

#get URA data

q <- "19q3" #which quarter to download
h <- new_handle()
handle_setheaders(h, "AccessKey" = "8da3d5f8-fa26-421a-95c5-58d2095cff84", "Token" = tok$Result)
t<- curl(url = paste("https://www.ura.gov.sg/uraDataService/invokeUraDS?service=PMI_Resi_Rental&refPeriod=",q, sep = "")
         , handle = h)
results <- readLines(t)

write(results, file = paste(q,".json", sep = ""))
