suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(ggplot2)
  library(cmocean)
  library(maxnet)
  library(stars)
})

fil <- here::here("data", "models", "lionfish.RData")
load(fil)

#Loading bounding box for the area of interest
fil <- here::here("data", "region", "Chesapeake.shp")
extent_polygon <- sf::read_sf(fil)
bbox <- sf::st_bbox(extent_polygon)

clamp <- TRUE       # see ?predict.maxnet for details
type <- "cloglog"
future.predicted <- predict(sdm.model, futureenv.stars.crop, clamp = clamp, type = type)

fil <- here::here("data", "models", "future.RData")
save(future.predicted, file=fil)

#plot with occurance
ggplot() +
  geom_stars(data = future.predicted) +
  scale_fill_cmocean(name = "ice", direction = -1, guide = guide_colorbar(barwidth = 1, barheight = 10, ticks = FALSE, nbin = 1000, frame.colour = "black"), limits = c(0, 1)) +
  theme_linedraw() +
  coord_equal() +
  theme(panel.background = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()) +
  labs(title = "Lionfish SDM",
       x = "Longitude",
       y = "Latitude",
       fill = "Probability",
       shape = "Species (presence)",
       subtitle = "Environmental predictors: mean SS temp, mean SS salinity, mean bathymetry, \nmean pH, mean DO, mean SS chlorophyll-a")
