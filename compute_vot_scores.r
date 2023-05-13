# This script computes the tree kinds of convergence scores for VOT in the
# "vot_table" table.
# ========================================================================

# Compute difference-in-difference score (DID):
#
# did_score = abs(baseline - model) - abs(shadow - model)
#
# This metric looks at change relative to the model speaker, between
# baseline and shadow task.

vot_table$did_vot_score <- abs(vot_table$vot_baseline - vot_table$vot_model) -
  abs(vot_table$vot_shadow - vot_table$vot_model)

# Compute Nielsen convergence score:
#
# nielsen_score = 100 * (baseline / shadow - 1)
#
# This metric does not consider the model speaker performance. Note that
# we use "baseline / shadow" (not the other way around), because in our
# data "baseline" tends to be *larger* than "shadow" (which is the
# opposite trend of what Nielsen had in her paper).

vot_table$nielsen_vot_score <- 
  100 * (vot_table$vot_baseline / vot_table$vot_shadow - 1)

# Compute shift convergence score:
#
# shift_score = baseline - shadow.
#
# This metric also does not consider the model speaker performance.
#
# Note that "nielsen_score = 100 * shift_score / shadow" [ "nielsen_score" is
# a percentage of the change relative to "shadow", "shift_score" is
# absolute change ]

vot_table$shift_vot_score <- vot_table$vot_baseline - vot_table$vot_shadow

# Explore data.

vot_table[20, c("vot_baseline", "vot_shadow", "vot_model", "did_vot_score", 
                "nielsen_vot_score", "shift_vot_score")]
