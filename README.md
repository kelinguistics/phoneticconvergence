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
# from plot_vot_scores.r:

# We create a function plot_scores() that plots convergence scores for
# a metric specified as a parameter ("name"), and a slice of data 
# specified as another parameter ("vot_table"). Then we apply this function
# to plot different metrics on different slices of data.

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
}
```

#### Distributions of DID Scores

##### DID (P+T+K)
```
plot_scores(vot_table, "did_vot_score", "P+T+K")
```
<img width="468" alt="did_ptk" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/da61d9c6-3d5d-4334-b6fb-24829599c7b5">

##### DID (P)
```
plot_scores(vot_table_p, "did_vot_score", "P")
```
<img width="468" alt="did_p" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/15879300-01f9-4e21-a844-a3eabe2a1837">

##### DID (T)
```
plot_scores(vot_table_t, "did_vot_score", "T")
```
<img width="468" alt="did_t" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/6c54275f-2fdc-41c3-9f37-b440d009f6e1">

##### DID (K)
```
plot_scores(vot_table_k, "did_vot_score", "K")
```
<img width="468" alt="did_k" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/b1e014c8-94d7-48a2-89e2-35c803f2056d">


#### Distribution of Nielsen Scores

##### Nielsen (P+T+K)
```
plot_scores(vot_table, "nielsen_vot_score", "P+T+K")
```
<img width="468" alt="nielsen_ptk" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/f0ad5e46-986c-457b-9ec5-6e19e4a070b5">

##### Nielsen (P)
```
plot_scores(vot_table_p, "nielsen_vot_score", "P")
```
<img width="468" alt="Nielsen_p" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/9b1464d9-3a3e-44b8-9215-f498bb40fab7">

##### Nielsen (T)
```
plot_scores(vot_table_t, "nielsen_vot_score", "T")
```
<img width="468" alt="Nielsen_T" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/d981d933-9e4f-42b5-991b-2c050e1c448d">

##### Nielsen (K)
```
plot_scores(vot_table_k, "nielsen_vot_score", "K")
```
<img width="468" alt="Nielsen_K" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/4c5beef4-6970-4ddc-9103-d250e6210e78">


#### Distribution of Shift Scores

##### Shadow to Baselline Shift score (P+T+K)
```
plot_scores(vot_table, "shift_vot_score", "P+T+K")
```
<img width="468" alt="shift_ptk" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/8201e5f2-f5bc-423d-a529-ed2e547ae38e">

##### Shadow to Baseline Shift score (P)
```
plot_scores(vot_table_p, "shift_vot_score", "P")
```
<img width="468" alt="shift_p" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/ab4cb8c3-37a8-4d2f-8672-25cd4d58e984">

##### Shadow to Baseline Shift score (T)
```
plot_scores(vot_table_t, "shift_vot_score", "T")
```
<img width="468" alt="shift_t" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/32a84d91-4cd6-4193-be53-caedbe6863ef">

##### Shadow to Baseline Shift score (K)
```
plot_scores(vot_table_k, "shift_vot_score", "K")
```
<img width="468" alt="shift_k" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/ff51eaa0-4571-465c-9efd-3b3810e8a984">


#### Interpretation
While it may be difficult to spot the differences between the shapes while looking briefly, the K stop condition has a different distribution shape for each metric kind.


### Comparisons

To interpret the differences between metrics in a visually more meaningful way, we also do scatter-plots of the observed metric values, and compare the DID and Nielsen scores against the Shadow-to-Baseline Shift scores:

```
# plot_vot_scores_comparisons.r:
#
# This scripts plots DID/Nielsen VOT scores vs. VOT shift scores using the
# data in "vot_table".

# Plot raw VOT score data.
#
# The cross shape for [ did_score, shift_score ] illustrates that
# "did_score" is unable to predict the directionality of convergence (is
# "shift_score >= 0" or "shift_score < 0"?). Specifically, for a given
# "shift_score" on the y axis (which is positive or negative), we get
# associated both positive and negative DID score values.
#
# "did_score" is not a predictor for "shift_score"
# [ VOT shadow to baseline convergence ]

par(mfrow=c(1, 2))
plot(vot_table$did_vot_score, vot_table$shift_vot_score, 
     xlab="DID VOT score", ylab="VOT Shadow to Baseline", pch=1)
plot(vot_table$nielsen_vot_score , vot_table$shift_vot_score, 
     xlab="Nielsen VOT score", ylab="VOT Shadow to Baseline", pch=1)
