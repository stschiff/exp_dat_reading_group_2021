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
  ) %>%
  dplyr::group_by(
    first_group_name
  ) %>%
  dplyr::filter(
    dplyr::row_number() == 1#%in% c(1, 2)
  )

# write individual selection to a forgeFile
tibble::tibble(
  ind = paste0("<", sort(pat_filtered$Individual_ID), ">")
) %>% 
  readr::write_delim(
    file = "poseidon_data/poseidon_ind_list.txt",
    delim = " ",
    col_names = FALSE
  )

# forge a new package with only the selected individuals
system("trident forge -d poseidon_data/2012_PattersonGenetics --forgeFile poseidon_data/poseidon_ind_list.txt -o poseidon_data/patterson -n patterson --eigenstrat")

# read genotype data into a numeric matrix
geno_matrix <- scan("poseidon_data/patterson/patterson.geno", what = "character") %>%
  # only select the first X SNPs
  magrittr::extract(1:50000) %>%
  strsplit("") %>%
  do.call(cbind, .) %>%
  apply(., 2, as.numeric)

# prepare a useful subset of context information from the .janno file
context_info <- poseidonR::read_janno("poseidon_data/patterson", validate = FALSE) %>%
  tibble::as_tibble() %>%
  dplyr::select(Individual_ID, Group_Name, Country, Longitude, Latitude) %>%
  dplyr::mutate(
    Group_Name = purrr::map_chr(.$Group_Name, function(x) { x[1]}),
    Makro_Region = dplyr::case_when(
      Country == "Pakistan" ~ "South Asia",
      Country == "Congo" ~ "Sub-Saharan Africa",
      Country == "Central African Republic" ~ "Sub-Saharan Africa",
      Country == "France" ~ "Europe",
      Country == "Papua New Guinea" ~ "South-East Asia",
      Country == "Israel" ~ "Near East",
      Country == "Italy" ~ "Europe",
      Country == "Colombia" ~ "South America",
      Country == "Cambodia" ~ "South-East Asia",
      Country == "Japan" ~ "East Asia",
      Country == "China" ~ "East Asia",
      Country == "Great Britain" ~ "Europe",
      Country == "Brazil" ~ "South America",
      Country == "MeCountryico" ~ "Central America",
      Country == "Russia" ~ "Russia",
      Country == "Senegal" ~ "Sub-Saharan Africa",
      Country == "Nigeria" ~ "Sub-Saharan Africa",
      Country == "Namibia" ~ "Sub-Saharan Africa",
      Country == "South Africa" ~ "Sub-Saharan Africa",
      Country == "Angola" ~ "Sub-Saharan Africa",
      Country == "Algeria" ~ "North Africa",
      Country == "Kenya" ~ "Sub-Saharan Africa"
    )
  )

# write data to files
write.table(geno_matrix, "geno_matrix.txt", col.names = F, row.names = F, sep = "")
write.table(context_info, "context_info.csv", row.names = F, sep = ",")
