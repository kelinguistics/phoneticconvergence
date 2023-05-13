These files accompany the tutorial and a study on measuring VOT convergence 
scores. Input raw data for the study are stored in two ".csv" tables,
"vot_data.csv" and "model_talker.csv". The tutorial can be run interactively
by stepping through the provider ".r" files in e.g., RStudio. To run the 
tutorial steps top-to-bottom, step through the lines in "run.r".

# Intro

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
