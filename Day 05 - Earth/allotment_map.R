library(here)
library(dplyr)
library(sf)
library(leaflet)

greenspace <- st_read(here("Day 05 - Earth", "data", "GB_GreenspaceSite.shp"))
allotment <- greenspace |>
  rename(function_type = function.) |>
  filter(function_type == "Allotments Or Community Growing Spaces") |>
  filter(!st_is_empty(geometry)) |>
  st_zm(drop = TRUE, what = "ZM") |>
  st_simplify(dTolerance = 10) |>
  st_transform(crs = 4326)

leaflet() |>
  addProviderTiles(providers$CartoDB.DarkMatter) |>
  addPolygons(data =allotment, color = "#ffffff", weight = 0.2, fillColor = "#4dabf7",
              fillOpacity = 0.5, popup = ~paste0("<strong>Name: </strong>", distName1))
