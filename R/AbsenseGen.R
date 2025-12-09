#Deal with spatial data
library(sf)
#Base maps and plotting spatial data
library(rnaturalearth)
library(mapview)
library(raster)
#Data visualisation and manipulation
library(tidyverse)
#Find files easily
library(here)
#Access to OBIS
library(robis)
#SDM
library(sdmpredictors)
library(dismo)
library(ggspatial)

#Setting directories containing input data
dir_data <- file.path(here::here(), "data/raw-bio")
dir_env <- file.path(here::here(), "data/env")

#Loading bounding box for the area of interest
fil <- here::here("data", "region", "BoundingBox.shp")
extent_polygon <- read_sf(fil)

#Extract polygon geometry 
pol_geometry <- st_as_text(extent_polygon$geometry)

#Set default directory for environmental data
options(sdmpredictors_datadir = dir_env)
#Loading bathymetry
env_stack <- load_layers("MS_bathy_5m") %>% 
  #Cropping to our area of interest
  crop(extent_polygon)

#Setting seed for reproducibility
set.seed(43)

#Setting number of background points required
nsamp <- 1000

#Create background points
background <- randomPoints(env_stack, nsamp) %>% 
  #Transform to tibble
  as_tibble() %>% 
  #Transform to sf object
  st_as_sf(coords = c("x", "y"), crs = 4326)

absence_geo <- file.path(dir_data, "absence.geojson")
pts_absence_csv <- file.path(dir_data, "pts_absence.csv")
st_write(background, pts_absence_csv, layer_options = "GEOMETRY=AS_XY", append = FALSE)
  