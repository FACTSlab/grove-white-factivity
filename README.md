# grove-white-factivity

This repository contains the data and models associated with [Factivity, presupposition projection, and the role of discrete knowledge in gradient inference judgments](https://ling.auf.net/lingbuzz/007450) by [Julian Grove](https://juliangrove.github.io/) and [Aaron Steven White](http://aaronstevenwhite.io/).
We also include the data from [Degen and Tonhauser 2021](https://direct.mit.edu/opmi/article/doi/10.1162/opmi_a_00042/106927/Prior-Beliefs-Modulate-Projection), described in the paper, as a submodule.

To properly clone this repository, you should do `git clone --recurse-submodules git@github.com:FACTSlab/grove-white-factivity.git`.

## Installation

Two R packages are required:
 - [`cmdstanr`](https://mc-stan.org/cmdstanr/reference/cmdstanr-package.html) (to fit the models)
 - [`loo`](https://cran.r-project.org/web/packages/loo/index.html) (to analyze the results)

## The modeling pipeline

All scripts should be run from this directory.

### The norming models

To fit the norming models and extract the posteriors of the norming-gradient model, run:

	Rscript fits/norming/truncation/norming-models.r

You can check and compare the ELPDs of the norming-gradient and norming-discrete models in R:
	
	library(loo);
	model_dir <- "fits/norming/truncation/results/";
	model_names <- c("norming-gradient","norming-discrete");
	model_waic <- list();
	for (n in model_names) {
		model_path <- paste0(model_dir,n,".rds");
		model_fit <- readRDS(model_path);
		model_waic <- c(model_waic,list(waic(model_fit$draws("ll"))));
	}
	loo_compare(model_waic);

### The factivity models

To fit the four factivity models and extract their posteriors, run:

	Rscript fits/factivity/truncation/factivity-models.r

You can check and compare the ELPDs of the four models in R:
	
	library(loo);
	model_dir <- "fits/factivity/truncation/results/";
	model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");
	model_waic <- list();
	for (n in model_names) {
		model_path <- paste0(model_dir,n,".rds");
		model_fit <- readRDS(model_path);
		model_waic <- c(model_waic,list(waic(model_fit$draws("ll"))));
	}
	loo_compare(model_waic);

### Modeling the replication data

To fit the four models of the replication data, run:

	Rscript fits/evaluation/replication/replication-models.r

You can check and compare the ELPDs of the four model evaluations in R as above, but instead use:

	model_dir <- "fits/evaluation/replication/results/";

### Modeling the bleached/templatic data

Make sure to un-comment line 6 or 7 in `non-contentful-models.r`, depending on whether you want to use the bleached or templatic data.
To fit the four models of the data, run:

	Rscript fits/evaluation/non-contentful/non-contentful-models.r

You can check and compare the ELPDs of the four model evaluations on the bleached/templatic data in R as above.
To define the relevant directory, use the following, (un-)commenting as appropriate:

	which <- "bleached";
	# which <- "templatic";
	model_dir <- paste0("fits/evaluation/non-contentful/results-",which,"/");
