library(here)
library(sf)
library(readxl)

# Load LAD and LSOA Boundaries --------------------------------------------

lad_geo <- st_read(here("Day 07 - Accessibility", "data", "lad_may_2025_BGC.geojson"))
lsoa_geo <- st_read(here("Day 07 - Accessibility", "data", "lsoa_2021_BGC.geojson"))


# Load Population Estimates -----------------------------------------------

lsoa_pop <- read_excel(here("Day 07 - Accessibility", "data", "sapelsoabroadage20222024.xlsx"), sheet = "Mid-2024 LSOA 2021", skip = 3)


# Load Metrolink Data -----------------------------------------------------

stops <- st_read(here("Day 07 - Accessibility", "data", "Metrolink_Stops_Functional.kml"),
                 quiet = TRUE) |>
  st_transform(4326)

lines <- st_read(here("Day 07 - Accessibility", "data", "Metrolink_Lines_Functional.kml"),
                 quiet = TRUE) |>
  st_transform(4326)


# Load LSOA Pop Weighted Centroids ----------------------------------------

lsoa_pop_centroids <- read.csv(here("Day 07 - Accessibility", "data", "lsoa_2021_pop_weighted_centroids.csv"))
                               