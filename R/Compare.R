library(stars)
library(sf)
library(dplyr)
library(ggplot2)

fil <- here::here("data", "models", "current.RData")
load(fil)
fil <- here::here("data", "models", "future.RData")
load(fil)

points <- data.frame(
  lon = c(-76.33, -76, -76, -75.917, -75.5, -75),
  lat = c(39, 38, 37.5, 37.083, 36.5, 36)
)

# Convert to sf object
pts_sf <- st_as_sf(points, coords = c("lon", "lat"), crs = st_crs(future.predicted))

# Extract predicted values at those coordinates
future_vals  <- st_extract(future.predicted, pts_sf)
future_env <- st_extract(futureenv.stars.crop, pts_sf)
current_vals <- st_extract(current.predicted, pts_sf)
current_env <- st_extract(env.stars.crop, pts_sf)

# Combine results into a single dataframe
comparison <- data.frame(
  lon = points$lon,
  lat = points$lat,
  current = current_vals$pred,
  year2100  = future_vals$pred,
  change  = future_vals$pred - current_vals$pred
)

#plot with occurance
# Plot stars raster + points
ggplot() +
  geom_stars(data = future.predicted) +
  scale_fill_cmocean(
    name = "ice",
    direction = -1,
    guide = guide_colorbar(
      barwidth = 1,
      barheight = 10,
      ticks = FALSE,
      nbin = 1000,
      frame.colour = "black"
    ),
    limits = c(0, 1)
  ) +
  geom_sf(data = pts_sf, size = 3, shape = 21, fill = "red") +
  theme_linedraw() +
  coord_sf() +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Sample Points",
    x = "Longitude",
    y = "Latitude",
    fill = "Probability",
    color = "Point Label"
  )

comparison