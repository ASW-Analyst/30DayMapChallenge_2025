library(dplyr)

# GM Boundaries -----------------------------------------------------------

lad_geo_gm <- lad_geo |>
  filter(LAD25NM %in% c("Bolton",
                        "Bury",
                        "Manchester",
                        "Oldham",
                        "Rochdale",
                        "Salford",
                        "Stockport",
                        "Tameside",
                        "Trafford",
                        "Wigan"))

lsoa_geo_gm <- lsoa_geo |>
  mutate(LAD_Name = substr(LSOA21NM, 1, nchar(LSOA21NM) - 5)) |>
  filter(LAD_Name %in% c("Bolton",
                         "Bury",
                         "Manchester",
                         "Oldham",
                         "Rochdale",
                         "Salford",
                         "Stockport",
                         "Tameside",
                         "Trafford",
                         "Wigan"))

# Add Population ----------------------------------------------------------

lsoa_pop_reduced <- lsoa_pop |>
  select(`LSOA 2021 Code`, Total)

lsoa_geo_gm <- lsoa_geo_gm |>
  left_join(lsoa_pop_reduced, by = c("LSOA21CD" = "LSOA 2021 Code"))


# Add Pop Weighted Centroids ----------------------------------------------

pts <- st_as_sf(lsoa_pop_centroids, coords = c("x", "y"), crs = 27700)
pts_wgs <- st_transform(pts, 4326)
coords <- st_coordinates(pts_wgs)

lsoa_pop_centroids$pw_lon <- coords[,1]
lsoa_pop_centroids$pw_lat <- coords[,2]

lsoa_pop_centoids_lon_lat <- lsoa_pop_centroids |>
  select(c(LSOA21CD, pw_lon, pw_lat))

lsoa_geo_gm <- lsoa_geo_gm |>
  left_join(lsoa_pop_centoids_lon_lat, by = c("LSOA21CD"))
