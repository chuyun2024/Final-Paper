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
library(lubridate)
library(stringr)
library(arrow)

#### Clean data ####

# Load the dataset
school_shoot_raw_data <- read.csv("data/01-raw_data/raw_data.csv")

# Column explanations from the provided file
column_explanations <- list(
  uid = "Unique identifier",
  nces_school_id = "National Center for Education Statistics unique identifier for the school",
  school_name = "Name of the school",
  nces_district_id = "National Center for Education Statistics unique identifier for the school district",
  district_name = "Name of the school district",
  city = "City where the school is located",
  state = "State where the school is located",
  enrollment = "Total enrollment of the school",
  killed = "Number of individuals killed during the incident",
  injured = "Number of individuals injured during the incident",
  date = "Date of the incident"
)

# Step 1: Inspect the dataset
str(school_shoot_raw_data)
summary(school_shoot_raw_data)
head(school_shoot_raw_data)

# Step 2: Rename columns for consistency
school_shoot_cleaned <- school_shoot_raw_data %>%
  rename(
    uid = uid,
    nces_school_id = nces_school_id,
    school_name = school_name,
    nces_district_id = nces_district_id,
    district_name = district_name,
    city = city,
    state = state,
    enrollment = enrollment,
    killed = killed,
    injured = injured,
    date = date
  )

# Parse and clean the date column
school_shoot_cleaned <- school_shoot_raw_data %>%
  mutate(
    # Parse date from "Month Day, Year" format
    date = mdy(date),
    # Extract year, month, and day
    year = year(date),
    month = month(date, label = TRUE, abbr = TRUE),
    day = day(date)
  )

# Step 3: Process each column based on its description
school_shoot_cleaned <- school_shoot_cleaned %>%
  # Ensure `uid` is a unique identifier
  mutate(uid = as.character(uid)) %>%
  
  # Ensure `nces_school_id` and `nces_district_id` are character strings
  mutate(
    nces_school_id = as.character(nces_school_id),
    nces_district_id = as.character(nces_district_id)
  ) %>%
  
  # Standardize `school_name` and `district_name`
  mutate(
    school_name = str_to_title(school_name),
    district_name = str_to_title(district_name)
  ) %>%
  
  # Standardize `city` and `state`
  mutate(
    city = str_to_title(city),
    state = str_to_upper(state)
  ) %>%
  
  # Ensure `enrollment`, `killed`, and `injured` are numeric
  mutate(
    enrollment = as.numeric(enrollment),
    killed = as.numeric(killed),
    injured = as.numeric(injured)
  ) %>%
  
  # Replace missing `enrollment` values with the median
  mutate(enrollment = ifelse(is.na(enrollment), median(enrollment, na.rm = TRUE), enrollment)) %>%
  
  # Replace missing `killed` and `injured` values with 0
  mutate(
    killed = ifelse(is.na(killed), 0, killed),
    injured = ifelse(is.na(injured), 0, injured)
  ) %>%
  
  # Add `casualties` as the sum of `killed` and `injured`
  mutate(casualties = killed + injured)

# Step 4: Remove duplicates
school_shoot_cleaned <- school_shoot_cleaned %>%
  distinct()

# Step 5: Add documentation of column meanings
attr(school_shoot_cleaned, "column_descriptions") <- column_explanations

# Step 6: Final inspection
glimpse(school_shoot_cleaned)
summary(school_shoot_cleaned)

# Print the column descriptions
cat("\nColumn Descriptions:\n")
for (col in names(column_explanations)) {
  cat(paste0(col, ": ", column_explanations[[col]], "\n"))
}

# Print a few rows of the cleaned dataset
head(school_shoot_cleaned)

#### Save data ####
write_parquet(school_shoot_cleaned, "data/02-analysis_data/analysis_data.parquet")
