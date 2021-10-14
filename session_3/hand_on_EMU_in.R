require(tidyr)
## Function to normalise values of a matrix between 0 and 1
normalise_matrix <- function(x){
  (x-min(x))/(max(x)-min(x))
}

d <- matrix(c(0,1,NA,1,NA,0), nrow = 3)               ## Initialise D matrix
f <- colMeans(d, na.rm = T)                           ## Population allele frequencies
e <- d + rep(-f, each = nrow(d))                      ## Centered matrix E. Subtract population AF from each non missing value.
e <- tidyr::replace_na(e,0)                           ## Mean imputation
K <- 2                                                ## Number of PCs to use. Matrix is too small for anything larger here.

## You can rerun the code below to see how E changes with each iteration till convergence
s <- svd(e, nu=nrow(e), nv=ncol(e))                   ## SVD on E
D <- diag(s$d)
pi <- s$u[,1:K] %*% D[,1:K] %*% t(s$v[,1:K])          ## Keep only K=2 columns from each matrix to get Pi
pi <- pi + rep(f, each = nrow(pi))                    ## Add F rowwise to get individual AFs.
pi <- normalise_matrix(pi)                            ## Map matrix values between 0 and 1

pi2 <- pi + rep(-f, each = nrow(pi))                  ## Center values by population AF again.
e <- replace(e, is.na(d), pi2[is.na(d)])              ## Update E cells from missing values to the new expectation.
e

## The final E matrix is then rescaled and SVD applied
sq_f_1minusf <- sqrt( f * ( 1 - f ))
x <- e / rep(sq_f_1minusf, each = nrow(e))
svd_x <- svd(x)
