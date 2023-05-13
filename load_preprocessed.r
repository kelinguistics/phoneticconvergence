# This script loads the pre-processed "preprocessed.csv" table as "vot_table"
# and re-orders levels for the "stop" variable as "P", "T", "K".
# ===========================================================================

vot_table <- read.csv("preprocessed.csv", header=TRUE)
vot_table$stop <- factor(vot_table$stop, levels=c("P", "T", "K"))
