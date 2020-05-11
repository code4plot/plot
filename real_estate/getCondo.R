rawDat = readRDS("rawDat_19q4.rds")

#subset condominiums only
condo = subset(rawDat, propertyType %in% c("Non-landed Properties","Executive Condominium"))

#remove rows with noOfBedRoom = NA
condo = subset(rawDat, noOfBedRoom != "NA")

#keep columns: project, areaSqft, leaseDate, district, noOfBedRoom, rent, psf
condo = condo[,c("project","areaSqft","leaseDate","district","noOfBedRoom","rent","psf")]
condo$rent <- as.numeric(condo$rent)
saveRDS(condo, "rentalPlot/byCondo/data/condo.rds")

condo = condo[,c("areaSqft","leaseDate","district","noOfBedRoom","rent","psf")]
saveRDS(condo, "rentalPlot/byDistrict/data/district.rds")
