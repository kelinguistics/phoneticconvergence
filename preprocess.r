# This script pre-processes data from input "vot_data.csv" and 
# "model_talker.csv" into output "preprocessed.csv".
#
# The pre-processing consists of:
#   - merging the data from both input tables.

# Load raw "vot_data" and "model_talker" tables.

vot_data <- read.csv("vot_data.csv", header=TRUE)
model_talker <- read.csv("model_talker.csv", header=TRUE)

# Preprocess "vot_data".

vot_data_edited <- vot_data[order(
  vot_data$word, vot_data$stop, vot_data$interlocutor, vot_data$participant),]

assert("Error sorting vot_data", nrow(vot_data_edited) == nrow(vot_data))
head(vot_data_edited, 20)

# Preprocess "model_talker", transform times to milliseconds.

model_talker_edited <- 
  model_talker[,c("word", "phoneme", "VOT", "followingVowel", "vowelDuration")]
colnames(model_talker_edited) <- 
  c("word", "stop", "vot_model", "following_vowel_model", "vowel_duration_model")

model_talker_edited$vot_model <- 1000.0 * model_talker_edited$vot_model

model_talker_edited <- model_talker_edited[order(
  model_talker_edited$word, model_talker_edited$stop),]

assert("Error sorting model_talker",
       nrow(model_talker_edited) == nrow(model_talker))

# Merge "vot_data" with "model_talker" data.

vot_data_with_model_edited <- 
  merge(vot_data_edited, model_talker_edited, by = c("word", "stop"), 
        all.x=TRUE, all.y=FALSE, sort=TRUE)
vot_data_with_model_edited <- vot_data_with_model_edited[order(
  vot_data_with_model_edited$word, vot_data_with_model_edited$stop, 
  vot_data_with_model_edited$interlocutor, 
  vot_data_with_model_edited$participant),]

assert("Error merging vot_data and model_talker",
       nrow(vot_data_edited) == nrow(vot_data_with_model_edited))
mean(vot_data$vot_shadow)
mean(vot_data_with_model_edited$vot_shadow)

# Drop rows without model data.

vot_table <- 
  vot_data_with_model_edited[!is.na(vot_data_with_model_edited$vot_model), ]

assert("Error in deleting rows without model speaker data",
       nrow(vot_table) <= nrow(vot_data_with_model_edited))

# Save the resulting merged and cleaned table.

write.csv(vot_table, "preprocessed.csv")
