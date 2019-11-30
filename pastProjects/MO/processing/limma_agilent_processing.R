#!/user/bin/env Rscripts


library(limma)

##dual-channel
dual = function(path,targetFile, spotTypesFile,source = "agilent",GSE){
setwd(path)
targets = readTargets(targetFile)
x = read.maimages(targets, source = source)
for(i in colnames(x$R)){
x$R[,i] = sub(",",".",x$R[,i])
x$Rb[,i] = sub(",",".",x$Rb[,i])
x$G[,i] = sub(",",".",x$G[,i])
x$Gb[,i] = sub(",",".",x$Gb[,i])
}
x$R = apply(x$R,2,as.numeric)
x$Rb = apply(x$Rb,2,as.numeric)
x$G = apply(x$G,2,as.numeric)
x$Gb = apply(x$Gb,2,as.numeric)
spottypes = readSpotTypes(spotTypesFile)
x$genes$Status = controlStatus(spottypes,x)
x_bg = backgroundCorrect(x,method = "normexp", offset = 50)
MA = normalizeWithinArrays(x_bg,method = "loess")
##note
##M = log2(R/G)
##A = log2(R*G)/2
##R = cy5
##G = cy3
#########
pdf(paste(GSE,"_QC.plots.pdf",sep = ""))
for(i in 1:nrow(x$targets)){
plotMA(x, array = i)
plotMA(x_bg, array = i)
plotMA(MA, array = i)
}
BA = normalizeBetweenArrays(MA, method = "Aquantile")
plotDensities(BA)
dev.off()
colnames(BA$M) = BA$targets$Name
if(source == "genepix"){
outPut = data.frame(probe = BA$genes$ID, status = BA$genes$Status, BA$M)
write.table(outPut, file = paste(GSE,"_processed_M.txt",sep = ""), row.names = F, quote = FALSE, sep = "\t")
outPut = data.frame(probe = BA$genes$ID, status = BA$genes$Status, BA$A)
write.table(outPut, file = paste(GSE,"_processed_A.txt",sep = ""), row.names = F, quote = FALSE, sep = "\t")
} else {
outPut = data.frame(probe = BA$genes$ProbeName, status = BA$genes$Status, BA$M)
write.table(outPut, file = paste(GSE,"_processed_M.txt",sep = ""), row.names = F, quote = FALSE, sep = "\t")
outPut = data.frame(probe = BA$genes$ProbeName, status = BA$genes$Status, BA$A)
write.table(outPut, file = paste(GSE,"_processed_A.txt",sep = ""), row.names = F, quote = FALSE, sep = "\t")
}
save(x,x_bg,MA,BA,list = c("x","x_bg","MA","BA"),file =  paste(GSE,"_processed.RData",sep = ""))
}

###
# ‘normalizeBetweenArrays’ normalizes expression values to achieve
#     consistency between arrays. For two-color arrays, normalization
#     between arrays is usually a follow-up step after normalization
#     within arrays using ‘normalizeWithinArrays’. For single-channel
#     arrays, within array normalization is not usually relevant and so
#     ‘normalizeBetweenArrays’ is the sole normalization step.
###

##single-channel
single = function(path,targetFile,GSE){
setwd(path)
targets = readTargets(targetFile)
x = read.maimages(targets, source = "agilent", green.only = T)
x_bg = backgroundCorrect(x,method = "normexp", offset = 50)
BA = normalizeBetweenArrays(x_bg,method = "quantile")
pdf(paste(GSE,"_QC.plots.pdf",sep = ""))
plotDensities(x)
plotDensities(x_bg)
plotDensities(BA)
dev.off()
colnames(BA$E) = BA$targets$Name
outPut = data.frame(probe = BA$genes$ProbeName, status = BA$genes$ControlType, BA$E)
write.table(outPut, file = paste(GSE,"_processed.txt",sep = ""), row.names = F, quote = FALSE, sep = "\t")
save(x,x_bg,BA,list = c("x","x_bg","BA"),file =  paste(GSE,"_processed.RData",sep = ""))
}


#####
#linear model fitting and generating 95%CI
#########

#dual-channel

design = modelMatrix(x$targets, ref = "WT")
fit = lmFit(BA, design)
contrast.matrix = makeContrasts(MO1-WT,MO2-WT, levels = design) #if needed
fit2 = contrasts.fit(fit,contrast.matrix) #if needed
fit3 = eBayes(fit2)
topGenes = topTable(fit3, coef = 1, number = nrow(fit3$genes), confint = T)
isg = read.table("../isgProbes.txt", header = F)
ifn = read.table("../ifnProbes.txt",header = F)
write.table(topGenes[topGenes$ProbeName %in% isg$V2,], file = "", sep = "\t", quote = F, row.names = F)
write.table(topGenes[topGenes$ProbeName %in% ifn$V2,], file = "", sep = "\t", quote = F, row.names = F)