```

We obtain:

<img width="468" alt="did_vs_nielsen" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/b261a6b6-44c4-450a-a40b-51976b9d4551">

Now, we get to see an interesting phenomenon. While both Nielsen and Shadow-to-Baseline are able to express the directionality of the convergence (i.e., is the VOT value increasing or decreasing from shadow to baseline), the DID metric cannot. Looking at the plot on the left (the cross shape), for example, when the Shadow-to-Baseline shift is positive, the corresponding DID metric can be either positive or negative. Similarly, when the DID metric is positive, the Shadow-to-Baseline shift can be either positive or negative. As such, DID cannot predict the direction of the shift, the Shadow-to-Baseline score.


## Directionality of Convergence
To characterize the DID directionality problem quantitatively, we conduct an additional experiment:
1. We split the dataset to points where "baseline - shadow >= 0" (VOT drops, group A) and "baseline - shadow < 0" (VOT increases, group B).
2. We show that we can find a linear model that predicts group A data using DID. The implication is that for the points in group A, when "baseline - shadow >= 0", DID works "similarly" to the "baseline - shadow" score, but DID scores are both negative and positive.
3. We show that we can find another model that predicts group B data using DID. The implication is that for the points in group B, when "baseline - shadow < 0", DID works "similarly" to the "baseline - shadow" score, but DID scores are both negative and positive.
4. We show that when we combine the group A and group B data (as group AB), DID predicts the "baseline - shadow" value worse (e.g., higher residual error of the fit, higher AIC). The implication is that, when we don't know if "baseline - shadow > 0" or "baseline - shadow < 0", DID cannot predict the "baseline - shadow" score as well. Therefore, the DID score metric has difficulty telling between divergence and convergence.

As before, we apply this experiment to relevant slices of the dataset (P+T+K, P, T, K stops):

```
# from plot_vot_convergence_vs_divergence.r:

# We create a function run_did_prediction() that runs the DID directionality
# experiment for a slice of data specified by a parameter ("vot_table"), and a
# name of this slice specified by another parameter ("name"). Then we apply this 
# function to process different slices of data.

