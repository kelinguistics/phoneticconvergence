# This script plots VOT baseline and VOT shadow distributions for the data in
# "vot_table_with_outliers" and in "vot_table".
# ===========================================================================

par(mfrow=c(2, 2))

boxplot(vot_table_with_outliers$vot_baseline ~ vot_table_with_outliers$stop, 
        xlab="Stop", ylab="VOT Baseline (ms)")
title("Before Outlier Removal")

boxplot(vot_table$vot_baseline ~ vot_table$stop, 
        xlab="Stop", ylab="VOT Baseline (ms)")
title("After Outlier Removal")

boxplot(vot_table_with_outliers$vot_shadow ~ vot_table_with_outliers$stop, 
        xlab="Stop", ylab="VOT Shadow (ms)")
boxplot(vot_table$vot_shadow ~ vot_table$stop, 
        xlab="Stop", ylab="VOT Shadow (ms)")
