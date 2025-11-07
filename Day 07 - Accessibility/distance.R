library(sf)
library(dplyr)
library(units)

# Create df of coordinates in WGS84 ---------------------------------------
pw_pts <- lsoa_geo_gm |>
  st_drop_geometry() |>
  st_as_sf(coords = c("pw_lon", "pw_lat"), crs = 4326, remove = FALSE)

if (is.na(st_crs(stops))) st_crs(stops) <- 4326

# Reproject to BNG --------------------------------------------------------
pw_pts_27700 <- st_transform(pw_pts, 27700)
stops_27700  <- st_transform(stops, 27700)

# Find Nearest Stop -------------------------------------------------------
nearest_idx <- st_nearest_feature(pw_pts_27700, stops_27700)
dist_m <- st_distance(pw_pts_27700, stops_27700[nearest_idx, ], by_element = TRUE)


# Join back to lsoa_geo_gm ------------------------------------------------
lsoa_geo_gm$nearest_stop <- stops_27700$Name[nearest_idx]
lsoa_geo_gm$dist_km <- set_units(dist_m, "km") |> drop_units()

ns_coords <- st_coordinates(st_geometry(stops_27700)[nearest_idx])
lsoa_geo_gm$nearest_stop_e <- ns_coords[,1]
lsoa_geo_gm$nearest_stop_n <- ns_coords[,2]
