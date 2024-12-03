#### Preamble ####
# Purpose: Exploratory Data Analaysis for School Shooting Data
# Author: Yun Chu
# Date: 25 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 03-clean_data.R has been run
# Any other information needed? None


#### Workspace setup ####
library(tidyverse)
library(arrow)

#### Read data ####
data <- read_parquet("data/02-analysis_data/analysis_data.parquet")

# Dimensions of the dataset
dim(data)

# Column names
colnames(data)

# Check data structure
str(data)

# Summary of missing values
colSums(is.na(data))

# Summary for numerical columns
summary(select_if(data, is.numeric))

# Summary for categorical columns
summary(select_if(data, is.character))

# Incidents over Time
ggplot(data, aes(x = date)) +
  geom_histogram(binwidth = 30, fill = 'steelblue', color = 'black') +
  labs(title = "Number of Incidents Over Time", x = "Date", y = "Count") +
  theme_minimal()

# Incidents by State
# Count incidents by state
state_counts <- data %>%
  group_by(state) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

# Plot
ggplot(state_counts, aes(x = reorder(state, count), y = count)) +
  geom_bar(stat = "identity", fill = "tomato") +
  coord_flip() +
  labs(title = "Number of Incidents by State", x = "State", y = "Count") +
  theme_minimal()

# Causaulity Distribution
ggplot(data, aes(x = casualties)) +
  geom_histogram(binwidth = 1, fill = "purple", color = "black") +
  labs(title = "Distribution of Casualties", x = "Number of Casualties", y = "Frequency") +
  theme_minimal()
