rawDat = read.csv("rawDat_191028.csv", stringsAsFactors = F)

#subset condominiums only
condo = subset(rawDat, propertyType %in% c("Non-landed Properties","Executive Condominium"))

#remove rows with noOfBedRoom = NA
condo = subset(rawDat, noOfBedRoom != "NA")

#keep columns: project, areaSqft, leaseDate, district, noOfBedRoom, rent, psf
condo = condo[,c("project","areaSqft","leaseDate","district","noOfBedRoom","rent","psf")]

write.csv(condo, "rentalPlot/data/condo_191028.csv", row.names = F)
