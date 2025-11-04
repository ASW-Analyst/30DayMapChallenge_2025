
# Load packages -----------------------------------------------------------

library(sf)
library(dplyr)
library(leaflet)
library(here)


# Load data and prep route ------------------------------------------------

kml_path <- here("Day 04 - My Data", "data", "turc_run.kml")
layers <- st_layers(kml_path)
route <- st_read(kml_path, quiet = TRUE)

route_lines <- route %>%
  filter(as.character(st_geometry_type(geometry)) %in% c("LINESTRING","MULTILINESTRING"))

st_geometry(route_lines) <- sf::st_zm(st_geometry(route_lines), drop = TRUE, what = "ZM")
route_lines <- route_lines[!sf::st_is_empty(route_lines), , drop = FALSE]

route_points <- route %>%
  filter(as.character(st_geometry_type(geometry)) %in% c("POINT")) |>
  slice(-c(2))


# Create map --------------------------------------------------------------

leaflet() |>
  addProviderTiles(providers$CartoDB.DarkMatter) |>
  addPolylines(data = route_lines, weight = 4, col = "#69db7c") |>
  addCircleMarkers(data = route_points, radius = 5, col = "#4dabf7")
