# This script runs all parts of the tutorial in the correct order.
# ================================================================

#install.packages("testit")
#install.packages("ggplot2")
#install.packages("tidyverse")
#install.packages("mgcv")
#install.packages("itsadug")
#install.packages("tidymv")
#install.packages("gridExtra")
#install.packages("lme4")

library(tidyverse)
library(mgcv)
library(itsadug)
library(tidymv)
library(ggplot2)
library(gridExtra)
library(lme4)
library(testit)

# Load, pre-process data, remove outliers and extract data slices.

source("preprocess.r")
source("load_preprocessed.r")
source("remove_outliers.r")
source("extract_slices.r")

# Compute kinds of convergence scores.

source("compute_vot_scores.r")

# Plot the kinds of VOT scores and comparisons between them.

source("plot_vot_distributions.r")
source("plot_vot_means.r")
source("plot_vot_scores.r")
source("plot_vot_scores_comparisons.r")

# Illustrate that DID cannot distinguish between convergence and divergence.

source("plot_vot_convergence_vs_divergence.r")

# Predict VOT scores from the study using linear models.

source("vot_score_linear_models.r")
