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

#### Cross-Validation for Residual Calculation ####

# Define cross-validation folds
library(caret)
set.seed(42)
folds <- createFolds(y, k = 5, list = TRUE)

# Calculate residuals for each fold
residuals_all <- numeric()
for (fold in folds) {
  train_idx <- setdiff(seq_len(nrow(train_data)), fold)
  test_idx <- fold
  
  X_train_cv <- X[train_idx, ]
  y_train_cv <- y[train_idx]
  X_test_cv <- X[test_idx, ]
  y_test_cv <- y[test_idx]
  
  # Train Random Forest on CV fold
  rf_model_cv <- randomForest(X_train_cv, y_train_cv, ntree = 300)
  
  # Predict and calculate residuals
  y_pred_cv <- predict(rf_model_cv, newdata = X_test_cv)
  residuals_cv <- y_test_cv - y_pred_cv
  residuals_all[test_idx] <- residuals_cv
}

# Add residuals to the training data
train_data$residuals <- residuals_all

#### Identify and Remove Outliers ####
# Set a threshold for residuals (e.g., absolute residual > 10)
outlier_threshold <- 10
clean_data <- train_data %>% filter(abs(residuals) <= outlier_threshold)

# save clean data after removing outlier
write_csv(clean_data, "data/02-analysis_data/no_outlier_data.csv")

# Verify cleaned data
cat("Number of rows before cleaning:", nrow(train_data), "\n")
cat("Number of rows after cleaning:", nrow(clean_data), "\n")

#### Retrain the Model on Cleaned Data ####
X_clean <- clean_data %>% select(year, state)
y_clean <- clean_data$casualties

# Train-test split
set.seed(42)
train_indices <- sample(nrow(clean_data), 0.8 * nrow(clean_data))
X_train_clean <- X_clean[train_indices, ]
y_train_clean <- y_clean[train_indices]
X_test_clean <- X_clean[-train_indices, ]
y_test_clean <- y_clean[-train_indices]

# Train Random Forest model
rf_model_clean <- randomForest(X_train_clean, y_train_clean, ntree = 300)

# Evaluate the model on the cleaned test set
y_pred_clean <- predict(rf_model_clean, newdata = X_test_clean)
mae_clean <- mean(abs(y_test_clean - y_pred_clean))
rmse_clean <- sqrt(mean((y_test_clean - y_pred_clean)^2))

# Print evaluation metrics for cleaned data
cat("Model Evaluation after Cleaning:\n")
cat("Mean Absolute Error (MAE):", mae_clean, "\n")
cat("Root Mean Squared Error (RMSE):", rmse_clean, "\n")

# Model with outlier removed Residual Plot
hist(y_test_clean - y_pred_clean, breaks = 30, main = "Residuals After Cleaning", xlab = "Residuals")


#### Save model ####
saveRDS(
  rf_model_clean,
  file = "models/rf_model.rds"
)





