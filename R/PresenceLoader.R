#Dealing with spatial data
library(ggplot2)
library(sf)
#Getting base maps
library(rnaturalearth)
#Access to OBIS
library(robis)
#Data manipulation and visualisation
library(tidyverse)
library(janitor)

#Loading bounding box for the area of interest
fil <- here::here("data", "region", "BoundingBox.shp")
extent_polygon <- read_sf(fil)

#Extract polygon geometry 
pol_geometry <- st_as_text(extent_polygon$geometry)

spp <- c("Pterois volitans", "Pterois miles")

obs <- robis::occurrence(spp, startdate = as.Date("2000-01-01"), geometry = pol_geometry)

cols.to.use <- c("occurrenceID", "scientificName", 
                 "decimalLatitude", "decimalLongitude", "coordinateUncertaintyInMeters",
                 "individualCount","lifeStage", "sex",
                 "bathymetry",  "shoredistance", "sst", "sss")
obs <- obs[,cols.to.use]

dir_data <- here::here("data", "raw-bio")
filname <- "lionfish"
obs_csv <- file.path(dir_data, paste0(filname, ".csv"))
obs_geo <- file.path(dir_data, paste0(filname, ".geojson"))
obs_gpkg <- file.path(dir_data, paste0(filname, ".gpkg"))

obs_sf <- obs %>% 
  sf::st_as_sf(
    coords = c("decimalLongitude", "decimalLatitude"),
    crs = st_crs(4326))

readr::write_csv(obs, obs_csv)
sf::write_sf(obs_sf, obs_geo, delete_dsn=TRUE)
sf::write_sf(obs_sf, obs_gpkg, delete_dsn=TRUE)

# subset the occurences to include just those in the water
obs <- obs %>% 
  subset(bathymetry > 0 & shoredistance > 0)

cols <- c("scientificName", "decimalLatitude", "decimalLongitude", "bathymetry", "sst", "sss")
obs.sub <- obs %>% dplyr::select(all_of(cols))
colnames(obs.sub) <- c("sci.name", "lat", "lon", "bathy", "SST", "SSS")


readr::write_csv(obs.sub, obs_csv)
