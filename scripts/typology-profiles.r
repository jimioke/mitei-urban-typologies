library(VIM)
library(fmsb) ##radarchart
library(stats)
library(data.table)
#setwd('./')

scaleMaxMin1 <- function(x){1*(x - min(x, na.rm=T)) / (max(x, na.rm=T) - min(x, na.rm=T))}

### Get typology factor averages
factor_scores <- scaled.f9scores[,c(1:num_fac)]
colnames(factor_scores) = c("Metro", "BRT", "Bikeshare", "Development", "Sustainability", "Population", "Congestion", "Sprawl", "Network")
#factor_scores <- round(factor_scores,2)
factor_scores$clusterID <- fac9clusters.ward.scaled$cluster
factor_scores$superclusterID <- factor_scores$clusterID
factor_scores <- data.table(factor_scores)
factor_scores[clusterID==3, superclusterID := 1] # congested
factor_scores[clusterID==4, superclusterID := 2] # brt
factor_scores[clusterID==5, superclusterID := 3] # hyb
factor_scores[clusterID==6, superclusterID := 3] # hyb
factor_scores[clusterID==7, superclusterID := 4] # auto
factor_scores[clusterID==8, superclusterID := 4] # auto
factor_scores[clusterID==9, superclusterID := 5] # mass
factor_scores[clusterID==10, superclusterID := 5] # mass
factor_scores[clusterID==11, superclusterID := 6] # metrobike
factor_scores[clusterID==12, superclusterID := 6] # metrobike

factor_scores <- as.data.frame(factor_scores)
#factor_scores <- as.data.frame(lapply(factor_scores, scaleMaxMin1)) # obtain scaled dataframe

typology_factor_means <- round(aggregate(factor_scores, list(factor_scores$clusterID), mean), 2) #[,c(1:9)]
#typology_factor_means <- as.data.frame(lapply(typology_factor_means, scaleMaxMin1)) # obtain scaled dataframe

super_typology_factor_means <- round(aggregate(factor_scores, list(factor_scores$superclusterID), mean),2)
#super_typology_factor_means <- as.data.frame(lapply(super_typology_factor_means, scaleMaxMin1)) # obtain scaled dataframe


row.names(typology_factor_means) <- c(	"Congested Emerging",
                                        "BusTransit Sprawl",
                                        "Congested Boomer",
                                        "BusTransit Dense",
                                        "Hybrid Moderate",
                                        "Hybrid Giant",
                                        "Auto Sprawl",
                                        "Auto Innovative",
                                        "MassTransit Heavyweight",
                                        "MassTransit Moderate",
                                        "MetroBike Giant",
                                        "MetroBike Emerging"	)


row.names(super_typology_factor_means) <- c( "Congested",
                                       "BusTransit",
                                       "Hybrid",
                                       "Auto",
                                       "MassTransit",
                                       "MetroBike")

### Get top 6 variables and values for each typology
matrixplot(typology_factor_means[,2:10])

#https://www.data-to-viz.com/caveat/spider.html
typology_factor_means$color <- c(
  '#fb9a99', #lightred
  '#fdbf6f', #lightorange			
  '#e31a1c', #darkred
  '#ff7f00', #darkorange
  '#eaddca', # #ffff99', #yellow '#d2b48c', #lightbrown
  '#b15928', #darkbrown
  '#a6cee3', #lightblue
  '#1f78b4', #darkblue
  '#33a02c',  #darkgreen 
  '#b2df8a', #lightgreen
  '#6a3d9a', #darkpurple
  '#cab2d6' #lightpurple
)

super_typology_factor_means$color <- c(
  '#e31a1c', #darkred
  '#ff7f00', #darkorange
  '#b15928', #darkbrown
  '#1f78b4', #darkblue
  '#33a02c', #darkgreen 
  '#6a3d9a'  #darkpurple
)

typo_averages <- typology_factor_means[ order(row.names(typology_factor_means)), ]
plot_data <- typo_averages[,2:10]
plot_data <-rbind(rep(1,num_clust) , rep(0,num_clust) , plot_data)

super_typo_averages <- super_typology_factor_means[ order(row.names(super_typology_factor_means)), ]
super_plot_data <- super_typo_averages[,2:10]
super_plot_data <- rbind(rep(1,num_clust) , rep(0,num_clust) , super_plot_data)


# Split the screen in 6 parts
par(mar=rep(1,4)) #c(2.5, .75, 2.5, .75) )#rep(1,4))
par(mfcol=c(4,3))

#par(adj=0)

spider_plot <- function(num_clusters, data, factors_df) {
  for(i in 1:num_clusters){
    
    # Custom the radarChart !
    radarchart( data[c(1,2,i+2),], axistype=1, centerzero=FALSE,
                
                #custom polygon #typo_averages$color[i]
                pcol= 'darkgray', pfcol=alpha(factors_df$color[i],.8) , plwd=4, plty=1 , 
                
                #custom the grid
                cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,1,.25), cglwd=0.8,
                
                #custom labels
                vlcex=1.5,
                
                #title
                title=rownames(factors_df)[i]
    )
  }
}

spider_plot(12, plot_data, typo_averages) # Generate spider plots as seen in paper

par(mfcol=c(2,3))
spider_plot(6,super_plot_data,super_typo_averages) # Spider plots of super-typologies

data_complete <- read.csv('plot-data/urbandata2019-64var-id-sorted-updated-citynames-countries-updated.csv')
typology_var_means <- as.data.frame(aggregate(data_complete[,-c(1:4)], list(data_complete$clusterID), mean,na.rm = TRUE))
row.names(typology_var_means) <- c(	"Congested Emerging",
                                    "BusTransit Sprawl",
                                    "Congested Boomer",
                                    "BusTransit Dense",
                                    "Hybrid Moderate",
                                    "Hybrid Giant",
                                    "Auto Sprawl",
                                    "Auto Innovative",
                                    "MassTransit Heavyweight",
                                    "MassTransit Moderate",
                                    "MetroBike Giant",
                                    "MetroBike Emerging"	)


#single_spider_plot <- function(){

png(filename="output/single-spider.png",width=16, height=10, units="in",res=360,type='cairo')
op <- par(mar = c(5, 4, 12, 2) + 0.1) #c(1, 2, 10, 1))
radarchart(plot_data, axistype=1, centerzero=FALSE,
            #custom polygon #typo_averages$color[i]
            pcol=alpha(typo_averages$color,.8) , plwd=4, plty=1 , 
            #custom the grid
            cglcol="grey", cglty=1, axislabcol="black", caxislabels=seq(0,1,.25), cglwd=0.8,
            #custom labels
            vlcex=1.7,
  )
par(op)#mai=c(3,0,0,0))

legend(x=1.6, y=1, legend = rownames(plot_data[-c(1,2),]), bty = "n", pch=20 , col=typo_averages$color , text.col = "black", cex=1.5, pt.cex=3)

dev.off()

#single_spider_plot
