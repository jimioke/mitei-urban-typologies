library(psych)
library(cluster)
library(RColorBrewer)
library(data.table)
library(dendextend)
library(ggplot2)
library(NbClust)
library(scales)
library(extrafont)
library(gridExtra)
library(stats)

# this.dir<- dirname(parent.frame(2)$ofile)
# parent.dir <- strsplit(this.dir,'scripts')[[1]]
# setwd(parent.dir)

f9scores = read.csv('output/fscores-mean-imputed.csv',sep=",",header=TRUE)
f9scores$city <- as.character(f9scores$city)
f9scores$city[326] <- "Valencia(VZL)" #change Valencia for identification of duplicate
f9scores$city <- factor(f9scores$city, levels=f9scores$city[c(1:331)])
num_fac <- 9

### Distances
scaled.f9scores = as.data.frame(apply(as.matrix(f9scores[1:9]), 2, rescale)) #as.data.frame(scale(as.matrix(f9scores[1:9])))  
dis9scaled = dist(scaled.f9scores,method="manhattan")
dis9scaled.mat = as.matrix(dis9scaled)
write.csv(scaled.f9scores, 'output/f9scores-scaled.csv', row.names = F)

#num_clust = 12 #This is set in iterate.r

##################################################################################################################
#### Plot dendrogram
##################################################################################################################

## Function to perform clustering
clusterFit <- function(d, m) {
  fit <- hclust(d, method=m) # apply hierarchical clustering 
  return(fit)
}

## Get clustering for 9-factor solution
clusfit9scaled.ward = clusterFit(dis9scaled, "ward.D2")

# Compute goodness-of-fit metrics
optClustWardScaled9 <- NbClust(as.data.frame(scaled.f9scores),distance="manhattan", method="ward.D2",min.nc=10,max.nc=15,index="gap")
#optClustWardScaled9 <- NbClust(diss=dis9scaled.mat, method="ward.D2",min.nc=7,index="all")


## Group cities into clusters based on number of clusters desired
getClusters <- function (clusfit, k, scores) {
  #cluster <- dendextend:::cutree(clusfit, k, order_clusters_as_data = TRUE)
  cluster = cutree(clusfit, k)
  clusters = data.frame(cluster)
  row.names(clusters) = scores$city
  return(clusters)
}
fac9clusters.ward.scaled <- getClusters(clusfit9scaled.ward, num_clust, f9scores) #f9scores only for names!!
fac9clusters.ward.scaled.ordered <- fac9clusters.ward.scaled[order(fac9clusters.ward.scaled$cluster),,drop=FALSE]
write.csv(fac9clusters.ward.scaled, paste0('output/clusters-9-factors-ward-scaled.csv'))

typocolors_all = c(
  '#1f78b4', #darkblue
  '#a6cee3', #lightblue
  '#b2df8a', #lightgreen
  '#33a02c',  #darkgreen 
  '#fb9a99', #lightred
  '#e31a1c', #darkred
  '#6a3d9a', #darkpurple
  '#cab2d6', #lightpurple
  '#ffff99', #lightbrown
  '#b15928', #darkbrown
  '#fdbf6f', #lightorange
  '#ff7f00', #darkorange
  '#8e0152'  #purple
   )

typocolors = typocolors_all[1:num_clust]
if(num_clust==12){
dendtypolist = c(
  "Auto Innovative", "Auto Sprawl",
  "MassTransit Moderate", "MassTransit Heavyweight",
  "Congested Emerging", "Congested Boomer",
  "MetroBike Giant", "MetroBike Emerging",
  "Hybrid Moderate","Hybrid Giant",
  "BusTransit Sprawl", "BusTransit Dense")
}else{
  dendtypolist = c("Auto Innovative", "Auto Sprawl",
                   "MassTransit Sustainable", "MassTransit Moderate", "MassTransit Heavyweight",
                   "Congested Emerging", "Congested Boomer",
                   "MetroBike Giant", "MetroBike Emerging",
                   "Hybrid Moderate","Hybrid Giant",
                   "BusTransit Moderate", "BusTransit Giant")
}

