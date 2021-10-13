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

tidy_pca_output <- function(x, context = context_info) {
  pnf_tidy_obs <- x$x %>%
    tibble::as_tibble() %>%
    dplyr::bind_cols(context) %>%
    dplyr::mutate(type = "obs", id = Group_Name)
  pnf_tidy_vars <- x$rotation %>%
    tibble::as_tibble(rownames = "id") %>%
    dplyr::mutate(type = "vars")

  pnf_tidy <- list(
    obs = pnf_tidy_obs,
    vars = pnf_tidy_vars
  )
  
  ## rotate to give it all the same orientation
  j_pc1 <- pnf_tidy$obs %>% dplyr::filter(Group_Name == 'Japanese') %>% dplyr::select(PC1)
  m_pc1 <- pnf_tidy$obs %>% dplyr::filter(Group_Name == 'Mbuti') %>% dplyr::select(PC1)
  cat(as.numeric(j_pc1), as.numeric(m_pc1), '\n')
  if (m_pc1 > j_pc1) pnf_tidy$obs <- pnf_tidy$obs %>% dplyr::mutate(PC1 = -PC1)
  
  ## rotate to give it all the same orientation
  j_pc2 <- pnf_tidy$obs %>% dplyr::filter(Group_Name == 'Japanese') %>% dplyr::select(PC2)
  s_pc2 <- pnf_tidy$obs %>% dplyr::filter(Group_Name == 'Sardinian') %>% dplyr::select(PC2)
  cat(as.numeric(j_pc2), as.numeric(s_pc2), '\n')
  if (s_pc2 > j_pc2) pnf_tidy$obs <- pnf_tidy$obs %>% dplyr::mutate(PC2 = -PC2)
  
  pnf_tidy
}
# explore_filling_method(geno_matrix, missMethods::impute_mean, 0.2)

#####

plot_tidy_pca_simple <- function(x) {
  p <- ggplot() + 
    geom_point(
      data = x$obs,
      mapping = aes(x = PC1, y = PC2, colour = Makro_Region),
      size = 3
    ) +
    ggrepel::geom_text_repel(
      data = x$obs,
      mapping = aes(x = PC1, y = PC2, label = Group_Name),
      size = 3
    )
  if ('projected' %in% colnames(x$obs)) {
    # cat('labeling projected samples')
    p <- p +
      geom_point(
        data = x$obs %>% dplyr::filter(projected == 'projected'),
        mapping = aes(x = PC1, y = PC2),
        size = 1,
        color='black'
      )
  }
  p
}
# plot_tidy_pca_simple(pnf_tidy_drop_ind)

#####

plot_tidy_pca_density <- function(x) {
  p0 <- plot_tidy_pca_simple(x)
  xdens <- cowplot::axis_canvas(p0, axis = "x") +
    geom_density(
      data = x$obs,
      aes(x = PC1, fill = Makro_Region),
      alpha = 0.7
    )
  ydens <- cowplot::axis_canvas(p0, axis = "y", coord_flip = TRUE) +
    geom_density(
      data = x$obs,
      aes(x = PC2, fill = Makro_Region),
      alpha = 0.7
    ) +
    coord_flip()
  p1 <- cowplot::insert_xaxis_grob(p0, xdens, grid::unit(.2, "null"), position = "top")
  p2 <- cowplot::insert_yaxis_grob(p1, ydens, grid::unit(.2, "null"), position = "right")
  cowplot::ggdraw(p2)
}

pca <- prcomp(geno_matrix)
pnf_tidy <- tidy_pca_output(pca)

plot_tidy_pca_simple(pnf_tidy)
plot_tidy_pca_density(pnf_tidy)

# pnf_tidy_obs_long <- pnf_tidy_obs %>%
#   tidyr::pivot_longer(
#     cols = c(
#       "bill_length_mm", "bill_depth_mm",
#       "flipper_length_mm", "body_mass_g"
#     ),
#     names_to = "var",
#     values_to = "meas"
#   )
# 
# pnf_tidy_obs_long %>%
#   dplyr::group_split(var) %>%
#   purrr::map(
#     ~ggplot() +
#       geom_point(
#         data = .,
#         mapping = aes(x = PC1, y = PC2, colour = meas)
#       ) +
#       scale_color_viridis_c() +
#       ggtitle(unique(.$var))
#   ) %>%
#   cowplot::plot_grid(plotlist = .)

