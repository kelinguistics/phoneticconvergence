# This scripts plots DID/Nielsen VOT scores vs. VOT shift scores using the
# data in "vot_table".
# ========================================================================

# Plot raw VOT score data.
#
# The cross shape for [ did_score, shift_score ] illustrates that "did_score" is
# unable to predict the directionality of convergence (is "shift_score >= 0" or
# "shift_score < 0"?). Specifically, for a given "shift_score" on the y axis (which
# is positive or negative), we get associated both positive and negative did
# score values.
#
# "did_score" is not a predictor for "shift_score"
# [ vot shadow to baseline convergence ]

par(mfrow=c(1, 2))
plot(vot_table$did_vot_score, vot_table$shift_vot_score, 
     xlab="DID VOT score", ylab="VOT Shadow to Baseline", pch=1)
plot(vot_table$nielsen_vot_score , vot_table$shift_vot_score, 
     xlab="Nielsen VOT score", ylab="VOT Shadow to Baseline", pch=1)

# Plot smoothed VOT score data.
#
# The plot function lies. It can only plot data that appears like 
# [ x, f(x) + noise ], not multi-modal data. The smoothings work by fitting
# the function f(x) to the [ x, y ] data, but the data we plot has multiple
# "y" modes for each given "x" value. In fact, it shows why "did_score" cannot
# predict directionality of convergence.

#attach(vot_table)
#plot1 <- vot_table %>%
#  ggplot(aes(x=did_vot_score, y=shift_vot_score)) +
#  geom_smooth(method="loess")
#plot2 <- vot_table %>%
#  ggplot(aes(x=nielsen_vot_score, y=shift_vot_score)) +
#  geom_smooth(method="loess")
#grid.arrange(plot1, plot2, ncol = 2) # misleading result, shows only one mode
#detach(vot_table)
