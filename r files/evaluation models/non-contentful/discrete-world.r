library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## choose whether bleached or templatic:
which <- "bleached"
## which <- "templatic"

## the directory where your output files will be saved:
output_path <- paste("r files/evaluation models/non-contentful/results-",which,sep="")
## adjust as desired.

## the directory where your factivity files are saved:
factivity_path <- "r files/factivity models/truncation models/results"
## adjust as desired.

## preprocessing:
non_contentful <- read.csv(paste("data/",which,"/",which,".csv",sep="")

## global stuff...

## fixed effects levels:
N_predicate <- length(unique(non_contentful$predicate))

## random effects levels:
N_participant <- length(unique(non_contentful$participant))

## individual experiments...

## non-contentful data:
N_data <- nrow(non_contentful)
predicate <- non_contentful$predicate_number
participant <- non_contentful$participant
y <- non_contentful$response

## discrete-world model posteriors
mu_nu <- readRDS(paste(factivity_path,"discrete-world_mu_nu.rds",sep=""))
sigma_nu <- readRDS(paste(factivity_path,"discrete-world_sigma_nu.rds",sep=""))

data <- list(
    N_predicate=N_predicate,
    N_participant=N_participant,
    N_data=N_data,
    predicate=predicate,
    participant=participant,
    y=y,
    mu_nu=mu_nu,
    sigma_nu=sigma_nu
);

discrete_world_path <- file.path("stan code/evaluation models/non-contentful","discrete_world.stan");

discrete_world <- cmdstan_model(stan_file=discrete_world_path)

## fit the discrete-world model:
fit_discrete_world <- discrete_world$sample(
                                         data=data,
                                         refresh=20,
                                         seed=1337,
                                         chains=4,
                                         parallel_chains=4,
                                         iter_warmup=12000,
                                         iter_sampling=12000,
                                         adapt_delta=0.99,
                                         output_dir=output_path
                                     );

saveRDS(fit_discrete_world,file=paste(output_path,"discrete_world.rds",sep=""),compress="xz")
