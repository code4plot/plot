rawDat <- read.table("data/zfish_expression.txt", header = T, sep = "\t", stringsAsFactors = F)
genes <- rawDat[,c(1,ncol(rawDat))]
rawDat <- rawDat[,-c(1,ncol(rawDat))]
stages <- read.table("data/sample-stage.txt", header = T, sep = "\t", stringsAsFactors = F)
stages <- stages$stage
colnames(rawDat)[-c(1,ncol(rawDat))] <- stages

saveRDS(rawDat,"data/rawDat3.RDS")
saveRDS(genes,"data/genes.RDS")

x <- 10
for(i in 1:ncol(rawDat)){
  temp <- rawDat[,i]
  temp <- temp[which(temp > 0)]
  x <- min(c(temp,x))
}
x

