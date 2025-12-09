#Dealing with spatial data
library(sf)
#Getting base maps
library(rnaturalearth)
#Data manipulation and visualisation
library(tidyverse)
library(janitor)
library(ggspatial)
#We create a bounding box using minimum and maximum coordinate pairs
extent_polygon <- st_bbox(c(xmin = -180, xmax = 180, 
                            ymax = -10, ymin = 45), 
                          #Assign reference system
                          crs = st_crs(4326)) %>% 
  #Turn into sf object
  st_as_sfc()

#Extract polygon geometry 
pol_geometry <- st_as_text(extent_polygon[[1]])

#Saving bounding box for future use
fil <- here::here("data", "region", "BoundingBox.shp")
write_sf(extent_polygon, fil)

#Getting base map
world <- ne_countries(scale = "medium", returnclass = "sf")

#Plotting map
world_box <- ggplot() + 
  #Adding base map
  geom_sf(data = world) +
  #Adding bounding box
  geom_sf(data = extent_polygon, color = "red", fill = NA)+
  #Setting theme of plots to not include a grey background
  theme_bw()
fil <- here::here("data", "region", "world_box.rda")
save(world_box, file=fil)

#world_box

base_region_map <- ggplot()+
  #Adding base layer (world map)
  geom_sf(data = world, fill = "antiquewhite")+
  #Constraining map to original bounding box
  lims(x = c(st_bbox(extent_polygon)$xmin, st_bbox(extent_polygon)$xmax),
       y = c(st_bbox(extent_polygon)$ymin, st_bbox(extent_polygon)$ymax))
fil <- here::here("data", "region", "base_region_map.rda")
save(base_region_map, file=fil)

#base_region_map

region_map <- base_region_map +
  #Add scale bar on the top right of the plot
  annotation_scale(location = "tr", width_hint = 0.5)+
  #Add north arrow on the top left of plot
  annotation_north_arrow(location = "tl", which_north = "true",
                         #Include small buffer from plot edge
                         pad_x = unit(0.01, "in"), pad_y = unit(0.05, "in"),
                         #Set style of north arrow
                         style = north_arrow_fancy_orienteering) +
  #Changing color, type and size of grid lines
  theme(panel.grid.major = element_line(color = gray(.5), linetype = "dashed", linewidth = 0.5), 
        #Change background of map
        panel.background = element_rect(fill = "aliceblue")) +
  labs(x = "longitude", y = "latitude")

fil <- here::here("data", "region", "region_map.rda")
save(region_map, file=fil)

region_map