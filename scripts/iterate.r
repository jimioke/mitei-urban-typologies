### Iterate factor scores and clustering via mean imputation by typology
library(wordspace)

this.dir<- dirname(parent.frame(2)$ofile)
parent.dir <- strsplit(this.dir,'scripts')[[1]]
setwd(parent.dir)

get_data <- function () {
  datafile <- 'data/urbandata2019-64var-id-sorted-updated.csv'
  print(paste0("Step 1: read in appropriate dataset",datafile))
  data <- read.csv(datafile)
  head(data)
  return(data)
}

data1 <- get_data()
data_scaled_missing <- read.csv('data/urbandata2019-64var-id-sorted-updated-missing.dat',sep="\t",header=FALSE) 
data_scaled_missing[data_scaled_missing=="."]<-NA
data_scaled_missing <- apply(as.matrix(data_scaled_missing), 2, as.numeric)

data1[,c(1:64)] <- data_scaled_missing
indexcols <- read.csv('data/urbandata2019-64var-citynames-countries-updated.csv')[,1:4]
data1 <- cbind(indexcols,data1)

impute_iterate <- function (n) {
  num_clust = 13 #optimal starting number
  print("Step 2: starting zeroth iteration: factor scores on mean imputed data")
  source('scripts/fscore-analyses.r') # computes the first round of factor scores (check right loadings and data are used)
  print("Step 3: zeroth clustering step")
  source('scripts/cluster-analyses.r')
  print("Step 4: iterate over mean imputation by cluster")
  for (i in c(1:n)){
    if (i>1){
      clustermeans_old <- clustermeans
      print(head(clustermeans_old)[,1:4])
    }
    print(paste0("Step ",i+3,"a: perform mean imputation by cluster"))
    source('scripts/typology-mean-iteration.r')
    print(head(clustermeans)[,1:4])
    print(paste0("Step ",i+3,"b: get updated scores"))
    scores <- getScore(data3,loading)
    print(paste0("Step ",i+3,"c: perform clustering on updated scores"))
    source('scripts/cluster-analyses.r')
    print(paste0("Step ",i+3,"d: perform next iteration"))
    if (i>1){
      print(head(as.matrix(clustermeans)-as.matrix(clustermeans_old))[,1:4])
      normdiff <- mean(rowNorms(as.matrix(clustermeans)-as.matrix(clustermeans_old)))
      print(paste0("Iteration ",i, ": Norm of diff clustermeans: ", normdiff))
    }
  }
  num_clust = 12 #for final typology grouping
}

impute_iterate(6)
num_clust = 12 #for final grouping