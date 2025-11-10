
# Load Libraries ----------------------------------------------------------

library(shiny)
library(tidyverse)
library(sf)
library(lubridate)
library(here)
library(leaflet)
library(htmltools)

# Load and Prep Data ------------------------------------------------------

# Load data
tracks <- read_csv(file.path("data",
                             "GPS tracking of honey buzzards in Finland.csv"))

# Clean data - remove missing locations and timestamps
tracks_clean <- tracks |>
  filter(!is.na(`location-lat`),
         !is.na(`location-long`),
         is.na(`algorithm-marked-outlier`)) |>
  mutate(
    timestamp = ymd_hms(timestamp, quiet = TRUE),
    label = paste0(
      "<b>Bird:</b> ", `individual-local-identifier`,
      "<br><b>Time:</b> ", timestamp
    )
  ) |>
  filter(!is.na(timestamp)) |>
  arrange(`individual-local-identifier`, timestamp)

# Filter to Lars
lars <- tracks_clean |>
  filter(`individual-local-identifier` == "Lars") |>
  arrange(timestamp)

start_lon   <- lars$`location-long`[1]
start_lat   <- lars$`location-lat`[1]
start_label <- HTML(paste0(
  "<b>Start (first record)</b><br>",
  "Bird: ", lars$`individual-local-identifier`[1], "<br>",
  "Time: ", format(lars$timestamp[1], "%Y %B %d")
))

# Set boundary limits for Leaflet map
bb <- list(
  xmin = min(lars$`location-long`),
  xmax = max(lars$`location-long`),
  ymin = min(lars$`location-lat`),
  ymax = max(lars$`location-lat`)
)

# UI ----------------------------------------------------------------------

ui <- fluidPage(
  
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")),
  
  titlePanel("Lars — Migration pattern of a European Honey Buzzard"),
  hr(),
  fluidRow(
    column(
      width = 8,
      leafletOutput("map", height = 600)
    ),
    column(
      width = 4,
      tags$h4("Controls"),
      actionButton("play", "▶ Play", class = "btn-primary"),
      actionButton("pause", "⏸ Pause"),
      actionButton("reset", "⏮ Reset"),
      br(), br(),
      sliderInput("speed_ms", "Step delay (ms):",
                  min = 50, max = 1500, value = 250, step = 50),
      checkboxInput("autoloop", "Loop when finished", value = TRUE),
      hr(),
      verbatimTextOutput("status"),
      hr(),
      h3("About the data"),
      p("This app lets you explore the migration route of a specific European Honey Buzzard called Lars. 
        His tracking data has been obtained from ", strong("Movebank:"), "an online database 
        of animal tracking data. Max Planck Institute of Animal tracking data. Max Plank Institute of Animal 
        Behaviour, University of Konstanz."),
      p(tags$a(href = "https://www.movebank.org/", tags$i("https://www.movebank.org/"), target = "_blank")),
      br(),
      p("The data is taken from a study involving the GPS tracking of several European Honey Buzzards. I have 
        filtered the data to map the migration of one specific bird - ", strong("Lars.")),
      hr(),
      h3("How to use the map"),
      p("Use the play button to begin the animation. This will add new tracking data to the map depending on the 
        speed you set using the slider input. You can pause or reset the animation using the controls above. Hovering 
        over the tracking points will show you the timestamp of when these were recorded. As more points are added you 
        can see the migration pattern for Lars from August 2011 to July 2015."),
      hr(),
      h3("Citation"),
      tags$div(
        tags$p(
          tags$b("Reference:")
        ),
        tags$p(
          'Byholm, P, Mirski, P, & Vansteelant, W. (2025). ',
          tags$i('Data from: Study "GPS tracking of honey buzzards in Finland".'),
          ' Movebank Data Repository. ',
          tags$a(
            href = "http://dx.doi.org/10.5441/001/1.335",
            target = "_blank",
            "https://doi.org/10.5441/001/1.335"
          )
        )
      )
    )
  )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  n <- nrow(lars)
  state <- reactiveValues(i = 1, playing = FALSE)
  
  observeEvent(input$play,  { state$playing <- TRUE })
  observeEvent(input$pause, { state$playing <- FALSE })
  observeEvent(input$reset, { state$i <- 1; state$playing <- FALSE })
  
  output$map <- renderLeaflet({
    leaflet() |>
      addProviderTiles(providers$CartoDB.DarkMatter) |>
      fitBounds(bb$xmin, bb$ymin, bb$xmax, bb$ymax) |>
      addCircleMarkers(
        lng = start_lon, lat = start_lat,
        radius = 6, stroke = TRUE, weight = 2,
        color = "#2ecc71", fillOpacity = 1,
        label = start_label, group = "start"
      )
  })
  
  # Animation loop
  observe({
    req(state$playing)
    isolate({
      if (state$i < n) {
        state$i <- state$i + 1
      } else if (isTRUE(input$autoloop)) {
        state$i <- 1
      } else {
        state$playing <- FALSE
      }
    })
    invalidateLater(input$speed_ms)
  })
  
  # Redraw after each step
  observe({
    i <- state$i
    req(i >= 1, i <= n)
    
    pts <- lars[1:i, , drop = FALSE]
    
    leafletProxy("map") |>
      clearGroup("path") |>
      clearGroup("points") |>
      addPolylines(
        lng = pts$`location-long`,
        lat = pts$`location-lat`,
        group = "path",
        weight = 2,
        opacity = 0.7,
        color = "#FFD166"
      ) |>
      addCircleMarkers(
        data = pts,
        lng = ~`location-long`,
        lat = ~`location-lat`,
        radius = 3,
        stroke = FALSE,
        fillOpacity = 0.9,
        color = "#FFD166",
        label = ~lapply(label, HTML),
        group = "points"
      ) |>
      addCircleMarkers(
        lng = pts$`location-long`[i],
        lat = pts$`location-lat`[i],
        radius = 4,
        stroke = TRUE,
        weight = 1,
        color = "#4dabf7",
        fillOpacity = 1,
        group = "points"
      )
  })
  
  output$status <- renderText({
    pretty_time <- format(lars$timestamp[state$i], "%Y %B %d")
    paste0(
      "Points shown: ", state$i, "/", n, "\n",
      "Current time: ", pretty_time
    )
  })
}

shinyApp(ui, server)
