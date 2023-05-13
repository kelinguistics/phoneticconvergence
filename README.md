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

