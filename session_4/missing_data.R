# install dependencies
packages <- c("tidyverse", "palmerpenguins", "cowplot", "softImpute", "missMethods", "norm", "mvtnorm")
missing_packages <- packages[!packages %in% utils::installed.packages()]
Map(function(x) { install.packages(x) }, missing_packages)

library(magrittr)
library(ggplot2)

pengu <- palmerpenguins::penguins %>%
  dplyr::mutate(id = seq_len(nrow(.)) %>% as.character())

pnf <- pengu_na_filtered <- pengu %>%
  dplyr::filter(
    dplyr::across(
      tidyselect::any_of(c(
        "bill_length_mm", "bill_depth_mm", 
        "flipper_length_mm", "body_mass_g"
      )),
      function(x) { !is.na(x) }
    )
  )
  
pnf_matrix <- pengu_na_filtered %>%
  dplyr::select(
    "bill_length_mm", "bill_depth_mm", 
    "flipper_length_mm", "body_mass_g"
  ) %>% 
  as.matrix()

pnf_pca <- prcomp(pnf_matrix, scale. = T)
#biplot(pnf_pca)

####

tidy_pca_output <- function(x, ids = pnf$id, raw_input = pengu) {
  pnf_tidy_obs <- x$x %>%
    tibble::as_tibble() %>%
    dplyr::mutate(
      id = ids,
      type = "obs"
    ) %>%
    dplyr::left_join(
      raw_input, by = "id"
    )
  pnf_tidy_vars <- x$rotation %>%
    tibble::as_tibble(rownames = "id") %>%
    dplyr::mutate(
      type = "vars"
    )
  list(
    obs = pnf_tidy_obs,
    vars = pnf_tidy_vars
  )
}

pnf_tidy <- tidy_pca_output(pnf_pca, pnf$id, pengu)

plot_tidy_pca_simple <- function(x) {
  ggplot() + geom_point(
    data = x$obs,
    mapping = aes(x = PC1, y = PC2, colour = species)
  )
}

plot_tidy_pca_density <- function(x) {
  p0 <- plot_tidy_pca_simple(x)
  xdens <- cowplot::axis_canvas(p0, axis = "x") +
    geom_density(
      data = x$obs,
      aes(x = PC1, fill = species),
      alpha = 0.7
    )
  ydens <- cowplot::axis_canvas(p0, axis = "y", coord_flip = TRUE) +
    geom_density(
      data = x$obs,
      aes(x = PC2, fill = species),
      alpha = 0.7
    ) +
    coord_flip()
  p1 <- cowplot::insert_xaxis_grob(p0, xdens, grid::unit(.2, "null"), position = "top")
  p2 <- cowplot::insert_yaxis_grob(p1, ydens, grid::unit(.2, "null"), position = "right")
  cowplot::ggdraw(p2)
}

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

pengu_perforated <- shoot_holes(pnf_matrix, 0.2)

patch_holes_mean <- function(x) {
  apply(x, 2, function(y) { 
    y[is.na(y)] <- mean(y, na.rm = T)
    return(y)
  })
}

patch_holes_mean(pengu_perforated) %>% 
  prcomp(scale. = T) %>% tidy_pca_output() %>% plot_tidy_pca_density()

# fits <- softImpute::softImpute(pengu_perforated, type="svd")
# pnf_matrix %>% shoot_holes(pnf_matrix, 0.2) %>%
#   softImpute::complete(pengu_perforated, fits) %>%
#   prcomp(scale. = T) %>% tidy_pca_output() %>% plot_tidy_pca()

explore_filling_method <- function(x, f, destruction_level) {
  x %>% shoot_holes(destruction_level) %>% f() %>%
    prcomp(scale. = T) %>% tidy_pca_output() %>% plot_tidy_pca_density()
}

explore_filling_method(pnf_matrix, missMethods::impute_mean, 0.5)
explore_filling_method(pnf_matrix, missMethods::impute_median, 0.5)
explore_filling_method(pnf_matrix, missMethods::impute_mode, 0.2)

explore_filling_method(pnf_matrix, missMethods::impute_EM, 0.5)
explore_filling_method(pnf_matrix, missMethods::impute_sRHD, 0.5)

# Mean per penguin species would be much better, probably

####

prcomp(scale. = T)
scale(newdata, pca$center, pca$scale) %*% pca$rotation

