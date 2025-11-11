
# Load packages -----------------------------------------------------------

library(here)
library(readxl)
library(sf)
library(dplyr)
library(ggplot2)
library(scales)


# Load and Prep Data ------------------------------------------------------

pop_density <- read_excel(here("Day 11 - Minimal", "data", "aus_pop_density.xlsx")) |>
  mutate(`SA2 code` = as.character(`SA2 code`))

sa2 <- st_read(here("Day 11 - Minimal", "data", "SA2_2021_AUST_GDA2020.shp"))

geo_pop_density <- sa2 |>
  left_join(pop_density, by = c("SA2_CODE21" = "SA2 code")) |>
  mutate(density = case_when(est_res_pop_24 > 0 ~ as.numeric(est_res_pop_24) / as.numeric(km2),
                             TRUE ~ 0)
  )


# Create Minimal Map ------------------------------------------------------

ggplot(geo_pop_density) +
  geom_sf(aes(fill = density), linewidth = 0, colour = NA) +
  scale_fill_viridis_c(option = "E", trans = "log10", na.value = "#f1f1f1",
                       name = expression("People per "~km^2),
                       breaks = c(0.1, 10, 100, 1000, 10000),
                       labels = comma) +
  coord_sf(datum = NA) +
  theme_void(base_family = "sans") +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"),
        plot.caption = element_text(size = 10, colour = "#666666")) +
  labs(title = "Estimated Australia 2024 population density for each SA2 boundary",
       caption = "Source: Australian Bureau of Statistics Estimated Resident Population; ASGS SA2 2021 boundaries") +
  guides(fill = guide_colorbar(direction = "horizontal",
                               title.position = "top",
                               barwidth = unit(12, "cm"),
                               barheight = unit(0.4, "cm")))
