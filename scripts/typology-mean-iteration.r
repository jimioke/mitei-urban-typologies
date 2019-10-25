library(anchors)

# this.dir<- dirname(parent.frame(2)$ofile)
# parent.dir <- strsplit(this.dir,'scripts')[[1]]
# setwd(parent.dir)

clusters <- read.csv('output/clusters-9-factors-ward-scaled.csv')
data1$clusterID <- clusters$cluster


d1 <- colMeans(data1[data1$clusterID==1,][,-c(1:4)],na.rm=TRUE)
d2 <- colMeans(data1[data1$clusterID==2,][,-c(1:4)],na.rm=TRUE)
d3 <- colMeans(data1[data1$clusterID==3,][,-c(1:4)],na.rm=TRUE)
d4 <- colMeans(data1[data1$clusterID==4,][,-c(1:4)],na.rm=TRUE)
d5 <- colMeans(data1[data1$clusterID==5,][,-c(1:4)],na.rm=TRUE)
d6 <- colMeans(data1[data1$clusterID==6,][,-c(1:4)],na.rm=TRUE)
d7 <- colMeans(data1[data1$clusterID==7,][,-c(1:4)],na.rm=TRUE)
d8 <- colMeans(data1[data1$clusterID==8,][,-c(1:4)],na.rm=TRUE)
d9 <- colMeans(data1[data1$clusterID==9,][,-c(1:4)],na.rm=TRUE)
d10 <- colMeans(data1[data1$clusterID==10,][,-c(1:4)],na.rm=TRUE)
d11 <- colMeans(data1[data1$clusterID==11,][,-c(1:4)],na.rm=TRUE)
d12 <- colMeans(data1[data1$clusterID==12,][,-c(1:4)],na.rm=TRUE)
if(num_clust==13){
  d13 <- colMeans(data1[data1$clusterID==13,][,-c(1:4)],na.rm=TRUE)
}

datameans <- colMeans(data1[,-c(1:4)],na.rm=TRUE)
if(num_clust==13){clustermeans <- data.frame(rbind(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13))
}else{clustermeans <- data.frame(rbind(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12))}
for (ii in c(1:64)){
  clustermeans[,ii][is.na(clustermeans[,ii])] = as.numeric(datameans[ii])
}

data2 <- data.frame(data1)
head(data2[data2$clusterID==1,][names(clustermeans)[64]])
for (ii in c(1:13)){
  for (jj in c(1:64)){
      data2[data2$clusterID==ii,] <- replace.value(data2[data2$clusterID==ii,] , names(clustermeans)[jj], NA, clustermeans[ii,jj] )
  }
}
head(data2[data2$clusterID==1,][names(clustermeans)[64]])

data3 <- as.data.frame(data2[,-c(1:4)])



