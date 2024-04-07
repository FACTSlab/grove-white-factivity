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

Make sure to un-comment line 3 of this R file if you are running `cmdstanr` for the first time.
	
(2) Fit the norming-discrete model (or skip to step (3)):

	Rscript r\ files/norming\ models/truncation\ models/norming-discrete.r

At this point, you can check and compare the ELPDs of the norming-gradient and norming-discrete models in R:

	norming_gradient <- readRDS("r files/norming models/truncation models/results/norming-gradient.rds")
	norming_discrete <- readRDS("r files/norming models/truncation models/results/norming-discrete.rds")
	ll_ng <- norming_gradient$draws("ll")
	ll_nd <- norming_discrete$draws("ll")
	library(loo)
	waic_ng <- waic(ll_ng)
	waic_nd <- waic(ll_nd)
	loo_compare(waic_ng,waic_nd)

(3) Extract the posterior item log-odds means and standard deviations from the norming-gradient model:
	
	Rscript r\ files/norming\ models/truncation\ models/posteriors.r

### The factivity models

(4) Fit the discrete-factivity model:

	Rscript r\ files/factivity\ models/truncation\ models/discrete-factivity.r
	
(5) Fit the wholly-gradient model:

	Rscript r\ files/factivity\ models/truncation\ models/wholly-gradient.r
	
(6) Fit the discrete-world model:

	Rscript r\ files/factivity\ models/truncation\ models/discrete-world.r
	
(7) Fit the wholly-discrete model:

	Rscript r\ files/factivity\ models/truncation\ models/wholly-discrete.r
		
You can now check and compare the ELPDs of all four models in R:

	discrete_factivity <- readRDS("r files/factivity models/truncation models/results/discrete-factivity.rds")
	wholly_gradient <- readRDS("r files/factivity models/truncation models/results/wholly-gradient.rds")
	discrete_world <- readRDS("r files/factivity models/truncation models/results/discrete-world.rds")
	wholly_discrete <- readRDS("r files/factivity models/truncation models/results/wholly-discrete.rds")
	ll_df <- discrete_factivity$draws("ll")
	ll_wg <- wholly_gradient$draws("ll")
	ll_dw <- discrete_world$draws("ll")
	ll_wd <- wholly_discrete$draws("ll")
	library(loo)
	waic_df <- waic(ll_df)
	waic_wg <- waic(ll_wg)
	waic_dw <- waic(ll_dw)
	waic_wd <- waic(ll_wd)
	loo_compare(waic_df,waic_wg,waic_dw,waic_wd)

(8) Extract the posterior log-odds means and standard deviations from the four models:

	Rscript r\ files/factivity\ models/truncation\ models/posteriors.r

### Modeling the replication data

(9) Fit the discrete-factivity evaluation model:

	Rscript r\ files/evaluation\ models/replication/discrete-factivity.r
	
(10) Fit the wholly-gradient evaluation model:

	Rscript r\ files/evaluation\ models/replication/wholly-gradient.r
	
(11) Fit the discrete-world evaluation model:

	Rscript r\ files/evaluation\ models/replication/discrete-world.r
	
(12) Fit the wholly-discrete evaluation model:

	Rscript r\ files/evaluation\ models/replication/wholly-discrete.r

You can now check and compare the ELPDs of all four models in R:

	discrete_factivity <- readRDS("r files/evaluation models/replication/results/discrete-factivity.rds")
	wholly_gradient <- readRDS("r files/evaluation models/replication/results/wholly-gradient.rds")
	discrete_world <- readRDS("r files/evaluation models/replication/results/discrete-world.rds")
	wholly_discrete <- readRDS("r files/evaluation models/replication/results/wholly-discrete.rds")
	ll_df <- discrete_factivity$draws("ll")
	ll_wg <- wholly_gradient$draws("ll")
	ll_dw <- discrete_world$draws("ll")
	ll_wd <- wholly_discrete$draws("ll")
	library(loo)
	waic_df <- waic(ll_df)
	waic_wg <- waic(ll_wg)
	waic_dw <- waic(ll_dw)
	waic_wd <- waic(ll_wd)
	loo_compare(waic_df,waic_wg,waic_dw,waic_wd)

### Modeling the bleached/templatic data

Make sure to un-comment line 6 or 7 in each file, depending on which dataset you wish to use.

(13) Fit the discrete-factivity evaluation model:

	Rscript r\ files/evaluation\ models/non-contentful/discrete-factivity.r
	
(14) Fit the wholly-gradient evaluation model:

	Rscript r\ files/evaluation\ models/non-contentful/wholly-gradient.r
	
(15) Fit the discrete-world evaluation model:

	Rscript r\ files/evaluation\ models/non-contentful/discrete-world.r
	
(16) Fit the wholly-discrete evaluation model:

	Rscript r\ files/evaluation\ models/non-contentful/wholly-discrete.r

You can now check and compare the ELPDs of all four models in R (bleached, in this case):

	discrete_factivity <- readRDS("r files/evaluation models/non-contentful/results-bleached/discrete-factivity.rds")
	wholly_gradient <- readRDS("r files/evaluation models/non-contentful/results-bleached/wholly-gradient.rds")
	discrete_world <- readRDS("r files/evaluation models/non-contentful/results-bleached/discrete-world.rds")
	wholly_discrete <- readRDS("r files/evaluation models/non-contentful/results-bleached/wholly-discrete.rds")
	ll_df <- discrete_factivity$draws("ll")
	ll_wg <- wholly_gradient$draws("ll")
	ll_dw <- discrete_world$draws("ll")
	ll_wd <- wholly_discrete$draws("ll")
	library(loo)
	waic_df <- waic(ll_df)
	waic_wg <- waic(ll_wg)
	waic_dw <- waic(ll_dw)
	waic_wd <- waic(ll_wd)
	loo_compare(waic_df,waic_wg,waic_dw,waic_wd)
