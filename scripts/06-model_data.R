#### Preamble ####
# Purpose: Models the relationship between the existence of casualty and shooting type and longtitude
# Author: Yun Chu
# Date: 30 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: 03-clean_data.R has been run
# Any other information needed? None


#### Workspace setup ####
library(tidyverse)
library(dplyr)
library(rstanarm)
library(pROC)
library(arrow)
library(bayesplot)
### Model data ####

data <- read_parquet("data/02-analysis_data/analysis_data.parquet")

# Step 1: Create a binary response variable
data$ifcasualty <- ifelse(data$casualties> 0, 1, 0)

# Create a new column with simplified categories
data$shooting_category <- ifelse(
  data$shooting_type %in% c("indiscriminate", "targeted"),  
  "indiscriminate or targeted",                              
  "other"
)

data <- na.omit(data[, c("ifcasualty", "shooting_category", "long", "lat")])

#posterior <- as.matrix(bayes_model)
#hist(posterior[, "shooting_categoryother"], main = "Posterior Distribution")

# Fit Bayesian logistic regression
bayes_model <- stan_glm(ifcasualty ~ shooting_category + lat,
                        family = binomial(link = "logit"),
                        data = data,
                        prior = normal(0, 2.5),  # Weakly informative prior
                        prior_intercept = normal(0, 5),
                        chains = 4, iter = 2000)

# Summary of the model
summary(bayes_model)

# Extract posterior probabilities
predicted_probs <- posterior_epred(bayes_model)
data$predicted_prob_bayes <- colMeans(predicted_probs)

# Generate the ROC object
roc_obj <- roc(data$ifcasualty, data$predicted_prob_bayes)


# Calculate the optimal threshold using Youden's Index
optimal_coords <- coords(roc_obj, "best", ret = c("threshold", "specificity", "sensitivity"))


# Extract the optimal threshold value from coords()
optimal_threshold <- as.numeric(optimal_coords["threshold"])

# Display the optimal threshold
cat("Optimal Threshold:", optimal_threshold, "\n")

# Classify using the optimal threshold
data$predicted_class_bayes <- ifelse(data$predicted_prob_bayes > optimal_threshold, 1, 0)

# Confusion matrix
conf_matrix_bayes <- table(Predicted = data$predicted_class_bayes, Actual = data$ifcasualty)
print(conf_matrix_bayes)

# Accuracy
accuracy_bayes <- sum(diag(conf_matrix_bayes)) / sum(conf_matrix_bayes)
cat("Updated Accuracy with Optimal Threshold:", accuracy_bayes, "\n")





# Generate posterior predictive samples
posterior_predictive <- posterior_predict(bayes_model)

# Check dimensions of the posterior predictions
dim(posterior_predictive)  # Rows: posterior samples, Columns: observations


#### Save model ####
saveRDS(
  bayes_model,
  file = "models/bayes_model.rds"
)


# Accuracy using the default 0.5 as threshold
# Get mean predicted probabilities for each observation
data$predicted_prob_bayes <- colMeans(posterior_epred(bayes_model))

# Classify based on a threshold
threshold <- 0.5  # or replace with your calculated optimal threshold
data$predicted_class_bayes <- ifelse(data$predicted_prob_bayes > threshold, 1, 0)


# Confusion matrix
conf_matrix_bayes <- table(Predicted = data$predicted_class_bayes, Actual = data$ifcasualty)
print(conf_matrix_bayes)

# Accuracy
accuracy_bayes <- sum(diag(conf_matrix_bayes)) / sum(conf_matrix_bayes)
cat("Bayesian Logistic Regression Accuracy:", accuracy_bayes, "\n")

