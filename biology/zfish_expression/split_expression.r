#split expression file into smaller chunks, and then index the genes
library(NCmisc)

temp=read.table("data/zfish_expression.txt", header = T, stringsAsFactors = F, sep = "\t")

temp = temp[,c(1,ncol(temp),2:(ncol(temp)-1))]

write.table(temp,"data/zfish.txt", col.names = F, row.names = F, quote = F, sep = "\t")

file.split("data/zfish.txt", suf = "", size = 32520/40, win =F, same.dir = T)

genes = cbind(gene_id = temp$gene_id, gene_name = temp$gene_name, fileIndex = rep(seq(1,40),each = 32520/40))
write.table(genes, "data/zfish_genes.txt", row.names = F, quote = F, sep = "\t")
