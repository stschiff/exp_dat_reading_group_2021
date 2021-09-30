# install dependencies
packages <- c("tidyverse", "palmerpenguins", "cowplot")
missing_packages <- packages[!packages %in% utils::installed.packages()]
Map(function(x) { install.packages(x) }, missing_packages)

library(magrittr)
library(ggplot2)

pengu <- palmerpenguins::penguins %>%
  dplyr::mutate(id = seq_len(nrow(.)))

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

biplot(pnf_pca)

pnf_tidy_obs <- pnf_pca$x %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    id = pnf$id,
    type = "obs"
  ) %>%
  dplyr::left_join(
    pengu, by = "id"
  )

pnf_tidy_vars <- pnf_pca$rotation %>%
  tibble::as_tibble(rownames = "id") %>%
  dplyr::mutate(
    type = "vars"
  )

p0 <- ggplot() +
  geom_point(
    data = pnf_tidy_obs,
    mapping = aes(x = PC1, y = PC2, colour = species)
  )

# xdens <- cowplot::axis_canvas(p0, axis = "x") +
#   geom_density(
#     data = pnf_tidy_obs, 
#     aes(x = PC1, fill = species),
#     alpha = 0.7
#   ) 
# 
# ydens <- cowplot::axis_canvas(p0, axis = "y", coord_flip = TRUE) +
#   geom_density(
#     data = pnf_tidy_obs, 
#     aes(x = PC2, fill = species),
#     alpha = 0.7
#   ) + 
#   coord_flip()
# 
# p1 <- cowplot::insert_xaxis_grob(p0, xdens, grid::unit(.2, "null"), position = "top")
# p2 <- cowplot::insert_yaxis_grob(p1, ydens, grid::unit(.2, "null"), position = "right")
# cowplot::ggdraw(p2)

pnf_tidy_obs_long <- pnf_tidy_obs %>%
  tidyr::pivot_longer(
    cols = c(
      "bill_length_mm", "bill_depth_mm", 
      "flipper_length_mm", "body_mass_g"
    ),
    names_to = "var",
    values_to = "meas"
  )

pnf_tidy_obs_long %>%
  dplyr::group_split(var) %>%
  purrr::map(
    ~ggplot() +
      geom_point(
        data = .,
        mapping = aes(x = PC1, y = PC2, colour = meas)
      ) +
      scale_color_viridis_c() +
      ggtitle(unique(.$var))
  ) %>%
  cowplot::plot_grid(plotlist = .)



