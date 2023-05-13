# This script extracts slices of rows from "vot_table" for 
# "P", "T", "K", and "L1" vs. "L2" conditions.
# ========================================================

vot_table_p <- vot_table[vot_table$stop == "P", ]
vot_table_t <- vot_table[vot_table$stop == "T", ]
vot_table_k <- vot_table[vot_table$stop == "K", ]

vot_table_l1 <- vot_table[vot_table$interlocutor == "L1", ]
vot_table_l2 <- vot_table[vot_table$interlocutor == "L2", ]
