project_downsampled_inds <- function(x, destruction_level, drop_groups = c('Papuan', 'Russian'), context = context_info, pca_rest = NULL, ret.pca_rest = F) {
  drop_ind <- which(context$Group_Name %in% drop_groups)
  
  ## get data for "dropped inds"
  geno_matrix_drop_ind <- x[drop_ind,] %>% shoot_holes(destruction_level)
  dim(geno_matrix_drop_ind)
  # print(geno_matrix_drop_ind[1:2, 1:10])
  context_info_drop_ind <- context %>% dplyr::filter(Group_Name %in% drop_groups)
  context_info_drop_ind$projected <- 'projected'
  
  ## get data for rest
  geno_matrix_rest <- x[-drop_ind,]
  dim(geno_matrix_rest)
  context_info_rest <- context %>% dplyr::filter(!Group_Name %in% drop_groups)
  context_info_rest$projected <- 'pca'
  
  ## do pca for inds that are not downsampled
  if (is.null(pca_rest)) {
    pca_rest <- prcomp(geno_matrix_rest)
    ## allow the function to just return the pca for non-downsampled inds, which is static
    if (ret.pca_rest) return(pca_rest)
  }
  
  for (ind in 1:nrow(geno_matrix_drop_ind)) {
    # cat('projecting', ind, '\n')
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
  pnf_tidy_drop_ind <- pnf_tidy_drop_ind %>% dplyr::mutate(downsample = destruction_level)
  pnf_tidy_drop_ind
}

project_downsampled_inds2 <- function(x, destruction_level, drop_groups = c('Papuan', 'Russian'), context = context_info) {
  drop_ind <- which(context$Group_Name %in% drop_groups)
  
  ## get data for "dropped inds"
  geno_matrix_drop_ind <- x[drop_ind,] %>% shoot_holes(destruction_level)
  dim(geno_matrix_drop_ind)
  # print(geno_matrix_drop_ind[1:2, 1:10])
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
    # cat('projecting', ind, '\n')
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
  pnf_tidy_drop_ind <- pnf_tidy_drop_ind %>% dplyr::mutate(downsample = destruction_level)
  pnf_tidy_drop_ind
}

explore_filling_method <- function(x, f, destruction_level) {
  x %>% shoot_holes(destruction_level) %>% f() %>%
    prcomp() %>% tidy_pca_output() %>% plot_tidy_pca_density()
}

shoot_holes <- function(x, prop) {
  nr_cells <- prod(dim(x))
  holes <- sample(seq_len(nr_cells), size = round(prop * nr_cells))
  x[holes] <- NA
  return(x)
}

tidy_pca_output <- function(x, context = context_info) {
  pnf_tidy_obs <- x$x %>%
    tibble::as_tibble() %>%
    dplyr::bind_cols(context)

  ## rotate to give it all the same orientation
  j_pc1 <- pnf_tidy_obs %>% dplyr::filter(Group_Name == 'Japanese') %>% dplyr::select(PC1)
  m_pc1 <- pnf_tidy_obs %>% dplyr::filter(Group_Name == 'Mbuti') %>% dplyr::select(PC1)
  # cat(as.numeric(j_pc1), as.numeric(m_pc1), '\n')
  if (m_pc1 > j_pc1) pnf_tidy_obs <-pnf_tidy_obs %>% dplyr::mutate(PC1 = -PC1)
  
  ## rotate to give it all the same orientation
  j_pc2 <- pnf_tidy_obs %>% dplyr::filter(Group_Name == 'Japanese') %>% dplyr::select(PC2)
  s_pc2 <- pnf_tidy_obs %>% dplyr::filter(Group_Name == 'Sardinian') %>% dplyr::select(PC2)
  # cat(as.numeric(j_pc2), as.numeric(s_pc2), '\n')
  if (s_pc2 > j_pc2) pnf_tidy_obs <- pnf_tidy_obs %>% dplyr::mutate(PC2 = -PC2)
  
  pnf_tidy_obs
}
# explore_filling_method(geno_matrix, missMethods::impute_mean, 0.2)

#####

plot_tidy_pca_simple <- function(x, text_geom = geom_text) {suppressWarnings({
  if (!"downsample" %in% colnames(x)) {
    x$downsample <- 0.0
  }
  if (!"iter" %in% colnames(x)) {
    x$iter <- NA
  }
  p <- ggplot() + 
    geom_point(
      data = x,
      mapping = aes(x = PC1, y = PC2, colour = Makro_Region, frame = iter),
      size = 3
    ) +
    text_geom(
      data = x,
      mapping = aes(x = PC1, y = PC2, label = Group_Name, frame = iter),
      size = 3
    ) +
    geom_text(
      data = x %>% dplyr::mutate(PC1 = min(PC1), PC2 = min(PC2)) %>% dplyr::group_by(iter) %>% dplyr::sample_n(1),
      mapping = aes(x = -Inf, y = -Inf, label = sprintf('Remove %g%%', downsample*100), frame = iter),
      size = 5,
      vjust = -1.2, hjust = -0.1
    ) +
    # geom_text(label='hey', x = 0, y = 0) +
    NULL
  if ('projected' %in% colnames(x)) {
    # cat('labeling projected samples')
    p <- p +
      geom_point(
        data = x %>% dplyr::filter(projected == 'projected'),
        mapping = aes(x = PC1, y = PC2, frame = iter),
        size = 1,
        color='red'
      )
  }
  p
})}

plot_tidy_pca_density <- function(x, text_geom = geom_text) {
  p0 <- plot_tidy_pca_simple(x, text_geom)
  xdens <- cowplot::axis_canvas(p0, axis = "x") +
    geom_density(
      data = x,
      aes(x = PC1, fill = Makro_Region),
      alpha = 0.7
    )
  ydens <- cowplot::axis_canvas(p0, axis = "y", coord_flip = TRUE) +
    geom_density(
      data = x,
      aes(x = PC2, fill = Makro_Region),
      alpha = 0.7
    ) +
    coord_flip()
  p1 <- cowplot::insert_xaxis_grob(p0, xdens, grid::unit(.2, "null"), position = "top")
  p2 <- cowplot::insert_yaxis_grob(p1, ydens, grid::unit(.2, "null"), position = "right")
  cowplot::ggdraw(p2)
}