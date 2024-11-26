#### Preamble ####
# Purpose: Downloads and saves the data from the Washington Post's Github
# Author: Yun Chu
# Date: 22 November 2024
# Contact: yun.chu@mail.utoronto.ca
# License: CC BY-NC-SA 4.0
# Pre-requisites: None
# Any other information needed? None


#### Workspace setup ####

library(tidyverse)
library(readr)

#### Download data ####
school_shoot_raw_data <- read.csv("https://raw.githubusercontent.com/washingtonpost/data-school-shootings/master/school-shootings-data.csv")

#### Save data ####
write_csv(school_shoot_raw_data, "data/01-raw_data/raw_data.csv") 

         
