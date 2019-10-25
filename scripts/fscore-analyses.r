library(psych)
library(arsenal)
library(ggplot2)
library(data.table)

### GLOBAL VARIABLES
num_fac = 9


# this.dir<- dirname(parent.frame(2)$ofile)
# parent.dir <- strsplit(this.dir,'scripts')[[1]]
# setwd(parent.dir)

orig_var_order <- read.csv('efa/variable_order_mplus.csv')[,2]
city_names <- read.csv('data/urbandata2019-64var-citynames-countries.csv')[,1:2]

## LOADINGS || DATA || FACTOR CORRELATION 
loading <- read.csv(paste0('efa/',num_fac,'f-loadings-missing-sig.csv'),header=FALSE)
data_scaled <-read.table('data/urbandata2019-64var-id-sorted-updated.dat') 
#NOTE: Full-information maximum likelihood was used to estimate the factor model and obtain loadings
#But the mean-imputed dataset is used to compute the factor scores from these loadings as starting point for the iteration

## DATA
## Missingness
dm <-read.table('data/urbandata2019-64var-id-sorted-updated-missing.dat') 
dm[dm=="."]<-NA
missrate <- as.numeric(table(is.na(dm))[2])/sum(table(is.na(dm)))*100
print(paste0("Percent missingness in data: ", round(missrate,2)))

## Support for factor choice (Figure 1 in paper)
datacor = cor(as.matrix(sapply(dm, as.numeric)),use="pairwise.complete.obs")  
eigval = eigen(datacor)$values
ablinecolor <- rgb(31, 120, 180, alpha=255,maxColorValue = 255)
plot(c(1:64),eigval[1:64],xlab="Index",ylab="Eigenvalue",color='k',pch=19,xlim=c(0,64))
#axis(1, at = 0:64)
abline(v=9, col=ablinecolor)
rectcolor <- rgb(166, 206, 227, alpha=90,maxColorValue = 255)
rect(8, -2, 12, 17,border=NA,col=rectcolor)

getScore <- function(df, load, factor_cor=NULL){
  if(num_fac==8){colnames(load) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8")}
  if(num_fac==9){colnames(load) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9")}
  if(num_fac==11){colnames(load) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9","F10","F11")}
  print(head(load))
  load <- as.matrix(load[,-1])
  load <- cbind(load, as.matrix(orig_var_order))
  load_sorted <- load[order(load[,num_fac+1]),]
  load_sorted <- load_sorted[,1:num_fac]
  print("Loading:")
  print(head(load_sorted))
  if (is.null(factor_cor)){
    tf = factor.scores(data.matrix(df),load_sorted,method='components') 
    }else{
    tf = factor.scores(data.matrix(df),load_sorted, factor_cor,method='components') 
  }
  print("Scores")
  xform = tf$scores
  xform = xform[]
  xform = data.frame(xform)
  xform$city = city_names$City
  xform$cityID = city_names$cityID
  print(head(xform))
  write.csv(xform,'output/fscores-mean-imputed.csv',row.names=FALSE)
  return(xform)
}

scores <- getScore(data_scaled,loading)

viewLoadings <- function(df, n) {
  df2 <- melt(df, id="Variables", variable.name="Factors", value.name="Loading", measure = colnames(df)[1:n+1])
  print(head(df2))
  xd <- ggplot(df2, aes(Variables, abs(Loading), fill=Loading)) + facet_wrap(~ Factors, nrow=1) + geom_bar(stat="identity")+ coord_flip()+ 
    scale_fill_gradient2(name="Loading",high="blue",mid="white",low="red",midpoint=0,guide=F)+ylab("Loading")+theme_bw(base_size=10)
  ggsave(paste0("output/", "loadings-", nrow(df),"-variables-", n,"-factors.pdf"), xd, width=18, height=15)
}

if(num_fac==8){colnames(loading) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8")}
if(num_fac==9){colnames(loading) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9")}
if(num_fac==11){colnames(loading) = c("Variables", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9","F10","F11")}

loading$Variables <- factor(loading$Variables, levels=loading$Variables[c(1:64)])
viewLoadings(loading,num_fac)

## Loading stats
colMeans(loading[,-1])
apply(loading[,-1], 2, function(x) max(x, na.rm = TRUE))
apply(loading[,-1], 2, function(x) sd(x, na.rm = TRUE))

