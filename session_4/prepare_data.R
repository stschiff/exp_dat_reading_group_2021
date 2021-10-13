packages <- c("tidyverse", "remotes")
Map(function(x) { install.packages(x) }, packages[!packages %in% utils::installed.packages()])
remotes::install_github("poseidon-framework/poseidonR")

library(magrittr)

# download Patterson2012 genotype data with trident:
# https://poseidon-framework.github.io/#/trident
system("trident fetch -d poseidon_data -f \"*2012_PattersonGenetics*\"")

# filter to a reasonable set of individuals
pat <- poseidonR::read_janno("poseidon_data/2012_PattersonGenetics", validate = F)

pat_filtered <- pat %>%
  dplyr::mutate(
    first_group_name = purrr::map_chr(pat$Group_Name, function(x) { x[1]})
  ) %>%
  dplyr::filter(
    !grepl("Ignore", first_group_name)
  ) 

one_individual_per_group <- pat_filtered %>%
  dplyr::group_by(first_group_name) %>%
  dplyr::filter(dplyr::row_number() == 1) %>%
  

three_individuals_per_group <- pat_filtered %>%
  dplyr::group_by(first_group_name) %>%
  dplyr::filter(dplyr::row_number() %in% 1:3)

# write individual selections to a forgeFiles
tibble::tibble(ind = paste0("<", sort(one_individual_per_group$Individual_ID), ">")) %>% 
  readr::write_delim(
    file = "poseidon_data/ind_list_one_individual_per_group.txt",
    delim = " ",
    col_names = FALSE
  )

tibble::tibble(ind = paste0("<", sort(three_individuals_per_group$Individual_ID), ">")) %>% 
  readr::write_delim(
    file = "poseidon_data/ind_list_three_individuals_per_group.txt",
    delim = " ",
    col_names = FALSE
  )

# forge new packages with only the selected individuals
system("trident forge -d poseidon_data/2012_PattersonGenetics --forgeFile poseidon_data/ind_list_one_individual_per_group.txt -o poseidon_data/patterson_one_individual_per_group -n one --eigenstrat")

system("trident forge -d poseidon_data/2012_PattersonGenetics --forgeFile poseidon_data/ind_list_three_individuals_per_group.txt -o poseidon_data/patterson_three_individuals_per_group -n three --eigenstrat")

# read genotype data into numeric matrices
to_matrix <- function(x) {
  x %>%
  # only select the first X SNPs
  magrittr::extract(1:50000) %>%
    strsplit("") %>%
    t() %>%
    purrr::map(as.numeric) %>%
    purrr::discard(function(x){any(x == 9)}) %>%
    do.call(cbind, .)
}

geno_matrix_one <- scan(
    "poseidon_data/patterson_one_individual_per_group/one.geno", 
    what = "character"
  ) %>% to_matrix()

geno_matrix_three <- scan(
  "poseidon_data/patterson_three_individuals_per_group/three.geno", 
  what = "character"
) %>% to_matrix()

# prepare a useful subset of context information from the .janno files
prep_context <- function(x) {
  x %>%
  tibble::as_tibble() %>%
  dplyr::select(Individual_ID, Group_Name, Country, Longitude, Latitude) %>%
  dplyr::mutate(
    Group_Name = purrr::map_chr(.$Group_Name, function(x) { x[1]}),
    Makro_Region = dplyr::case_when(
      Country == "Pakistan" ~ "South Asia",
      Country == "Congo" ~ "Africa",
      Country == "Central African Republic" ~ "Africa",
      Country == "France" ~ "Europe",
      Country == "Papua New Guinea" ~ "East Asia",
      Country == "Israel" ~ "Near East",
      Country == "Italy" ~ "Europe",
      Country == "Colombia" ~ "Americas",
      Country == "Cambodia" ~ "East Asia",
      Country == "Japan" ~ "East Asia",
      Country == "China" ~ "East Asia",
      Country == "Great Britain" ~ "Europe",
      Country == "Brazil" ~ "Americas",
      Country == "MeCountryico" ~ "Americas",
      Country == "Russia" ~ "Russia",
      Country == "Senegal" ~ "Africa",
      Country == "Nigeria" ~ "Africa",
      Country == "Namibia" ~ "Africa",
      Country == "South Africa" ~ "Africa",
      Country == "Angola" ~ "Africa",
      Country == "Algeria" ~ "Africa",
      Country == "Kenya" ~ "Africa",
      Country == "Mexico" ~ "Americas"
    )
  )
}

context_info_one <- poseidonR::read_janno("poseidon_data/patterson_one_individual_per_group", validate = FALSE) %>% prep_context()

context_info_three <- poseidonR::read_janno("poseidon_data/patterson_three_individuals_per_group", validate = FALSE) %>% prep_context()

# write data to files
write.table(geno_matrix_one, "geno_matrix_one.txt", col.names = F, row.names = F, sep = "")
write.table(context_info_one, "context_info_one.csv", row.names = F, sep = ",")
write.table(geno_matrix_three, "geno_matrix_three.txt", col.names = F, row.names = F, sep = "")
write.table(context_info_three, "context_info_three.csv", row.names = F, sep = ",")
