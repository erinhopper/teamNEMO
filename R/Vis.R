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
fil <- here::here("data", "region", "BoundingBox.shp")
extent_polygon <- sf::read_sf(fil)
bbox <- sf::st_bbox(extent_polygon)

clamp <- TRUE       # see ?predict.maxnet for details
type <- "cloglog"
predicted <- predict(sdm.model, env.stars.crop, clamp = clamp, type = type)

#plot with occurance
ggplot() +
  geom_stars(data = predicted) +
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
       subtitle = "Environmental predictors: mean SS temp, mean SS salinity, mean bathymetry, \nmean pH, mean DO, mean SS chlorophyll-a") +
  geom_point(occ.points, mapping = aes(shape = sci.name, geometry = geometry), stat = "sf_coordinates", alpha = 0.3, color = "purple")
