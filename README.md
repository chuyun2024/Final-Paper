# 2025 US School Shooting Predictions and Solutions

## Overview

School shootings in the United States pose a critical challenge with far-reaching impacts. This paper employs a Random Forest regression model to predict state-level casualties for 2025 using historical data from 1999 to the present. The findings reveal a positively skewed distribution of casualties, with states like Georgia, California, and Pennsylvania projected to face the highest numbers. These insights highlight the need for targeted interventions, including enhanced school safety measures and stricter gun control policies. By providing actionable predictions, this study aims to inform policies that reduce school shooting casualties and protect vulnerable populations.

## File Structure

The repo is structured as:

-   `data/raw_data` contains the raw data as obtained from The Washington Post.
-   `data/analysis_data` contains the cleaned dataset and the dataset that had outliers removed.
-   `model` contains fitted random forest models. 
-   `other` contains details about LLM chat interactions, and sketches.
-   `paper` contains the files used to generate the paper, including the Quarto document and reference bibliography file, as well as the PDF of the paper. 
-   `scripts` contains the R scripts used to simulate, download and clean data.


## Statement on LLM usage

Aspects of the code and introduction were written with the help of ChatGPT 4. The entire chat history is available in inputs/llms/usage.txt.

