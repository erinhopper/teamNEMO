suppressPackageStartupMessages({
  library(maxnet)
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
})

#Loading bounding box for the area of interest
fil <- here::here("data", "region", "BoundingBox.shp")
extent_polygon <- sf::read_sf(fil)
bbox <- sf::st_bbox(extent_polygon)

# presence data
fil <- here::here("data", "raw-bio", "lionfish_sample.csv")
occ.sub <- read.csv(fil)
occ.points <- sf::st_as_sf(occ.sub, coords = c("lon", "lat"), crs = 4326)
head(occ.points)

# absence data
fil <- here::here("data", "raw-bio", "pts_absence.csv")
pts.abs <- read.csv(fil) # X is lon and Y is lat

colnames(pts.abs) <- c("lon","lat")
pts.abs <- na.omit(pts.abs)

abs.points <- sf::st_as_sf(pts.abs, coords = c("lon", "lat"), crs = 4326)

dir_env <- here::here("data", "env")
options(sdmpredictors_datadir = dir_env)
layercodes <- c("BO_bathymean", "BO22_salinitymax_ss", "BO22_chlomean_ss",
                "BO22_tempmean_ss","BO22_tempmin_bdmean", "BO22_temprange_bdmean",
                "BO22_curvelmax_bdmean")
#layercodes <- c("BO_sstmean", "BO_bathymean", "BO22_ph", "BO2_dissoxmean_bdmean", "BO2_salinitymean_ss", "BO2_chlomean_ss")

env <- sdmpredictors::load_layers(layercodes, rasterstack = TRUE)
env.stars <- stars::st_as_stars(env) # convert to stars object
env.stars <- terra::split(env.stars)

occ.env <- stars::st_extract(env.stars, sf::st_coordinates(occ.points)) %>%
  dplyr::as_tibble()

abs.env <- stars::st_extract(env.stars, sf::st_coordinates(abs.points)) %>% 
  dplyr::as_tibble()

occ.env <- na.omit(occ.env)
abs.env <- na.omit(abs.env)

env_df <- rbind(occ.env, abs.env)
pres <- c(rep(1, nrow(occ.env)), rep(0, nrow(abs.env)))
sdm.model <- maxnet::maxnet(pres, env_df)
responses <- plot(sdm.model, type = "cloglog")

env.stars.crop <- env.stars %>% sf::st_crop(bbox)
fil <- here::here("data", "models", "lionfish.RData")
save(sdm.model, env.stars.crop, occ.points, abs.points, file=fil)


