#### Preamble ####
# Purpose: Tests the structure and validity of the simulated school shooting dataset.
# Author: Yun Chu
# Date: 22 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 
  # - 00-simulate_data.R must have been run
# Any other information needed? None


#### Workspace setup ####

analysis_data <- read_csv("data/00-simulated_data/simulated_data.csv")

# Test if the data was successfully loaded
if (exists("analysis_data")) {
  message("Test Passed: The dataset was successfully loaded.")
} else {
  stop("Test Failed: The dataset could not be loaded.")
}


#### Test data ####

# Load necessary library
library(dplyr)

# Function to test the simulated dataset
test_simulated_data <- function(data) {
  # 1. Check the structure of the data
  cat("\n--- Structure of the Dataset ---\n")
  str(data)
  
  # 2. Check for missing values
  cat("\n--- Missing Values ---\n")
  missing_summary <- sapply(data, function(x) sum(is.na(x)))
  print(missing_summary)
  
  # 3. Check unique values for categorical variables
  cat("\n--- Unique Values in Categorical Variables ---\n")
  categorical_vars <- c("school_name", "district_name", "school_type", 
                        "shooting_type", "gender_shooter1", "shooter_relationship1")
  for (var in categorical_vars) {
    if (var %in% names(data)) {
      cat("\n", var, ":\n")
      print(table(data[[var]]))
    }
  }
  
  # 4. Check ranges for numerical variables
  cat("\n--- Summary Statistics for Numerical Variables ---\n")
  numerical_vars <- c("enrollment", "killed", "injured", "casualties", "age_shooter1")
  for (var in numerical_vars) {
    if (var %in% names(data)) {
      cat("\n", var, ":\n")
      print(summary(data[[var]]))
    }
  }
  
  # 5. Check date-related variables
  if ("date" %in% names(data)) {
    cat("\n--- Date Variable Checks ---\n")
    cat("Earliest Date:", min(data$date), "\n")
    cat("Latest Date:", max(data$date), "\n")
  }
  
  # 6. Check relationships between variables
  cat("\n--- Variable Relationships ---\n")
  
  # Enrollment should always be >= 0
  if (any(data$enrollment < 0, na.rm = TRUE)) {
    cat("ERROR: Enrollment has negative values!\n")
  } else {
    cat("Enrollment has no negative values.\n")
  }
  
  # Casualties should equal killed + injured
  if ("casualties" %in% names(data) && "killed" %in% names(data) && "injured" %in% names(data)) {
    if (!all(data$casualties == (data$killed + data$injured), na.rm = TRUE)) {
      cat("ERROR: Casualties do not equal killed + injured!\n")
    } else {
      cat("Casualties match killed + injured.\n")
    }
  }
  
  # 7. Visual inspection of distributions
  cat("\n--- Visualizing Key Distributions ---\n")
  hist(data$enrollment, main = "Enrollment Distribution", xlab = "Enrollment", col = "blue")
  hist(data$killed, main = "Killed Distribution", xlab = "Killed", col = "red")
  hist(data$injured, main = "Injured Distribution", xlab = "Injured", col = "green")
}

# Call the function with the simulated data
test_simulated_data(simulated_data)
