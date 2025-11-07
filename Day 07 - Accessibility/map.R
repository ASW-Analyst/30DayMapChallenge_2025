library(sf)
library(dplyr)
library(leaflet)
library(viridisLite)
library(scales)

pal <- colorNumeric(palette = rev(viridis(7, option = "G")), domain = lsoa$dist_km)

leaflet() |>
  leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
  addMapPane("polys", zIndex = 410) |>
  addMapPane("lines", zIndex = 430) |>
  addMapPane("stops", zIndex = 440) |>
  addProviderTiles(providers$CartoDB.Positron) |>
  addPolygons(data = lad_geo_gm, fillOpacity = 0, color = "#000000", weight = 1) |>
  addPolygons(
    data        = lsoa,
    fillColor   = ~pal(dist_km),
    fillOpacity = 0.5,
    color       = "#555555",
    weight      = 0.6,
    opacity     = 0.5,
    smoothFactor = 0.3,
    popup       = ~sprintf(
      "<b>%s</b><br/>Population (2024): %s<br/>Nearest stop: %s<br/>Distance: %.2f km",
      lsoa$LSOA21NM,
      comma(lsoa$Total),
      lsoa$nearest_stop,
      lsoa$dist_km
    ),
    highlightOptions = highlightOptions(weight = 2, color = "#222222", bringToFront = TRUE),
    group       = "LSOAs (distance to stop)",
    options     = pathOptions(pane = "polys")
  ) |>
  addLegend(
    pal = pal,
    values = lsoa$dist_km,
    title = "Nearest tram stop (km)",
    position = "bottomright",
    labFormat = labelFormat(suffix = " km")
  ) |>
  addPolylines(
    data   = lines |> st_zm(drop = TRUE, what = "ZM"),
    color  = "#000000",
    weight = 6,
    opacity = 0.95,
    group = "Metrolink lines",
    options = pathOptions(pane = "lines")
  ) |>
  addCircleMarkers(
    data        = stops,
    radius      = 5,
    stroke      = TRUE,
    weight      = 1,
    color       = "#111111",
    fillColor   = "#FFD166",
    fillOpacity = 0.95,
    label       = label_stop,
    group       = "Metrolink stops",
    options     = pathOptions(pane = "stops")
  ) |>
  addLayersControl(
    overlayGroups = c("LSOAs (population)", "Metrolink lines", "Metrolink stops"),
    options = layersControlOptions(collapsed = FALSE)
  )
