## process_ura_data.R is a script to parse json-formatted file downloaded from URA

library(jsonlite)
library(plyr)

#parseLine converts the list object from read_json into a data.frame object
parseLine = function(theList) {
	results <- cbind(as.data.frame(theList[1:4]),
			as.data.frame(theList$rental[[1]])
			)
	n = length(theList$rental)
	if(n > 1){
		for(i in 2:n){
			results <- rbind.fill(results,
						cbind(as.data.frame(theList[1:4]),
							as.data.frame(theList$rental[[i]])
							)
						)
		}
	}
	return(results)
}

#binArea converts binned area to its midpoint
binArea = function(x){
	if(length(grep("-",x))){
		temp = unlist(strsplit(x,"-"))
		temp = as.numeric(temp)
		temp = (temp[1] + temp[2])/2
	} else {
		temp = gsub("[^0-9]","",x)
		temp = as.numeric(temp)
	}
	return(temp)
}

#assignQ assigns a given month, x, to its Quarter
assignQ = function(x){
	x = as.numeric(x)
	for(i in 1:4){
		if(x <= i*3 & x > (i-1)*3){
			result = paste("Q",as.character(i),sep="")
		}
	}
	return(result)
}


#parseDate takes mmyy date and returns yyQx, where x is the Quarter
parseDate = function(x, Quarter = T){
	x = as.character(x)
	temp = unlist(strsplit(x,""))
	if(length(temp) == 4){
		month = paste(temp[1],temp[2], sep = "")
		year = paste(temp[3],temp[4], sep = "")
	} else {
		month = temp[1]
		year = paste(temp[2],temp[3], sep = "")
	}
	if(Quarter == T){
	  Q = assignQ(month)
	  result = paste(year,Q, sep = "")
	} else {
	  result <- paste(year,month,sep = "/")
	}
	return(result)
}

#load .json file from URA
dat = read_json("ura_rent_191012.json",flatten=F)
dat = dat$Result

#initiate data.frame object
rawDat = data.frame(street = character(),
x = character(),
project = character(),
y = character(),
areaSqft = character(),
leaseDate = character(),
propertyType = character(),
district = character(),
noOfBedRoom = character(),
rent = character(),
stringsAsFactors = F)

#write dat into data.frame object
for(i in 1:length(dat)){
	if(length(dat[[i]]) == 5){
		rawDat = rbind.fill(rawDat,parseLine(dat[[i]]))
	}
}

#convert binned area (e.g. 300-400) to its midpoint (e.g. 350)
rawDat$areaSqft = unlist(lapply(rawDat$areaSqft, binArea))

#add $ psf column to rawDat
psf = as.numeric(rawDat$rent)/rawDat$areaSqft
rawDat = cbind(rawDat, psf = psf)

#assign leaseDate (mmyy) to quarters
rawDat$leaseDate = unlist(lapply(rawDat$leaseDate, parseDate))
#convert leaseDat (mmyy) to (yy/mm)
rawDat$leaseDate = unlist(lapply(rawDat$leaseDate, function(x) parseDate(x,F)))

saveRDS(rawDat,"rentalPlot/byDistrict/data/district.rds")