#single-channel
Group = factor(x$targets$Cy3)
design = model.matrix(~0+Group)
colnames(design) = c("WT","MO")
fit = lmFit(BA,design)
contrast.matrix = makeContrasts(MO-WT,levels = design)
fit2 = contrasts.fit(fit,contrast.matrix)
fit3 = eBayes(fit2)
topGenes = topTable(fit3,coef=1, number = nrow(fit3$genes), confint = T)
isg = read.table("../isgProbes.txt", header = F)
ifn = read.table("../ifnProbes.txt", header = F)
write.table(topGenes[topGenes$ProbeName %in% isg$V2,], sep = "\t", quote = F, row.names = F, file = "")
write.table(topGenes[topGenes$ProbeName %in% ifn$V2,], file = "", sep = "\t", quote = F, row.names = F)


####
#meta-analysis
###

#read all files into a list
isgFiles = read.table("isgFiles", header = F)
data_list_isg = lapply(as.character(isgFiles$V1), read.table, sep = "\t", header = T, quote = "")
isgProbes = read.table("isgProbes.txt", header = F)


#we take the maximum absolute(logFC)
isg15_probes = isgProbes$V2[isgProbes$V1 == "isg15"]

isg15_FC = c()
isg15_low = c()
isg15_high = c()
isg15_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% isg15_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
isg15_FC =  append(isg15_FC,temp)
isg15_low = append(isg15_low,tempVec$CI.L[tempInd])
isg15_high = append(isg15_high,tempVec$CI.R[tempInd])
isg15_p = append(isg15_p, tempVec$adj.P.Val[tempInd])
}


isg20_probes = isgProbes$V2[isgProbes$V1 == "isg20"]


isg20_FC = c()
isg20_low = c()
isg20_high = c()
isg20_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% isg20_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
isg20_FC =  append(isg20_FC,temp)
isg20_low = append(isg20_low,tempVec$CI.L[tempInd])
isg20_high = append(isg20_high,tempVec$CI.R[tempInd])
isg20_p = append(isg20_p, tempVec$adj.P.Val[tempInd])
}

tp53_probes = isgProbes$V2[isgProbes$V1 == "tp53"]


tp53_FC = c()
tp53_low = c()
tp53_high = c()
tp53_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% tp53_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
tp53_FC =  append(tp53_FC,temp)
tp53_low = append(tp53_low,tempVec$CI.L[tempInd])
tp53_high = append(tp53_high,tempVec$CI.R[tempInd])
tp53_p = append(tp53_p, tempVec$adj.P.Val[tempInd])
}

casp8_probes = isgProbes$V2[isgProbes$V1 == "casp8"]


casp8_FC = c()
casp8_low = c()
casp8_high = c()
casp8_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% casp8_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
casp8_FC =  append(casp8_FC,temp)
casp8_low = append(casp8_low,tempVec$CI.L[tempInd])
casp8_high = append(casp8_high,tempVec$CI.R[tempInd])
casp8_p = append(casp8_p, tempVec$adj.P.Val[tempInd])
}

gadd45aa_probes = isgProbes$V2[isgProbes$V1 == "gadd45aa"]


gadd45aa_FC = c()
gadd45aa_low = c()
gadd45aa_high = c()
gadd45aa_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% gadd45aa_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
gadd45aa_FC =  append(gadd45aa_FC,temp)
gadd45aa_low = append(gadd45aa_low,tempVec$CI.L[tempInd])
gadd45aa_high = append(gadd45aa_high,tempVec$CI.R[tempInd])
gadd45aa_p = append(gadd45aa_p, tempVec$adj.P.Val[tempInd])
}

phlda3_probes = isgProbes$V2[isgProbes$V1 == "phlda3"]


phlda3_FC = c()
phlda3_low = c()
phlda3_high = c()
phlda3_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% phlda3_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
phlda3_FC =  append(phlda3_FC,temp)
phlda3_low = append(phlda3_low,tempVec$CI.L[tempInd])
phlda3_high = append(phlda3_high,tempVec$CI.R[tempInd])
phlda3_p = append(phlda3_p, tempVec$adj.P.Val[tempInd])
}

mdm2_probes = isgProbes$V2[isgProbes$V1 == "mdm2"]


