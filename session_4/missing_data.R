# install dependencies
packages <- c("tidyverse", "cowplot", "softImpute", "missMethods", "norm", "mvtnorm", "ggrepel")
Map(function(x) { install.packages(x) }, packages[!packages %in% utils::installed.packages()])

library(magrittr)
library(ggplot2)

# load data
geno_matrix <- scan("geno_matrix.txt", what = "character") %>%
  strsplit("") %>%
  do.call(rbind, .) %>%
  apply(., 2, as.numeric)

context_info <- readr::read_csv("context_info.csv")

###### 

pca <- prcomp(geno_matrix)
pnf_tidy <- tidy_pca_output(pca)

plot_tidy_pca_simple(pnf_tidy)
plot_tidy_pca_density(pnf_tidy)

####

geno_perforated <- shoot_holes(geno_matrix, 0.2)

patch_holes_mean <- function(x) {
  apply(x, 2, function(y) { 
    y[is.na(y)] <- mean(y, na.rm = T)
    return(y)
  })
}

patch_holes_mean(geno_perforated) %>% 
  prcomp() %>% tidy_pca_output() %>% plot_tidy_pca_density()

# fits <- softImpute::softImpute(pengu_perforated, type="svd")
# pnf_matrix %>% shoot_holes(pnf_matrix, 0.2) %>%
#   softImpute::complete(pengu_perforated, fits) %>%
#   prcomp(scale. = T) %>% tidy_pca_output() %>% plot_tidy_pca()

explore_filling_method(geno_matrix, missMethods::impute_mean, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_median, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_mode, 0.2)

explore_filling_method(geno_matrix, missMethods::impute_EM, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_sRHD, 0.3)

# Mean per penguin species would be much better, probably

######  
## fuck around w/ projecting data

# prcomp(scale. = T)


hey <- project_downsampled_inds(geno_matrix, .2)
plot_tidy_pca_density(hey)




#######

%>% plot_tidy_pca_density()

######


plot_tidy_pca_density(pnf_tidy_drop_ind)


# install.packages('gganimate')
library(gganimate)
library(plotly)

##########

hey <- project_downsampled_inds(geno_matrix, 0)
for (ds in c(seq(.5, .9, .1), seq(.91, .99, .003))) {
  hey1 <- project_downsampled_inds(geno_matrix, ds)
  hey$obs <- rbind(hey$obs, hey1$obs)
}
# hey1$vars <- rbind(hey1$vars, hey2$vars)
# plot_tidy_pca_density(hey1)

# plot_tidy_pca_density(hey1)

#######

# plot_tidy_pca_simple(pnf_tidy_drop_ind)

ggplotly(plot_tidy_pca_simple(hey))
