# This script plots VOT convergence scores individually, based on data in
# "vot_table" and slices extracted from "vot_table" using "extract_slices.r".
# ===========================================================================

# Plots the convergence scores for the metric "name", based on data in
# "vot_table".
plot_scores <- function(vot_table, name, title_for_all_plots) {
  par(mfrow=c(1, 3))
  
  # Plot distributions of scores for L1 and L2 as boxplots.
  
  boxplot(vot_table[, name] ~ vot_table$interlocutor, xlab="Interlocutor", 
          ylab=name)
  title(title_for_all_plots)
  
  # Plot distributions of scores for L1 as a histogram + density function.
  
  hist(vot_table[vot_table$interlocutor == "L1", name], freq=F, 
       main=c("Distribution of ", name), xlab=c(name, "L1"), ylab="density")
  lines(density(vot_table[vot_table$interlocutor == "L1", name]))
  
  # Plot distributions of scores for L2 as a histogram + density function.
  
  hist(vot_table[vot_table$interlocutor == "L2", name], freq=F, 
       main=c("Distribution of ", name), xlab=c(name, "L2"), ylab="density")
  lines(density(vot_table[vot_table$interlocutor == "L2", name]))
  
  # Wait for a [enter] to continue.
  
  readline(prompt="Press [enter] to continue")
}

plot_scores(vot_table, "did_vot_score", "P+T+K")
plot_scores(vot_table_p, "did_vot_score", "P")
plot_scores(vot_table_t, "did_vot_score", "T")
plot_scores(vot_table_k, "did_vot_score", "K")

plot_scores(vot_table, "nielsen_vot_score", "P+T+K")
plot_scores(vot_table_p, "nielsen_vot_score", "P")
plot_scores(vot_table_t, "nielsen_vot_score", "T")
plot_scores(vot_table_k, "nielsen_vot_score", "K")

plot_scores(vot_table, "shift_vot_score", "P+T+K")
plot_scores(vot_table_p, "shift_vot_score", "P")
plot_scores(vot_table_t, "shift_vot_score", "T")
plot_scores(vot_table_k, "shift_vot_score", "K")
