# This script plots means of VOT baseline vs. shadow for the data previously 
# sliced from "vot_table" using "extract_slices.r".
# ==========================================================================

par(mfrow=c(1, 2))

# Calculate mean VOT values for baseline and shadow data by stop conditions and
# L1 vs L2.

vot_means_l1 <- aggregate(vot_table_l1[c("vot_baseline", "vot_shadow")], 
                   by = list(vot_table_l1$stop), 
                   FUN = mean)
colnames(vot_means_l1) <- c("Stop", "Baseline", "Shadow")

vot_means_l2 <- aggregate(vot_table_l2[c("vot_baseline", "vot_shadow")], 
                          by = list(vot_table_l2$stop), 
                          FUN = mean)
colnames(vot_means_l2) <- c("Stop", "Baseline", "Shadow")

# Create barplots with paired bars.

barplot(height = t(as.matrix(vot_means_l1[, -1])), 
        beside = TRUE, 
        names.arg = vot_means_l1$Stop, 
        ylim=c(0, 100),
        main = "VOT Baseline vs. Shadow (L1)", 
        xlab = "Stop",
        ylab = "Mean VOT Time (ms)",
        legend.text = TRUE,
        args.legend = list(x = "topright", inset = c(0, -0.05)),
        col = c("blue", "red"))

barplot(height = t(as.matrix(vot_means_l2[, -1])), 
        beside = TRUE, 
        names.arg = vot_means_l2$Stop, 
        ylim=c(0, 100),
        main = "VOT Baseline vs. Shadow (L2)", 
        xlab = "Stop",
        ylab = "Mean VOT Time (ms)",
        legend.text = TRUE,
        args.legend = list(x = "topright", inset = c(0, -0.05)),
        col = c("blue", "red"))
