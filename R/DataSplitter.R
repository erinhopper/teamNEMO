library(here)
library(readr)
library(dplyr)

# Path to input file
infile <- here::here("data", "raw-bio", "lionfish_thinned.csv")

# Read data
df <- read_csv(infile)

set.seed(123)  # for reproducibility

# Create 75/25 split
sample_index <- sample(nrow(df), size = 0.75 * nrow(df))

df_sample <- df[sample_index, ]
df_test   <- df[-sample_index, ]

# Output paths
sample_file <- here::here("data", "raw-bio", "lionfish_sample.csv")
test_file   <- here::here("data", "raw-bio", "lionfish_test.csv")

# Write out
write_csv(df_sample, sample_file)
write_csv(df_test,   test_file)

message("Done: sample and test files written.")