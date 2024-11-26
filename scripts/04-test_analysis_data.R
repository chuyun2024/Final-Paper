#### Preamble ####
# Purpose: Tests cleaned school shoots data
# Author: Yun Chu
# Date: 22 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 
# 03-clean_data.R has been run
# Any other information needed? None


#### Workspace setup ####
library(dplyr)
library(testthat)
library(arrow)

data <- read_csv("data/02-analysis_data/analysis_data.csv")


#### Test data ####

# Function to test cleaned dataset
test_cleaned_data <- function(data) {
  cat("\n--- Testing Cleaned Dataset ---\n")
  
  # 1. Check the structure of the dataset
  cat("\n--- Dataset Structure ---\n")
  print(str(data))
  
  # 2. Check for missing values
  cat("\n--- Missing Values ---\n")
  missing_values <- sapply(data, function(x) sum(is.na(x)))
  print(missing_values)
  
  # 3. Validate data types for key columns
  cat("\n--- Data Type Validation ---\n")
  expected_types <- list(
    uid = "character",
    nces_school_id = "character",
    school_name = "character",
    nces_district_id = "character",
    district_name = "character",
    date = "Date",
    enrollment = "numeric",
    killed = "numeric",
    injured = "numeric",
    casualties = "numeric"
  )
  for (col in names(expected_types)) {
    if (col %in% names(data)) {
      actual_type <- class(data[[col]])[1]
      cat(paste0(col, ": Expected ", expected_types[[col]], ", Got ", actual_type, "\n"))
      if (actual_type != expected_types[[col]]) {
        cat("ERROR: Data type mismatch in column: ", col, "\n")
      }
    }
  }
  
  # 4. Validate `casualties` consistency
  cat("\n--- Casualties Consistency ---\n")
  casualties_discrepancies <- data %>%
    filter(casualties != (killed + injured)) %>%
    select(uid, killed, injured, casualties)
  if (nrow(casualties_discrepancies) > 0) {
    cat("ERROR: Discrepancies in `casualties` column:\n")
    print(casualties_discrepancies)
  } else {
    cat("`casualties` column is consistent.\n")
  }
  
  # 5. Check date column integrity
  cat("\n--- Date Validation ---\n")
  if ("date" %in% names(data)) {
    invalid_dates <- data %>%
      filter(is.na(date))
    if (nrow(invalid_dates) > 0) {
      cat("ERROR: Invalid dates detected:\n")
      print(invalid_dates)
    } else {
      cat("All dates are valid.\n")
    }
  }
  
  # 6. Check for duplicates
  cat("\n--- Duplicate Check ---\n")
  duplicate_rows <- data %>%
    duplicated()
  if (any(duplicate_rows)) {
    cat("ERROR: Duplicate rows detected.\n")
    print(data[duplicate_rows, ])
  } else {
    cat("No duplicate rows found.\n")
  }
  
  # 7. Summary statistics for numeric columns
  cat("\n--- Summary Statistics ---\n")
  numeric_columns <- data %>%
    select(where(is.numeric))
  print(summary(numeric_columns))
  
  # 8. Validate categorical columns
  cat("\n--- Categorical Column Validation ---\n")
  categorical_columns <- c("school_type", "state", "shooting_type", "gender_shooter1")
  for (col in categorical_columns) {
    if (col %in% names(data)) {
      cat(paste0("\n", col, ":\n"))
      print(table(data[[col]]))
    }
  }
  
  cat("\n--- Testing Completed ---\n")
}

# Test the cleaned dataset
test_cleaned_data(school_shoot_cleaned)
