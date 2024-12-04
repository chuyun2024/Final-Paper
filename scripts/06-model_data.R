#### Preamble ####
# Purpose: Models the relationship between the existence of casualty and shooting type and latitude
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
library(arrow)
### Model data ####

data <- read_parquet("data/02-analysis_data/analysis_data.parquet")

data <- na.omit(data[, c("ifcasualty", "shooting_category", "long", "lat")])


# Fit Bayesian logistic regression
bayes_model <- stan_glm(ifcasualty ~ shooting_category + lat,
                        family = binomial(link = "logit"),
                        data = data,
                        prior = normal(0, 2.5),  # Weakly informative prior
                        prior_intercept = normal(0, 5),
                        chains = 4, iter = 2000)

#### Save model ####
saveRDS(
  bayes_model,
  file = "models/bayes_model.rds"
)


