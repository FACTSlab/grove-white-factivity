# grove-white-factivity

This repository contains the data and Stan code associated with [Factivity, presupposition projection, and the role of discrete knowledge in gradient inference judgments](https://ling.auf.net/lingbuzz/007450) by [Julian Grove](https://juliangrove.github.io/) and [Aaron Steven White](http://aaronstevenwhite.io/).
We also include the data from [Degen and Tonhauser 2021](https://direct.mit.edu/opmi/article/doi/10.1162/opmi_a_00042/106927/Prior-Beliefs-Modulate-Projection), described in the paper, as a submodule.
To properly clone this repository, you should do `git clone --recurse-submodules git@github.com:FACTSlab/grove-white-factivity.git`.
The modeling pipeline is described below.

## The modeling pipeline

All scripts should be run from this directory.
You will need to install `cmdstanr` to fit the models.
You should also install `loo` if you want to compare the WAIC scores of the resulting fits.

### The norming models

(1) Fit the norming-gradient model:
	
	Rscript r\ files/norming\ models/truncation\ models/norming-gradient.r
	
(2) Fit the norming-discrete model (or skip to step (3)):

	Rscript r\ files/norming\ models/truncation\ models/norming-discrete.r

At this point, you can check the ELPDs of the norming-gradient and norming-discrete models in R:

	R
	>>> norming_gradient <- readRDS("r files/norming models/truncation models/results/norming-gradient.rds")
	>>> norming_discrete <- readRDS("r files/norming models/truncation models/results/norming-discrete.rds")
	>>> ll_ng <- norming_gradient$draws("ll")
	>>> ll_nd <- norming_discrete$draws("ll")
	>>> library(loo)
	>>> waic_ng <- waic(ll_ng)
	>>> waic_nd <- waic(ll_nd)
	>>> loo_compare(waic_ng,waic_nd)

(3) Extract the posterior item log-odds means and standard deviations from the norming-gradient model:
	
	Rscript r\ files/norming\ models/truncation\ models/posteriors.r