####

shoot_holes <- function(x, prop) {
  nr_cells <- prod(dim(x))
  holes <- sample(seq_len(nr_cells), size = round(prop * nr_cells))
  x[holes] <- NA
  return(x)
}

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

explore_filling_method <- function(x, f, destruction_level) {
  x %>% shoot_holes(destruction_level) %>% f() %>%
    prcomp() %>% tidy_pca_output() %>% plot_tidy_pca_density()
}

explore_filling_method(geno_matrix, missMethods::impute_mean, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_median, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_mode, 0.2)

explore_filling_method(geno_matrix, missMethods::impute_EM, 0.2)
explore_filling_method(geno_matrix, missMethods::impute_sRHD, 0.3)

# Mean per penguin species would be much better, probably



######  
## fuck around w/ projecting data

# prcomp(scale. = T)
# scale(newdata, pca$center, pca$scale) %*% pca$rotation

project_downsampled_inds <- function(x, destruction_level, drop_groups = c('Papuan', 'Russian'), context = context_info) {
  drop_ind <- which(context$Group_Name %in% drop_groups)
  
  ## get data for "dropped inds"
  geno_matrix_drop_ind <- x[drop_ind,] %>% shoot_holes(destruction_level)
  dim(geno_matrix_drop_ind)
  print(geno_matrix_drop_ind[1:2, 1:10])
  context_info_drop_ind <- context %>% dplyr::filter(Group_Name %in% drop_groups)
  context_info_drop_ind$projected <- 'projected'
  
  ## get data for rest
  geno_matrix_rest <- x[-drop_ind,]
  dim(geno_matrix_rest)
  context_info_rest <- context %>% dplyr::filter(!Group_Name %in% drop_groups)
  context_info_rest$projected <- 'pca'

  ## do pca for inds that are not downsampled
  pca_rest <- prcomp(geno_matrix_rest)
  
  for (ind in 1:nrow(geno_matrix_drop_ind)) {
    cat('projecting', ind, '\n')
    keep_sites <- !is.na(geno_matrix_drop_ind[ind,])
    pca_drop_ind <- scale(matrix(geno_matrix_drop_ind[ind, keep_sites], nrow = 1),
                          pca_rest$center[keep_sites],
                          pca_rest$scale) %*% pca_rest$rotation[keep_sites, ]
    pca_drop_ind <- pca_drop_ind * length(keep_sites) / sum(keep_sites)
    pca_rest$x <- rbind(pca_rest$x, pca_drop_ind)
    context_info_rest <- rbind(context_info_rest, context_info_drop_ind[ind,])
  }

  ## clean up results
  pnf_tidy_drop_ind <- tidy_pca_output(pca_rest, context_info_rest)
  pnf_tidy_drop_ind$obs <- pnf_tidy_drop_ind$obs %>% dplyr::mutate(downsample = destruction_level)
  pnf_tidy_drop_ind
}

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

plot_tidy_pca_simple2 <- function(x) {
  p <- ggplot() + 
    geom_point(
      data = x$obs,
      mapping = aes(x = PC1, y = PC2, colour = Makro_Region, frame = downsample),
      size = 3
    ) +
    geom_text(
      data = x$obs,
      mapping = aes(x = PC1, y = PC2, label = Group_Name, frame = downsample),
      size = 3
    ) +
    # geom_text(label='hey', x = 0, y = 0) +
  NULL
  if ('projected' %in% colnames(x$obs)) {
    # cat('labeling projected samples')
    p <- p +
      geom_point(
        data = x$obs %>% dplyr::filter(projected == 'projected'),
        mapping = aes(x = PC1, y = PC2, frame = downsample),
        size = 1,
        color='black'
      )
  }
  p
}
# plot_tidy_pca_simple(pnf_tidy_drop_ind)



ggplotly(plot_tidy_pca_simple2(hey))
