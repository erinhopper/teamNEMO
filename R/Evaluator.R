suppressPackageStartupMessages({
  library(maxnet)
  library(dplyr)
  library(sf)
  library(stars)
  library(geodata)
  library(dismo)
  library(sdmpredictors)
  library(terra)
})

# ------------------------------------------------------
# 1. LOAD SDM MODEL + ENVIRONMENT LAYERS
# ------------------------------------------------------

fil_model <- here::here("data", "models", "lionfish.RData")
load(fil_model)  
# loads: sdm.model, env.stars.crop, occ.points, abs.points

# env.stars.crop is your predictor raster set (stars object)
# convert stars → terra SpatRaster
env.terra <- terra::rast(env.stars.crop)

# convert terra → raster stack
env.stack <- raster::stack(env.terra)

# ------------------------------------------------------
# 2. LOAD TEST PRESENCE POINTS
# ------------------------------------------------------

fil_test <- here::here("data", "raw-bio", "lionfish_test.csv")
test_df <- read.csv(fil_test)

# Create sf object (same CRS as training)
test.points <- sf::st_as_sf(test_df, coords = c("lon","lat"), crs = 4326)

# ------------------------------------------------------
# 3. EXTRACT ENVIRONMENTAL VARIABLES AT TEST POINTS
# ------------------------------------------------------

test.env <- stars::st_extract(env.stars.crop, sf::st_coordinates(test.points)) %>%
  as_tibble() %>%
  na.omit()

# ------------------------------------------------------
# 4. USE THE SAME ABSENCE/BACKGROUND ENVIRONMENT DATA
#     (abs.env created during training)
# ------------------------------------------------------

abs.env <- abs.env   # from the training script

# ------------------------------------------------------
# 5. RUN EVALUATION
# ------------------------------------------------------

eval <- dismo::evaluate(
  p = test.env,     # predictor values at test presences
  a = abs.env,      # predictor values at background/absences
  model = sdm.model,
  type = "cloglog"
)

# ------------------------------------------------------
# 6. PRINT METRICS
# ------------------------------------------------------

cat("AUC:", eval@auc, "\n")

conf <- eval@confusion
print("Confusion Matrix:")
print(conf)

best_thr <- eval@t[which.max(eval@TPR + eval@TNR)]

# Find closest row in @t
thr_vec <- eval@t
idx <- which.min(abs(thr_vec - best_thr))

tp <- conf[idx, 1]
fn <- conf[idx, 2]
tn <- conf[idx, 3]
fp <- conf[idx, 4]

rec <- tp / (tp + fn)
acc <- (tp + tn) / (tp + tn + fn + fp)
prec <- tp / (tp + fp)
f1 <- (2 * tp) / (2 * tp + fp + fn)

cat("Recall: ", rec, "\n")
cat("Accuracy: ", acc, "\n")
cat("Precision: ", prec, "\n")
cat("F1 Score: ", f1, "\n")


# world polygons
world <- vect("https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_110m_admin_0_countries.geojson")

plot(world, col = "gray90", border = "gray30")
points(test.points, col = "red", pch = 20)
points(occ.points, col = "red", pch = 20)
points(pts.abs, col = "blue", pch = 20)

