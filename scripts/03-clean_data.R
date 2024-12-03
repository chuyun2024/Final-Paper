#### Preamble ####
# Purpose: Cleans the US School Shooting data by coverting datatypes to the right ones and extracting each
# component of date columns
# Author: Yun Chu
# Date: 22 November 2022
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 
# - 02-downloaded_data.R must have been run
# Any other information needed? None

#### Workspace setup ####
library(dplyr)
library(arrow)

#### Clean data ####

raw_data <- read.csv("data/01-raw_data/raw_data.csv")

# Work on a copy of the raw data to ensure raw data integrity
analysis_data <- raw_data

# Add a column indicating whether there were casualties
analysis_data$ifcasualty <- ifelse(analysis_data$casualties > 0, 1, 0)

# Create a new column with simplified shooting categories
analysis_data$shooting_category <- ifelse(
  analysis_data$shooting_type %in% c("indiscriminate", "targeted"),
  "indiscriminate or targeted",
  "other"
)

#### Save data ####
write_parquet(analysis_data, "data/02-analysis_data/analysis_data.parquet")
