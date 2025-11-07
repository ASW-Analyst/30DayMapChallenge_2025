# Day 07 - Accessibility
For today's theme I have mapped the location of tram stops across Greater Manchester. 
This is mapped against the distance from the population weighted centre of each LSOA to its nearest stop, **as the crow flies**.
This demonstrates the areas of Greater Manchester that are less well served by the tram.

The map has been produced in R using the `{leaflet}` package. An interactive version of the map is available [here](https://rpubs.com/andy_wilson_nhstu/gm_tram_30dmc).

## Data Sources

| **Data Item** | **Description** | **Source** |
|---------------|-----------------|------------|
| Metrolink lines and stops location data | Location data for all lines and stops on the Metrolink | [Transport for Greater Manchester](https://www.data.gov.uk/dataset/55576216-cd1d-4e2b-adcf-c87c07473373/gm-metrolink-network?utm_source=chatgpt.com)|
| LSOA Boundaries | Boundaries for all LSOAs in England | [Open Geography Portal](https://geoportal.statistics.gov.uk/datasets/68515293204e43ca8ab56fa13ae8a547_0/explore?location=52.754110%2C-2.489483%2C7.21) |
| Local Authority Boundaries | Boundaries for all Local Authorities in England | [Open Geography Portal](https://geoportal.statistics.gov.uk/datasets/0b8528fb4132495181d82bb65c5e370a_0/explore?location=55.080940%2C-3.316939%2C6.40) |
| LSOA Population Weighted Centroids | Population weighted centroids for each LSOA in England | [Open Geography Portal](https://geoportal.statistics.gov.uk/datasets/79fa1c80981b4e4eb218bbce1afc304b_0/explore) |
| LSOA Population Estimates | Mid-Year 2024 population estimates for each LSOA in England | [Office for National Statistics](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimatesnationalstatistics) |