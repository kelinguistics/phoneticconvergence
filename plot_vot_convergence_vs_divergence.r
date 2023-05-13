# This script uses linear models to show that "did_score" cannot distinguish 
# between convergence vs. divergence, using data from "vot_table".
# ==========================================================================

# Plan of action:
#
# 1)  split the dataset to points where "baseline - shadow >= 0" (VOT drops, 
#     group A) and "baseline - shadow < 0" (VOT increases, group B).
# 2)  show that we can find a model that predicts group A data using DID:
#       implication is that for the points in group A, when 
#       "baseline - shadow >= 0", DID works "similarly" to the 
#       "baseline - shadow" score, but DID scores are both negative and postive.
# 3)  show that we can find another model that predicts group B data using DID:
#       implication is that for the points in group B, when 
#       "baseline - shadow < 0", DID works "similarly" to the "baseline - shadow"
#       score, but DID scores are both negative and positive.
# 4)  show that when we combine the group A and group B data (as group AB), DID 
#     predicts the "baseline - shadow" value worse.
#       implication is that, when we don't know if "baseline - shadow > 0" or
#       "baseline - shadow < 0", DID cannot predict the "baseline - shadow" 
#       score as well. Therefore, the model has difficulty telling between
#       divergence and convergence.

run_did_prediction <- function(vot_data, name) {
  par(mfrow=c(1, 3))

  group_a <- vot_data[vot_data$vot_baseline - vot_data$vot_shadow >= 0, ]
  group_b <- vot_data[vot_data$vot_baseline - vot_data$vot_shadow < 0, ]
  group_ab <- vot_data

  shadow_to_baseline_a <- group_a$vot_baseline - group_a$vot_shadow
  shadow_to_baseline_b <- group_b$vot_baseline - group_b$vot_shadow
  shadow_to_baseline_ab <- group_ab$vot_baseline - group_ab$vot_shadow
  
  did_score_a <- group_a$did_vot_score
  did_score_b <- group_b$did_vot_score
  did_score_ab <- group_ab$did_vot_score
  
  # Show how for group A, "did_score_a" predicts "shadow_to_baseline_a".
  #
  # Shift always >= 0, DID can be anything.
  
  plot(shadow_to_baseline_a ~ did_score_a, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group A")
  group_a_fit <- lm(shadow_to_baseline_a ~ did_score_a)
  print(group_a_fit)
  abline(group_a_fit, col="red")
  title(c("Shift >= 0", name))
  
  # Show how for group B, "did_score_b" predicts "shadow_to_baseline_b".
  #
  # Shift always < 0, DID can be anything.
  
  plot(shadow_to_baseline_b ~ did_score_b, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group B")
  group_b_fit <- lm(shadow_to_baseline_b ~ did_score_b)
  print(group_b_fit)
  abline(group_b_fit, col="red")
  title(c("Shift < 0", name))
  
  # Show how for group AB, "did_score_ab" *does not* predict 
  # "shadow_to_baseline_ab".
  #
  # Shift can be anything, DID can be anything.
  
  plot(shadow_to_baseline_ab ~ did_score_ab, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group A + B")
  group_ab_fit <- lm(shadow_to_baseline_ab ~ did_score_ab)
  print(group_ab_fit)
  abline(group_ab_fit, col="red")
  title(c("Shift >= 0 or < 0", name))

  summary(lm(group_a_fit)) # moderate residual standard error
  summary(lm(group_b_fit)) # moderate residual standard error
  summary(lm(group_ab_fit)) # larger residual standard error
  
  # Wait for [enter] to continue.
  
  readline(prompt="Press [enter] to continue")
}

run_did_prediction(vot_table, "P+T+K")
run_did_prediction(vot_table_p, "P")
run_did_prediction(vot_table_t, "T")
run_did_prediction(vot_table_k, "K")
