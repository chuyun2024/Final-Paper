#### Preamble ####
# Purpose: Models... [...UPDATE THIS...]
# Author: Yun Chu
# Date: 25 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 03-clean_data.R has been run
# Any other information needed? None


#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(randomForest)

#### Read data ####
data <- read_csv("data/02-analysis_data/analysis_data.csv")

### Model data ####

# Add year column and aggregate data by state and year
data <- data %>%
  group_by(state, year) %>%
  summarise(
    killed = sum(killed, na.rm = TRUE),
    injured = sum(injured, na.rm = TRUE),
    casualties = sum(casualties, na.rm = TRUE)
  ) %>%
  ungroup()

# Prepare data for modeling
train_data <- data %>% filter(year <= 2024)

# Convert state to a factor (categorical variable)
train_data <- train_data %>%
  mutate(state = as.factor(state))

# Define features and target variable
X <- train_data %>% select(year, state)
y <- train_data$casualties

# Split data into training and test sets
set.seed(42)
train_indices <- sample(nrow(train_data), 0.8 * nrow(train_data))
X_train <- X[train_indices, ]
y_train <- y[train_indices]
X_test <- X[-train_indices, ]
y_test <- y[-train_indices]

# Train a Random Forest model
rf_model <- randomForest(X_train, y_train, ntree = 300)

# Evaluate the model on the test set
y_pred <- predict(rf_model, newdata = X_test)
mae <- mean(abs(y_test - y_pred))
rmse <- sqrt(mean((y_test - y_pred)^2))

# Print evaluation metrics
cat("Model Evaluation:\n")
cat("Mean Absolute Error (MAE):", mae, "\n")
cat("Root Mean Squared Error (RMSE):", rmse, "\n")

# Prepare future data for 2025 predictions
future_data <- data.frame(
  year = 2025,
  state = unique(train_data$state)  # Predict for all states
)

# Predict casualties for each state in 2025
future_data$predicted_casualties <- predict(rf_model, newdata = future_data)

# Output predictions for each state
cat("\nPredicted Casualties for 2025 (by state):\n")
print(future_data)

#### Save model ####
saveRDS(
  rf_model,
  file = "models/first_model.rds"
)


