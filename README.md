Files in this repository accompany the tutorial and a study on measuring VOT convergence 
scores. Input raw data for the study are stored in two `.csv` tables,
`vot_data.csv` and `model_talker.csv`. The tutorial can be run interactively
by stepping through the provider `.r` files in e.g., RStudio. To run the 
tutorial steps top-to-bottom, step through the lines in `run.r`.

# Introduction

This tutorial illustrates different methods of measuring phonetic convergence, the degree to which a speaker becomes more similar to a model talker or interlocutor from baseline production to post-exposure production. I examine the following three ways of phonetic convergence: (1) Difference-in-Difference (DID); Nielsen’s percentage of increase (Nielsen, 2011); (3) a Raw Baseline-to-Shadow shift score.

1. Difference-in-Distance or Difference-in-Difference (DID)

This method accounts for changes relative to the model talker from both baseline and shadow blocks. Here is the basic formula, as presented by DID.

The basic formula:	DID = |SR – R| – |Sb – R| (Priva & Sanker, 2019)
SR: speaker’s production after exposure
Sb:  speaker’ baseline production
R: model talker’s production

Alternatively, the DID method has been realized in the following way in Phillips & Clopper (2011):
			DID = |Xtarg - Xbase| - |Xtarg - Xshad|

One strength of the DID approach is that it is able to capture measurements for a wide range of acoustic features (e.g., vowels, voice onset timing, f0,  f0 trajectories), as evident in Phillips and Clopper (2011). Despite this strength, many recent works have critiqued the DID approach for the following problems (Priva & Sanker, 2019; Macleod, 2021):

- Starting point bias: the greater the difference between a shadower’s baseline and the model talker’s production, the greater the convergence.
- Incapable of distinguishing between different trajectories. For example, lack of convergence is sometimes treated the same way as divergence when a speaker over-converges. 
- Prone to overestimate divergence when a subject’s baseline performance is close to the reference value.

2. Nielsen’s percentage of increase (Nielsen 2011)

Nielsen = 100 * (post-exposure/baseline –1)

This method was used in Nielsen’s study measuring VOT convergence by speakers instructed to shadow after hearing words with extended VOT stimuli. The production (measured in milliseconds) in speakers’ post-exposure is therefore already designed to be greater than their baseline production. 

3. Raw Baseline-to-Shadow shift score

Raw Baseline-to-Shadow Shift score = Shadow – Baseline 

To my understanding, this method has not been directly explored in literature. However, I include it here to illustrate how this simpler calculation captures the difference in speaker’s acoustic production. In fact, this metric is directly related to the Nielsen’s percentage because

Baseline-to-Shadow = Shadow - Baseline = Nielsen * Baseline / 100, and 
Nielsen = 100 * Baseline-to-Shadow / Baseline = 100 * (Shadow - Baseline) / Baseline.

In other words, while Nielsen’s score is a relative metric (as a percentage of the value change relative to the Baseline value), the Raw shift score measures the actual difference in the value.

In the following sections, I compare the three methods and evaluate their ability to tell convergence vs. divergence, and predictability by linear models. I will take you on a journey exploring VOT convergence data I collected for my study (further explained in the Data section), and together, we will evaluate how the merits and weaknesses that were found to be true for the above approaches apply to my data.

# Data

The data that I use in the tutorial was previously collected for my study exploring L2 Mandarin speakers’ VOT convergence for the voiceless aspirated stops /p, t, k/ as influenced by their perception of a model talker’s L1 status. In my experiment, participants first recorded their baseline production by reading a wordlist in a sound booth. Then, in a shadow task, contextualized as an escape room activity, participants were instructed to repeat a word following a model talker, whose speech was pre-recorded and delivered via a computer. Half of the participants were assigned to the L1 condition, in which they were led to believe that their model talker was a native speaker of American English. The remaining participants were assigned to the L2 condition, in which they were led to believe that the model talker was an L2 speaker of English, and also a native speaker of Mandarin. I manipulated participants’ beliefs about the L1 vs. L2 status of the model talker by customizing a digital male avatar to match stereotypically white, male features with an English full name for L1, East Asian features. I used a Chinese full name for the L2 condition.

The design of my study was based on the following premises:
1. VOT for Mandarin /p, t, k/ are significantly longer than their counterparts in English (Lisker & Abramson, 1964; Klatt, 1975).
2. Nonnative speakers tend to exhibit greater convergence when they believe the model talker is a native speaker than a nonnative speaker, despite the reality of this model talker’s L1 status or speech (Jiang & Kennison, 2022; Zając & Rojczyk, 2014).

The following variables were relevant for my experiments, and I use them in this tutorial:
1. Stops: P, T, K
2. Interlocutor condition: L1, L2
3. Experimental block: baseline vs. shadow

This tutorial is structured as a sequence of .R files so it can be followed interactively by executing parts of the code in e.g., RStudio. To start, open the `run.r` file and follow the instructions within.

# Setting up

To follow along, and execute parts of the tutorial in RStudio, first load data in RStudio. This part consists of pre-processing, outlier removal, and extracting data for slices of interest that I use to contrast convergence effects in different parts of the dataset (e.g., different stop conditions that may affect the studied variable VOT, etc.).

```
# Load, pre-process data, remove outliers and extract data slices.

source("preprocess.r")
source("load_preprocessed.r")
source("remove_outliers.r")
source("extract_slices.r")
```

