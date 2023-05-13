# This script removes outliers from the "vot_table" table.
#
# Outliers are rows that contain outlier "vot_baseline" values or outlier
# "vot_shadow" values, considered separately for each "P", "T", "K" stop
# condition. Outlier values are values outside the [ cut_off, 1.0 - cut_off ]
# quantile range.

# Returns "vot_data" with outliers rows for the "column_name" column removed.
# Outliers are computed with respect to the "stop" == requested_stop condition.
remove_outliers <- function(vot_data, column_name, requested_stop) {
  cut_off <- 0.025
  top_q <- 
    quantile(vot_data[vot_data$stop == requested_stop, column_name], 
             1.0 - cut_off)
  bottom_q <- 
    quantile(vot_data[vot_data$stop == requested_stop, column_name],
             cut_off)
  inlier_vot_data <- 
    vot_data[vot_data[, column_name] >= bottom_q & 
               vot_data[, column_name] <= top_q, ]
  return (inlier_vot_data)
}

vot_table_with_outliers <- vot_table

vot_table <- remove_outliers(vot_table, "vot_baseline", "P")
vot_table <- remove_outliers(vot_table, "vot_baseline", "T")
vot_table <- remove_outliers(vot_table, "vot_baseline", "K")

vot_table <- remove_outliers(vot_table, "vot_shadow", "P")
vot_table <- remove_outliers(vot_table, "vot_shadow", "T")
vot_table <- remove_outliers(vot_table, "vot_shadow", "K")
