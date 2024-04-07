# grove-white-factivity

This repository contains the data and Stan code associated with [Factivity, presupposition projection, and the role of discrete knowledge in gradient inference judgments](https://ling.auf.net/lingbuzz/007450) by [Julian Grove](https://juliangrove.github.io/) and [Aaron Steven White](http://aaronstevenwhite.io/).
We also include the data from [Degen and Tonhauser 2021](https://direct.mit.edu/opmi/article/doi/10.1162/opmi_a_00042/106927/Prior-Beliefs-Modulate-Projection), described in the paper, as a submodule.
To properly clone this repository, you should do `git clone --recurse-submodules git@github.com:FACTSlab/grove-white-factivity.git`.
The modeling pipeline is described below.

## The modeling pipeline

All scripts should be run from this directory.
You will need to install `cmdstanr`.

### The norming models

Fit the norming-gradient model:

```Rscript r\ files/norming\ models/truncation\ models/norming-gradient.r```