Perhaps the most interesting aspects of this setup work worth showing in the document is outlier removal, and extracting slices of the dataset for contrasting. The outlier removal considers P, T, K stop conditions, and baseline and shadow data, as data slices, and applies outlier removal separately to each slice using the `remove_outliers()` function:

```
# remove_outliers.r:
#
# This script removes outliers from the "vot_table" table.
#
# Outliers are rows that contain outlier "vot_baseline" values or outlier
# "vot_shadow" values, considered separately for each "P", "T", "K" stop
# condition. Outlier values are values outside the 
# [ cut_off, 1.0 - cut_off ] quantile range.

# Returns "vot_data" with outliers rows for the "column_name" column
# removed.
# Outliers are computed with respect to the "stop" == requested_stop
# condition.
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
```

For later use in the study, I also extract relevant data slices after outlier removal into new variables:

```
# extract_slices.r:
#
# This script extracts slices of rows from "vot_table" for 
# "P", "T", "K", and "L1" vs. "L2" conditions.

vot_table_p <- vot_table[vot_table$stop == "P", ]
vot_table_t <- vot_table[vot_table$stop == "T", ]
vot_table_k <- vot_table[vot_table$stop == "K", ]

vot_table_l1 <- vot_table[vot_table$interlocutor == "L1", ]
vot_table_l2 <- vot_table[vot_table$interlocutor == "L2", ]
```

# Inspecting Data

Next, we inspect the VOT data that we collected in the study and that we are going to use for the rest of the tutorial:

```
source("plot_vot_distributions.r")
source("plot_vot_means.r")
```

## Plotting VOT Distributions

First, we look at the distributions of VOT values in the baseline and shadow task, separately, and before and after outlier removal:

```
# plot_vot_distributions.r:
#
# This script plots VOT baseline and VOT shadow distributions for the data
# in "vot_table_with_outliers" and in "vot_table".

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
```

We obtain the following plots:

<img width="468" alt="outlier" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/92d773bc-716a-43ba-94e4-5758698fda5c">

## Plotting VOT Means

For better understandability of VOT differences across the data slices, we also plot mean VOT changes from the baseline to the shadow task sidewise:

```
# plot_vot_means.r:
#
# This script plots means of VOT baseline vs. shadow for the data previously 
# sliced from "vot_table" using "extract_slices.r".

par(mfrow=c(1, 2))

# Calculate mean VOT values for baseline and shadow data by stop conditions
# and L1 vs L2.

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
```

We obtain the following bar plots, and we can see that regardless of interlocutor condition (L1 vs. L2), participants VOT measurements dropped from baseline to shadow, which is consistent with the literature on Mandarin VOTs and demonstrating phonetic convergence happens (although we do not yet know to what degree) regardless of my participants’ beliefs about the interlocutor’s native language status.

<img width="468" alt="pic2" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/52dddc01-f9fe-48fb-96f5-2ba5550747fa">

# Convergence Scores

The main focus of this tutorial is to explore different ways of measuring changes in linguistic performance in the baseline and shadow task, and highlight some of their merits and downsides. Here, we are interested in evaluating the performance differences in VOT using common convergence metrics (scores).


## Computing Scores

We consider these three kinds of scores: DID-score, Nielsen score, raw Baseline-to-Shadow shift score. 
To reflect trends in our study data, we first flip the position of “baseline” and “shadow” from the formulae presented in the introduction: we know that our participants’ baseline production has longer time measurements than their shadow position, and we want to use positive scores to characterize this trend.

As such, we use the following definitions for the metrics in experiments:
- DID = |Baseline - Model| - |Shadow - Model|, where Model is the performance of the model speaker,
- Nielsen = 100 * (Baseline / Shadow - 1),
- Shadow-to-Baseline = Baseline - Shadow.

We compute these scores using

```
source("compute_vot_scores.r")
```

containing

```
# compute_vot_scores.r:
#
# This script computes the three kinds of convergence scores for VOT in the
# "vot_table" table.

# Compute difference-in-difference score (DID):
#
# did_score = abs(baseline - model) - abs(shadow - model)
#
# This metric looks at change relative to the model speaker, between
# baseline and shadow task.

vot_table$did_vot_score <- 
  abs(vot_table$vot_baseline - vot_table$vot_model) -
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
# Note that "nielsen_score = 100 * shift_score / shadow" 
# [ "nielsen_score" is a percentage of the change relative to "shadow",
# "shift_score" is absolute change ]

vot_table$shift_vot_score <- vot_table$vot_baseline - vot_table$vot_shadow

# Explore data.

vot_table[20, c("vot_baseline", "vot_shadow", "vot_model", "did_vot_score", 
                "nielsen_vot_score", "shift_vot_score")]
```

## Inspecting Scores

As we expect there to be differences in the metrics, we plot the obtained score values and compare one metric kind against another visually. To follow this part, we execute

```
# Plot the kinds of VOT scores and comparisons between them.

source("plot_vot_scores.r")
source("plot_vot_scores_comparisons.r")
```

### Score distributions

First, we look at the differences in the distributions of the convergence metrics, across different slices of the dataset (P+T+K, P, T, K stop conditions). We simply plot distributions of the metric values for each kind of the metric, and a dataset slice:

```
# plot_vot_scores.r:
#
# This script plots VOT convergence scores individually, based on data in
# "vot_table" and slices extracted from "vot_table" using "extract_slices.r".

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
```






