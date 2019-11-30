#!/user/bin/env Rscripts

#######################
#######################
#######Jason Lai#######
## PhD candidate#######
###Max Planck - BN#####
#######################

#-----19/03/2015-------
#Description: The script downloads the raw data of GSE data series 
##form GEO NCBI data repository

####load libraries
library(GEOquery)

###load the list of the GSE studies
##Until March 2015
gseList = read.table("GSEList.txt")
##March 2015 till Aug 2016
gseList = rbind(gseList, read.table("GSEList_update.txt"))


###initialize valiables
gsm = c()
gse = c()

####START CODE
for(i in gseList$V1){
  ##parse with getGEO function
  dataset = try(getGEOSuppFiles(i))
  
  ####control loop: in case error is given suspend execution 
  while(class(dataset) == "try-error"){
  Sys.sleep(2)
  dataset = try(getGEOSuppFiles(i))
  }
Sys.sleep(2)
}
####END CODE
