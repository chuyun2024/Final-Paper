#### Preamble ####
# Purpose: Simulates a dataset of US School Shooting.
# Author: Yun Chu
# Date: 22 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: The `tidyverse` package must be installed
# Any other information needed? None


#### Workspace setup ####
library(dplyr)
library(lubridate)

#### Simulate data ####
# Set seed for reproducibility
set.seed(123)

# Number of observations to simulate
n <- 100

# Simulate 'uid' as a sequence of unique identifiers
uid <- 1:n

# Simulate 'school_name' as random school names
school_names <- c("Lincoln High School", "Washington Middle School", "Roosevelt Elementary", "Jefferson Academy", "Madison Primary School")
school_name <- sample(school_names, n, replace = TRUE)

# Simulate 'nces_district_id' as random 7-digit numbers (as character strings)
nces_district_id <- sprintf("%07d", sample(1e6:1e7 - 1, n, replace = TRUE))

# Simulate 'district_name' as random district names
district_names <- c("Springfield District", "Riverside District", "Mountain View District", "Lakeside District", "Green Valley District")
district_name <- sample(district_names, n, replace = TRUE)

# Simulate 'date' as random dates between 1999 and 2024
start_date <- as.Date("1999-01-01")
end_date <- as.Date("2024-11-22")
date <- sample(seq(start_date, end_date, by = "day"), n, replace = TRUE)

# Simulate 'school_year' based on 'date'
school_year <- ifelse(month(date) >= 8, paste(year(date), year(date) + 1, sep = "-"), paste(year(date) - 1, year(date), sep = "-"))

# Extract 'year' from 'date'
year <- year(date)

# Simulate 'time' as random times during school hours
time <- format(sample(seq(as.POSIXct("08:00", format = "%H:%M"), as.POSIXct("15:00", format = "%H:%M"), by = "min"), n, replace = TRUE), "%I:%M %p")

# Extract 'day_of_week' from 'date'
day_of_week <- weekdays(date)

# Simulate 'city' and 'state' as random city-state pairs
cities <- c("Springfield", "Riverside", "Mountain View", "Lakeside", "Green Valley")
states <- c("CA", "TX", "FL", "NY", "IL")
city <- sample(cities, n, replace = TRUE)
state <- sample(states, n, replace = TRUE)

# Simulate 'school_type' as 'public' or 'private'
school_type <- sample(c("public", "private"), n, replace = TRUE, prob = c(0.8, 0.2))

# Simulate 'enrollment' as random numbers between 100 and 3000
enrollment <- sample(100:3000, n, replace = TRUE)

# Simulate 'killed' and 'injured' as random numbers
killed <- sample(0:5, n, replace = TRUE, prob = c(0.85, 0.1, 0.03, 0.01, 0.005, 0.005))
injured <- sample(0:10, n, replace = TRUE, prob = c(0.7, 0.15, 0.08, 0.04, 0.02, 0.01, 0.005, 0.005, 0.005, 0.0025, 0.0025))

# Calculate 'casualties' as the sum of 'killed' and 'injured'
casualties <- killed + injured

# Simulate 'shooting_type' as random categories
shooting_type <- sample(c("targeted", "indiscriminate", "accidental"), n, replace = TRUE, prob = c(0.5, 0.3, 0.2))

# Simulate 'age_shooter1' as random ages between 10 and 60
age_shooter1 <- sample(10:60, n, replace = TRUE)

# Simulate 'gender_shooter1' as 'm' or 'f'
gender_shooter1 <- sample(c("m", "f"), n, replace = TRUE, prob = c(0.9, 0.1))

# Simulate 'shooter_relationship1' as random relationships
shooter_relationship1 <- sample(c("student", "staff", "outsider", "unknown"), n, replace = TRUE, prob = c(0.6, 0.1, 0.2, 0.1))

# Simulate 'shooter_deceased1' as TRUE or FALSE
shooter_deceased1 <- sample(c(TRUE, FALSE), n, replace = TRUE, prob = c(0.2, 0.8))

# Simulate 'deceased_notes1' as random notes
deceased_notes1 <- ifelse(shooter_deceased1, sample(c("suicide", "killed by police", "unknown"), n, replace = TRUE), NA)

# Combine all variables into a data frame
simulated_data <- data.frame(
  uid,
  school_name,
  nces_district_id,
  district_name,
  date,
  school_year,
  year,
  time,
  day_of_week,
  city,
  state,
  school_type,
  enrollment,
  killed,
  injured,
  casualties,
  shooting_type,
  age_shooter1,
  gender_shooter1,
  shooter_relationship1,
  shooter_deceased1,
  deceased_notes1,
  stringsAsFactors = FALSE
)

# View the first few rows of the simulated data
head(simulated_data)


#### Save data ####
write_csv(simulated_data, "data/00-simulated_data/simulated_data.csv")
