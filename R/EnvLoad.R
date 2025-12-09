library(ggplot2)
library(sdmpredictors)
library(DT)
library(sf)
library(sp)
library(raster)

dir_env <- here::here("data", "env")
options(sdmpredictors_datadir = dir_env)

# choose marine
env_datasets <- sdmpredictors::list_datasets(terrestrial = FALSE, marine = TRUE)
layercodes <- c("BO_bathymean", "BO22_salinitymax_ss", "BO22_chlomean_ss",
                "BO22_tempmean_ss","BO22_tempmin_bdmean", "BO22_temprange_bdmean",
                "BO22_curvelmax_bdmean")

env <- sdmpredictors::load_layers(layercodes)

#Loading bounding box for the area of interest
fil <- here::here("data", "region", "BoundingBox.shp")
extent_polygon <- read_sf(fil)

io.rast <- raster::crop(env, raster::extent(extent_polygon))
plot(io.rast)

# presence data
fil <- here::here("data", "raw-bio", "lionfish.csv")
df.occ <- read.csv(fil)

# absence data
fil <- here::here("data", "raw-bio", "pts_absence.csv")
df.abs <- read.csv(fil)
colnames(df.abs) <- c("lon", "lat")

df.abs <- na.omit(df.abs) # just in case
sf.abs <- sf::st_as_sf(df.abs, coords = c("lon", "lat"), crs = 4326)
sf.occ <- sf::st_as_sf(df.occ, coords = c("lon", "lat"), crs = 4326)

env.stars <- stars::st_as_stars(env) # convert to stars object
env.stars <- terra::split(env.stars)

env.abs <- stars::st_extract(env.stars, sf::st_coordinates(sf.abs)) %>% 
  dplyr::as_tibble() %>% 
  na.omit()

head(env.abs)

env.occ <- stars::st_extract(env.stars, sf::st_coordinates(sf.occ)) %>% 
  dplyr::as_tibble() %>% 
  na.omit()

head(env.occ)

pres <- c(rep(1, nrow(env.occ)), rep(0, nrow(env.abs)))
sdm_data <- data.frame(pa = pres, rbind(env.occ, env.abs))
head(sdm_data)

fil <- here::here("data", "raw-bio", "sdm_data.csv")
write.csv(sdm_data, row.names = FALSE, file=fil)