# This function fits linear models to VOT data in the groups A, B, AB.
#
# The data comes from "vot_table", which can be a slice of the full table,
# or the full table. The "name" parameter specifies the printable name of
# the processed data slice.
run_did_prediction <- function(vot_data, name) {
  par(mfrow=c(1, 3))

  group_a <- vot_data[vot_data$vot_baseline - vot_data$vot_shadow >= 0, ]
  group_b <- vot_data[vot_data$vot_baseline - vot_data$vot_shadow < 0, ]
  group_ab <- vot_data

  shadow_to_baseline_a <- group_a$vot_baseline - group_a$vot_shadow
  shadow_to_baseline_b <- group_b$vot_baseline - group_b$vot_shadow
  shadow_to_baseline_ab <- group_ab$vot_baseline - group_ab$vot_shadow
  
  did_score_a <- group_a$did_vot_score
  did_score_b <- group_b$did_vot_score
  did_score_ab <- group_ab$did_vot_score
  
  # Show how for group A, "did_score_a" predicts "shadow_to_baseline_a".
  #
  # Shift always >= 0, DID can be anything.
  
  plot(shadow_to_baseline_a ~ did_score_a, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group A")
  group_a_fit <- glm(shadow_to_baseline_a ~ did_score_a)
  print(group_a_fit)

  abline(group_a_fit, col="red")
  title(c("Shift >= 0", name))
  
  # Show how for group B, "did_score_b" predicts "shadow_to_baseline_b".
  #
  # Shift always < 0, DID can be anything.
  
  plot(shadow_to_baseline_b ~ did_score_b, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group B")
  group_b_fit <- glm(shadow_to_baseline_b ~ did_score_b)
  print(group_b_fit)
  abline(group_b_fit, col="red")
  title(c("Shift < 0", name))
  
  # Show how for group AB, "did_score_ab" *does not* predict 
  # "shadow_to_baseline_ab".
  #
  # Shift can be anything, DID can be anything.
  
  plot(shadow_to_baseline_ab ~ did_score_ab, 
       xlab="DID score", ylab="Shadow to Baseline Shift (ms), Group A + B")
  group_ab_fit <- glm(shadow_to_baseline_ab ~ did_score_ab)
  print(group_ab_fit)
  abline(group_ab_fit, col="red")
  title(c("Shift >= 0 or < 0", name))

  summary(glm(group_a_fit)) # moderate residual, smaller AIC
  summary(glm(group_b_fit)) # moderate residual, smaller AIC
  summary(glm(group_ab_fit)) # larger residual, larger AIC
}
```

```
run_did_prediction(vot_table, "P+T+K")
```
<img width="468" alt="did_ptk_model" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/013df5d0-c085-4e1d-8496-3862fc3e6f9c">

```
run_did_prediction(vot_table_p, "P")
```
<img width="468" alt="did_p_model" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/ad940ffa-d556-4cb9-afce-b56ffe58c091">

```
run_did_prediction(vot_table_t, "T")
```
<img width="468" alt="did_t_model" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/b7ae1fdf-b6fb-4cae-b857-6087bbc842f5">

```
run_did_prediction(vot_table_k, "K")
```
<img width="468" alt="did_k_model" src="https://github.com/klin1208/phoneticconvergence/assets/126110100/555a7df1-989c-4b7c-9150-357c8d106cd3">

For all of the four data slices (P+T+K, P, T, K stops), the residual error of the fit and the AIC is largest for the third model on the right, confirming (4) from the experiment plan. For example, for the K stop data slice, the group A is fit with the residual = 247 and AIC = 1762, the group B is fit with the residual = 131, AIC = 883, and the group AB is fit with the residual = 380, AIC = 2844.

# Predicting Convergence Scores using Other Variables in the VOT Study

We apply the metrics from the tutorial to the data in the original VOT study, and test which VOT convergence metric can be best predicted by linear models in terms of other variables present in our data. In other words, we are evaluating which of the three considered metrics is most “explainable” for the data from our study:

```
# vot_score_linear_models.r:
#
# This script builds linear models to predict VOT convergence scores for the
# VOT score kinds in "vot_table" from other variables in the table.
#
# It shows which variables/conditions in the study can explain the observed
# VOT convergence, and which kind of VOT score can be predicted "best" using 
# linear models for the data in the study. The same predictors are used for
# each model, the difference is in the outcome variable (VOT score) that is
# being predicted.

did_predictor <- glm(
  vot_table$did_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
print(summary(did_predictor)) 
  # AIC: 7868.9 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping
  # the predictors are less than alpha = 0.05). Specifically, "L2" is not 
  # significant.

nielsen_predictor <- glm(
  vot_table$nielsen_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
print(summary(nielsen_predictor))
  # AIC: 8661.1 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping
  # the predictors are less than alpha = 0.05). Specifically, "L2" is not 
  # significant.

shift_predictor <- glm(
  vot_table$shift_vot_score ~ 
  vot_table$vot_baseline + 
  (vot_table$stop) * (vot_table$interlocutor),
  family="gaussian")
summary(shift_predictor) 
  # AIC: 7837.8 (lower is better)
  #
  # "T", "K" are statistically significant predictors (p-values of dropping
  # the predictors are less than alpha = 0.05). Specifically, "L2" is not
  # significant.
  #
  # The linear model is able to predict the "shift VOT score" the best.
```

We found that T and K stops are significant predictors of the VOT convergence score, for all three considered VOT metrics. The Shadow-to-Base Shift metric can be predicted the best (with the highest AIC value) using these predictors. Nielsen score was found to be the most difficult to predict, out of the three metrics that were considered.


# Conclusion
In this tutorial, I presented three different methods for measuring convergence in linguistic performance between shadow and baseline tasks: DID score, Nielsen score, Shadow-to-Base Shift metric. I applied the tutorial to VOT data. While Nielsen score operated similarly to Shadow-to-Base Shift, DID metric could not capture directionality in the shift. I demonstrated that out of the three metrics, the Shadow-to-Base Shift metric was the most “explainable” using the data in the VOT study.


# References
Phillips, S., & Clopper, C. G. (2011, May). Perceived imitation of regional dialects. In 
Proceedings of Meetings on Acoustics 161ASA (Vol. 12, No. 1, p. 060002). Acoustical 
Society of America.

Nielsen, K. (2011). Specificity and abstractness of VOT imitation. Journal of Phonetics, 39(2), 
132-142.

MacLeod, B. (2021). Problems in the Difference-in-Distance measure of phonetic imitation. 
Journal of Phonetics, 87, 101058.

Phillips, S., & Clopper, C. G. (2011, May). Perceived imitation of regional dialects. In 
Proceedings of Meetings on Acoustics 161ASA (Vol. 12, No. 1, p. 060002). Acoustical 
Society of America.

Priva, U. C., & Sanker, C. (2019). Limitations of difference-in-difference for measuring 
convergence. Laboratory Phonology, 10(1).
