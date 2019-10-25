library(MplusAutomation)
setwd("./")

this.dir<- dirname(parent.frame(2)$ofile)
parent.dir <- strsplit(this.dir,'scripts')[[1]]
setwd(parent.dir)

scaleMaxMin10 <- function(x){
  a = 10.0/max(x, na.rm=T)
  scaledvar = a*x
  return(scaledvar)
}

prep_missing <- function (data) {
  dataf <- read.table(paste0("data/",data,".csv"),sep=",",header=TRUE) #,na.strings = "")
  dataf = as.data.frame(lapply(dataf, scaleMaxMin10)) # obtain scaled dataframe
  outfile = paste0("./data/",data,"-missing.dat")
  head(dataf)
  prepareMplusData(dataf, outfile) # produce input for Mplus, remove first column (city)
}

prep <- function (data) {
  dataf <- read.table(paste0("data/",data,".csv"),sep=",",header=TRUE) #,na.strings = "")
  for(i in 1:ncol(dataf)){
    dataf[is.na(dataf[,i]), i] <- mean(dataf[,i], na.rm = TRUE)
  }
  dataf = as.data.frame(lapply(dataf, scaleMaxMin10)) # obtain scaled dataframe
  outfile = paste0("./data/",data,".dat")
  head(dataf)
  prepareMplusData(dataf, outfile) # produce input for Mplus, remove first column (city)
}

prep('urbandata2019-64var-id-sorted-updated') #output: 'urbandata2019-64var-id-sorted-updated.dat'
prep_missing('urbandata2019-64var-id-sorted-updated') #output: 'urbandata2019-64var-id-sorted-updated-missing.dat'

