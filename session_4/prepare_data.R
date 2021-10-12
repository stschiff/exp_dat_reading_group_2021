library(magrittr)

pat <- poseidonR::read_janno("~/agora/published_data/2012_PattersonGenetics", validate = F)

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
    dplyr::row_number() %in% c(1)#c(1, 2)
  )
  
pat_filtered$Individual_ID

tibble::tibble(
  ind = paste0("<", sort(pat_filtered$Individual_ID), ">")
) %>% 
  readr::write_delim(
    file = "poseidon_ind_list.txt",
    delim = " ",
    col_names = FALSE
  )

# trident forge -d ~/agora/published_data/2012_PattersonGenetics --forgeFile poseidon_ind_list.txt -o patterson -n patterson

hu <- scan("patterson/patterson.geno", what = "character")[1:50000] %>%
  strsplit("") %>%
  do.call(cbind, .) %>%
  apply(., 2, as.numeric)

zu <- poseidonR::read_janno("patterson/")

x <- prcomp(hu)

y <- x$x %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    id = 1:54,
    type = "obs"
  ) %>%
  cbind(zu)

y2 <- y %>% dplyr::mutate(
  makro_region = purrr::map_chr(Country, function(x) { country_hash[[x]] })
)

library(ggplot2)
y2 %>%
  ggplot() +
  geom_point(
    aes(x = PC1, y = PC2, colour = makro_region)
  )

country_hash <- tibble::tribble(
  ~country, ~makro_region,
  "Pakistan" , "South Asia",
  "Congo" , "Sub-Saharan Africa",
  "Central African Republic" , "Sub-Saharan Africa",
  "France", "Europe",
  "Papua New Guinea" , "South-East Asia",
  "Israel" , "Near East",
  "Italy", "Europe",
  "Colombia", "South America",
  "Cambodia", "South-East Asia",
  "Japan", "East Asia",
  "China", "East Asia",
  "Great Britain", "Europe",
  "Brazil", "South America",
  "Mexico", "Central America",
  "Russia", "Russia",
  "Senegal", "Sub-Saharan Africa",
  "Nigeria", "Sub-Saharan Africa",
  "Namibia", "Sub-Saharan Africa",
  "South Africa", "Sub-Saharan Africa",
  "Angola", "Sub-Saharan Africa",
  "Algeria", "North Africa",
  "Kenya", "Sub-Saharan Africa"
) %>% hash::hash(
  keys = .$country,
  values = .$makro_region
)

