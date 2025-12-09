library(dplyr)
library(sf)
library(stars)
library(geodata)
library(dismo)
library(lubridate)
library(sdmpredictors)
library(ggplot2)
library(cmocean)
library(janitor)
library(DT)

fil <- here::here("data", "sdmpredictors_data")
options(sdmpredictors_datadir = fil)

#Create a small bounding box using minimum and maximum coordinate pairs
extent_polygon <- st_bbox(c(xmin = -80, xmax = -70, 
                            ymax = 40, ymin = 30), 
                          #Assign reference system
                          crs = st_crs(4326)) %>% 
  #Turn into sf object
  st_as_sfc()

#Extract polygon geometry 
pol_geometry <- st_as_text(extent_polygon[[1]])

#Saving bounding box for future use
fil <- here::here("data", "region", "Chesapeake.shp")
write_sf(extent_polygon, fil)

bbox <- sf::st_bbox(extent_polygon)

# choose marine
env_future_layers <- sdmpredictors::list_layers_future(terrestrial = FALSE, marine = TRUE)
future_layercodes <- c("BO22_RCP45_2100_salinitymax_ss", "BO22_RCP45_2100_chlomean_ss",
                       "BO22_RCP45_2100_tempmean_ss","BO22_RCP45_2100_tempmin_bdmean",
                       "BO22_RCP45_2100_temprange_bdmean", "BO22_RCP45_2100_curvelmax_bdmean")



future_env <- sdmpredictors::load_layers(future_layercodes, rasterstack = FALSE)
bathy_present <- sdmpredictors::load_layers("BO_bathymean")

global_ext <- raster::extent(-180, 180, -90, 90)

future_env_crop <- lapply(future_env, function(x) {
  raster::extend(x, global_ext)
})

all_layers <- raster::stack(future_env_crop)
all_layers <- raster::stack(bathy_present, all_layers)

futureenv.stars <- stars::st_as_stars(all_layers) # convert to stars object
futureenv.stars <- terra::split(futureenv.stars)

names(futureenv.stars) <- c("BO_bathymean", "BO22_salinitymax_ss", "BO22_chlomean_ss",
"BO22_tempmean_ss","BO22_tempmin_bdmean", "BO22_temprange_bdmean",
"BO22_curvelmax_bdmean")

futureenv.stars.crop <- futureenv.stars %>% sf::st_crop(bbox)
