# This script builds linear models to predict VOT convergence scores for the
# VOT score kinds in "vot_table" from other variables in the table.
#
# It shows which variables/conditions in the study can explain the observed VOT 
# convergence, and which kind of VOT score can be predicted "best" using 
# linear models for the data in the study. The same predictors are used for each
# model, the difference is in the outcome variable (VOT score) that is being
# predicted.
# ==============================================================================

did_predictor <- glm(
  vot_table$did_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
print(summary(did_predictor)) 
  # AIC: 7868.9 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping the 
  # predictors are less than alpha = 0.05). Specifically, "L2" is not 
  # significant.

nielsen_predictor <- glm(
  vot_table$nielsen_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
print(summary(nielsen_predictor))
  # AIC: 8661.1 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping the
  # predictors are less than alpha = 0.05). Specifically, "L2" is not 
  # significant.

shift_predictor <- glm(
  vot_table$shift_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
summary(shift_predictor) 
  # AIC: 7837.8 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping the 
  # predictors are less than alpha = 0.05). Specifically, "L2" is not
  # significant.
  #
  # The linear model is able to predict the "shift VOT score" the best.
