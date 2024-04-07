library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_path <- "r files/factivity models/truncation models/results"
## adjust as desired.

## preprocessing:
replication <- read.csv("data/replication/replication.csv")

## global stuff...

## fixed effects levels:
N_predicate <- length(unique(replication$predicate))
N_context <- length(unique(replication$context))

## random effects levels:
N_participant <- length(unique(replication$participant))

## individual experiments...

## replication data:
N_data <- nrow(replication)
predicate <- replication$predicate_number
context <- replication$context_number
participant <- replication$participant
y <- replication$response

## discrete-factivity model posteriors:
mu_nu <- readRDS(paste(factivity_path,"discrete-factivity_mu_nu.rds",sep=""))
sigma_nu <- readRDS(paste(factivity_path,"discrete-factivity_sigma_nu.rds",sep=""))
mu_omega <- readRDS(paste(factivity_path,"discrete-factivity_mu_omega.rds",sep=""))
sigma_omega <- readRDS(paste(factivity_path,"discrete-factivity_sigma_omega.rds",sep=""))

data <- list(
    N_predicate=N_predicate,
    N_context=N_context,
    N_participant=N_participant,
    N_data=N_data,
    predicate=predicate,
    context=context,
    participant=participant,
    y=y,
    mu_nu=mu_nu,
    sigma_nu=sigma_nu,
    mu_omega=mu_omega,
    sigma_omega=sigma_omega
);

discrete_factivity_path <- file.path("stan code/evaluation models/replication","discrete_factivity.stan");

discrete_factivity <- cmdstan_model(stan_file=discrete_factivity_path)

## fit the discrete-factivity model:
fit_discrete_factivity <- discrete_factivity$sample(
                                                 data=data,
                                                 refresh=20,
                                                 seed=1337,
                                                 chains=4,
                                                 parallel_chains=4,
                                                 iter_warmup=24000,
                                                 iter_sampling=24000,
                                                 adapt_delta=0.99,
                                                 output_dir=output_path
                                             );

saveRDS(fit_discrete_factivity,file=paste(output_path,"discrete_factivity.rds",sep=""),compress="xz")
