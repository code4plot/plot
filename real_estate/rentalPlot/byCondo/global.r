#load raw data
rawDat = "data/rawDat_191028.csv"
rawDat = read.csv(rawDat, stringsAsFactors = F)

#subset to analyze condominiums and executive condominiums
condo = subset(rawDat, propertyType %in% c("Non-landed Properties", "Executive Condominium"))