mdm2_FC = c()
mdm2_low = c()
mdm2_high = c()
mdm2_p = c()
for(i in 1:length(data_list_isg)){
rows = data_list_isg[[i]][,"ProbeName"] %in% mdm2_probes
tempVec = data_list_isg[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
mdm2_FC =  append(mdm2_FC,temp)
mdm2_low = append(mdm2_low,tempVec$CI.L[tempInd])
mdm2_high = append(mdm2_high,tempVec$CI.R[tempInd])
mdm2_p = append(mdm2_p, tempVec$adj.P.Val[tempInd])
}


###IFN
ifnFiles = read.table("ifnFiles",header = F)
data_list_ifn = lapply(as.character(ifnFiles$V1), read.table, sep = "\t", header = T, quote = "")
ifnProbes = read.table("ifnProbes.txt", header = F)

ifnphi1_probes = ifnProbes$V2[ifnProbes$V1 == "ifnphi1"]


ifnphi1_FC = c()
ifnphi1_low = c()
ifnphi1_high = c()
ifnphi1_p = c()
for(i in 1:length(data_list_ifn)){
rows = data_list_ifn[[i]][,"ProbeName"] %in% ifnphi1_probes
tempVec = data_list_ifn[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
ifnphi1_FC =  append(ifnphi1_FC,temp)
ifnphi1_low = append(ifnphi1_low,tempVec$CI.L[tempInd])
ifnphi1_high = append(ifnphi1_high,tempVec$CI.R[tempInd])
ifnphi1_p = append(ifnphi1_p, tempVec$adj.P.Val[tempInd])
}


ifnphi3_probes = ifnProbes$V2[ifnProbes$V1 == "ifnphi3"]


ifnphi3_FC = c()
ifnphi3_low = c()
ifnphi3_high = c()
ifnphi3_p = c()
for(i in 1:length(data_list_ifn)){
rows = data_list_ifn[[i]][,"ProbeName"] %in% ifnphi3_probes
if(sum(rows) == 0){
ifnphi3_FC = append(ifnphi3_FC,NA)
ifnphi3_low = append(ifnphi3_low,NA)
ifnphi3_high = append(ifnphi3_high,NA)
ifnphi3_p = append(ifnphi3_p,NA)
} else {
tempVec = data_list_ifn[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
ifnphi3_FC =  append(ifnphi3_FC,temp)
ifnphi3_low = append(ifnphi3_low,tempVec$CI.L[tempInd])
ifnphi3_high = append(ifnphi3_high,tempVec$CI.R[tempInd])
ifnphi3_p = append(ifnphi3_p, tempVec$adj.P.Val[tempInd])
}
}

ifng1_1_probes = ifnProbes$V2[ifnProbes$V1 == "ifng1-1"]


ifng1_1_FC = c()
ifng1_1_low = c()
ifng1_1_high = c()
ifng1_1_p = c()
for(i in 1:length(data_list_ifn)){
rows = data_list_ifn[[i]][,"ProbeName"] %in% ifng1_1_probes
if(sum(rows) == 0){
ifng1_1_FC = append(ifng1_1_FC,NA)
ifng1_1_low = append(ifng1_1_low,NA)
ifng1_1_high = append(ifng1_1_high,NA)
ifng1_1_p = append(ifng1_1_p,NA)
} else {
tempVec = data_list_ifn[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
ifng1_1_FC =  append(ifng1_1_FC,temp)
ifng1_1_low = append(ifng1_1_low,tempVec$CI.L[tempInd])
ifng1_1_high = append(ifng1_1_high,tempVec$CI.R[tempInd])
ifng1_1_p = append(ifng1_1_p, tempVec$adj.P.Val[tempInd])
}
}

ifng1_2_probes = ifnProbes$V2[ifnProbes$V1 == "ifng1-2"]


ifng1_2_FC = c()
ifng1_2_low = c()
ifng1_2_high = c()
ifng1_2_p = c()
for(i in 1:length(data_list_ifn)){
rows = data_list_ifn[[i]][,"ProbeName"] %in% ifng1_2_probes
tempVec = data_list_ifn[[i]][rows,c("logFC","CI.L","CI.R","adj.P.Val")]
maxVec = max(abs(tempVec$logFC))
tempInd = abs(tempVec$logFC) %in% maxVec
temp = tempVec$logFC[tempInd]
ifng1_2_FC =  append(ifng1_2_FC,temp)
ifng1_2_low = append(ifng1_2_low,tempVec$CI.L[tempInd])
ifng1_2_high = append(ifng1_2_high,tempVec$CI.R[tempInd])
ifng1_2_p = append(ifng1_2_p, tempVec$adj.P.Val[tempInd])
}


