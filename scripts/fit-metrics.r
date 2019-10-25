library(openxlsx)
library(matlib)
library(Matrix)

this.dir<- dirname(parent.frame(2)$ofile)
parent.dir <- strsplit(this.dir,'scripts')[[1]]
setwd(parent.dir)

load_file <- 'efa/missing-loadings-f3-f12-sig-2.xlsx' #only statistically signficant loadings included
#To compute LSI using all loadings set load_file to 'efa/missing-loadings-f3-f12.csv'

f12_load_mat <- as.matrix(read.xlsx(load_file, sheet = 1, colNames = FALSE))
f11_load_mat <- as.matrix(read.xlsx(load_file, sheet = 2, colNames = FALSE))
f10_load_mat <- as.matrix(read.xlsx(load_file, sheet = 3, colNames = FALSE))
f9_load_mat <- as.matrix(read.xlsx(load_file, sheet = 4, colNames = FALSE))
f8_load_mat <- as.matrix(read.xlsx(load_file, sheet = 5, colNames = FALSE))
f7_load_mat <- as.matrix(read.xlsx(load_file, sheet = 6, colNames = FALSE))
f6_load_mat <- as.matrix(read.xlsx(load_file, sheet = 7, colNames = FALSE))
f5_load_mat <- as.matrix(read.xlsx(load_file, sheet = 8, colNames = FALSE))
f4_load_mat <- as.matrix(read.xlsx(load_file, sheet = 9, colNames = FALSE))
f3_load_mat <- as.matrix(read.xlsx(load_file, sheet = 10, colNames = FALSE))

eps <- 1.0e-8
w_fun <- function(x) {(x^2 + eps)^(10*x^2)}
"%^%" <- function(x, n) with(eigen(x), vectors %*% (values^n * t(vectors)))
lsi <- function(load_mat) {
  nfac <- ncol(load_mat)
  c_mat <- diag(t(load_mat) %*% load_mat)
  c_mat <- diag(c_mat)
  h_mat <- diag(load_mat %*% inv(c_mat) %*% t(load_mat))
  h_mat <- diag(h_mat)
  b_mat <- (h_mat %^% (-0.5)) %*% load_mat %*% (c_mat %^% (-0.5))
  ww <- sum(sapply( b_mat, w_fun,simplify="array"))*(1/64.0)*(1.0/nfac)  
  ee <- ((1.0/nfac) + eps)^(10.0/nfac)
  ind <- (ww-ee)/(1.0-ee)
  return(ind)
}

print(paste0(ncol(f12_load_mat)," factors: LSI =", lsi(f12_load_mat)))
print(paste0(ncol(f11_load_mat)," factors: LSI =", lsi(f11_load_mat)))
print(paste0(ncol(f10_load_mat)," factors: LSI =", lsi(f10_load_mat)))
print(paste0(ncol(f9_load_mat)," factors: LSI =", lsi(f9_load_mat)))
print(paste0(ncol(f8_load_mat)," factors: LSI =", lsi(f8_load_mat)))
print(paste0(ncol(f7_load_mat)," factors: LSI =", lsi(f7_load_mat)))
print(paste0(ncol(f6_load_mat)," factors: LSI =", lsi(f6_load_mat)))
print(paste0(ncol(f5_load_mat)," factors: LSI =", lsi(f5_load_mat)))
print(paste0(ncol(f4_load_mat)," factors: LSI =", lsi(f4_load_mat)))
print(paste0(ncol(f3_load_mat)," factors: LSI =", lsi(f3_load_mat)))