##################################################################################################################
#### Plot dendrogram
##################################################################################################################
# https://gist.github.com/jslefche/eff85ef06b4705e6efbc
theme_black = function(base_size = 12, base_family = "") {
  
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    
    theme(
      # Specify axis options
      axis.line = element_blank(),  
      axis.text.x = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.text.y = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.ticks = element_line(color = "white", size  =  0.2),  
      axis.title.x = element_text(size = base_size, color = "white", margin = margin(0, 10, 0, 0)),  
      axis.title.y = element_text(size = base_size, color = "white", angle = 90, margin = margin(0, 10, 0, 0)),  
      axis.ticks.length = unit(0.3, "lines"),   
      # Specify legend options
      legend.background = element_rect(color = NA, fill = "black"),  
      legend.key = element_rect(color = "white",  fill = "black"),  
      legend.key.size = unit(1.2, "lines"),  
      legend.key.height = NULL,  
      legend.key.width = NULL,      
      legend.text = element_text(size = base_size*0.8, color = "white"),  
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "white"),  
      legend.position = "right",  
      legend.text.align = NULL,  
      legend.title.align = NULL,  
      legend.direction = "vertical",  
      legend.box = NULL, 
      # Specify panel options
      panel.background = element_rect(fill = "black", color  =  NA),  
      panel.border = element_rect(fill = NA, color = "white"),  
      panel.grid.major = element_line(color = "grey35"),  
      panel.grid.minor = element_line(color = "grey20"),  
      panel.spacing = unit(0.5, "lines"),   
      # Specify facetting options
      strip.background = element_rect(fill = "grey30", color = "grey10"),  
      strip.text.x = element_text(size = base_size*0.8, color = "white"),  
      strip.text.y = element_text(size = base_size*0.8, color = "white",angle = -90),  
      # Specify plot options
      plot.background = element_rect(color = "black", fill = "black"),  
      plot.title = element_text(size = base_size*1.2, color = "white"),  
      plot.margin = unit(rep(1, 4), "lines")
    )
}

plotD <- function (clusfit,kk,meth,scores,ff) 
{
  dend <- as.dendrogram(clusfit)
  #dend <- reorder(dend, 1:13, mean)
  nodePar <- list(lab.cex = 0.8, pch = c(NA, NA), cex = 1.6,font=2)
  labels(dend) <- as.character(scores$city[clusfit$order])
  #dend <- set(dend, "labels_cex", .45)
  d1=color_branches(dend,k=kk,col = typocolors) # brewer.pal(kk,"Paired"))
  dcol <- get_leaves_branches_col(d1)
  d1 <- color_labels(d1,k=kk,col=typocolors) #brewer.pal(kk,"Paired"))
  png(file=paste0("output/Dendrogram-",kk,"-clusters-",ff,"-factors-Method-",meth,".png"),family="CM Sans", width=5300,height=2600)
  plot(d1)
  #colored_bars(dcol, dend, rowLabels = c("13 Typologies"))
  dev.off()
}
plotD(clusfit9scaled.ward,num_clust,"Ward.D2-Scaled",f9scores,9)

plotDgg <- function (clusfit,kk,meth,scores,ff) 
{
  dend <- as.dendrogram(clusfit)
  dend <- assign_values_to_branches_edgePar(dend=dend, value = "white", edgePar = "col")
  dend <- color_branches(dend,k=kk,col = typocolors) # brewer.pal(kk,"Paired"))
  ggd1 <- as.ggdend(dend)
  base <- ggplot(ggd1,labels=FALSE)
  base + 
    geom_hline(yintercept=6.2, color="gray",lty=2,lwd=1) + 
    geom_hline(yintercept=3.6, color="gray",lty=3,lwd=1) + 
    theme_black() +
    theme(panel.border = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            axis.title=element_blank(),
            axis.ticks=element_blank(),
            axis.text=element_blank(),
            legend.position=c(0,1)
          )
}
p1 <- plotDgg(clusfit9scaled.ward,num_clust,"Ward.D2-Scaled",f9scores,9)

idx = c(1:331)
df2<-data.frame(cluster=cutree(clusfit9scaled.ward,num_clust) ,states=factor(idx)) #,levels=idx)) #[clusfit9scaled.ward$order]))
head(df2)
df3 <- df2[order(df2$cluster),]
df3$states <- factor(1:331)
df3$cluster <- factor(df3$cluster, labels = dendtypolist)

p2 <- ggplot(df3,aes(states,y=1,fill=factor(cluster)))+
  geom_tile()+
  #scale_y_continuous(expand=c(0,0)) + 
  scale_fill_manual(values = typocolors,breaks=dendtypolist)+  
  #scale_fill_discrete( #+ scale_fill_manual(values = typocolors)+
  theme(axis.title=element_blank(),
        axis.ticks=element_blank(),
        axis.text=element_blank(),
        legend.position=c(.85,9.3),
        legend.title=element_blank(),
        legend.text = element_text(colour="white", size=16),
        legend.key.size = unit(1.5, 'lines'),
        legend.key = element_rect(fill = "gray", colour = "transparent"),
        legend.background = element_rect(fill = "transparent", colour = "transparent")
        )

gp1 <-ggplotGrob(p1)
gp2<-ggplotGrob(p2)  

maxWidth = grid::unit.pmax(gp1$widths[2:5], gp2$widths[2:5])
gp1$widths[2:5] <- as.list(maxWidth)
gp2$widths[2:5] <- as.list(maxWidth)

loadfonts()
png(file=paste0("output/Dendrogram-GG-clusters-","9","-factors-Method-","Ward.D2-Scaled",".png"),family="CM Sans",width=1200,height=1000,res=100)
#gp1
grid.arrange(gp1, gp2, ncol=1,heights=c(9/10,1/10))

dev.off()

