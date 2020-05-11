
inputFile <- "19q4.rds"
oldFile <- "rawDat_19q3.rds"
outRawDat <- readRDS(oldFile)
newDat <- readRDS(inputFile)

outRawDat <- rbind(outRawDat,newDat)

saveRDS(outRawDat, paste("rawDat_",inputFile,sep = ""))
