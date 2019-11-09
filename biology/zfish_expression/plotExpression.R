library(ggplot2)
library(plyr)

#load genes file
gfile = read.table("data/zfish_genes.txt", header = T, sep = "\t", stringsAsFactors = F)

#load sample-stage file
stages = read.table("data/sample-stage.txt", header = T, sep = "\t", stringsAsFactors = F)
stages = c("gene_id", stages$stage, "gene_name")

#some example
ensemblExamples = c("ENSDARG00000068401","ENSDARG00000067719","ENSDARG00000042934","ENSDARG00000023062","ENSDARG00000077860","ENSDARG00000068409")

#load data from files
toPlot = subset(gfile, gene_id %in% ensemblExamples)
plotDat = getData(toPlot)
plotDat = subset(rawDat, gene_id %in% ensemblExamples)
#cleanup column names
plotDat = rename(plotDat, replace = stages)
#take a row median (as reference point, if not using absolute value)
temp_ind = 2:(ncol(plotDat)-1)
temp_df = plotDat[,temp_ind]
plotDat[,temp_ind] = rowRelative(temp_df,"median",T)

#make datapoints relative to zygote
plotDat[,temp_ind] = rowRelative(temp_df,"zygote", T)

plotDat = makeExpressionDF(plotDat)

s = ggplot(plotDat, aes(x = stage, y = reads, color = gene_name, group = gene_name)) +
  geom_line(size = 1.2) +
  labs(y = "log-scaled relative expression", x = "developmental stage", color = "gene") +
  ggtitle("Relative (median) gene expression") +
  theme_bw() +
  theme(plot.title = element_text(size = 15, hjust = 0.5), 
        axis.text.x = element_text(angle = 30, hjust = 1, size = 12))
s

rowMedian = function(df){
  df = apply(df, 1, median)
  return(df)
}

rowRelative = function(df, ref, logScale = F){
  if(tolower(ref) == "median"){
    x = rowMedian(df)
  } else {
    x = df[,ref]
    x[which(x == 0)] = 0.001
  }
  df = df/x
  if(logScale == T){
    df = log(df,2)
  }
  return(df)
}

makeExpressionDF = function(df){
  temp = stack(df, select = -c(gene_name, gene_id))
  times = nrow(temp)/nrow(df)
  result = data.frame(gene_id = rep(plotDat$gene_id, times), gene_name = rep(plotDat$gene_name, times), 
                      reads = temp$values, stage = temp$ind, stringsAsFactors = F)
  return(result)
}

getData = function(x, suf = "zfish_", ext = ".txt", fromDir = "data/", id = "gene_id"){
  if(id == "gene_id"){
    y = 1
  } else {
    y = 2
  }
  ind = unique(x$fileIndex)
  for(i in ind){
    genes = x[which(x$fileIndex %in% i), id]
    i = as.character(i)
    fileName = paste(fromDir,suf,i,ext,sep = "")
    temp = read.table(fileName, header = F, sep = "\t", stringsAsFactors = F)
    if(!exists("results")){
      results = subset(temp, temp[,y] %in% genes)
    } else {
      results = rbind(results, subset(temp, temp[,y] %in% genes))
    }
  }
  return(results)
}
