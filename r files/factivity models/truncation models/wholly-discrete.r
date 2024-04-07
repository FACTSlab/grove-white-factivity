library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_path <- "r files/factivity models/truncation models/results"
## adjust as desired.

## the directory where your norming files are saved:
norming_path <- "r files/norming models/truncation models/results"
## adjust as desired.

## preprocessing:
source("r files/preprocessing/degen_tonhauser_projection.r");

## global stuff...

## fixed effects levels:
N_predicate <- length(unique(projection$predicate))
N_context <- length(unique(projection$context))

## random effects levels:
N_participant <- length(unique(projection$participant))

## individual experiments...

## projection data:
N_data <- nrow(projection)
predicate <- projection$predicate_number
context <- projection$context_number
participant <- projection$participant
y <- projection$response
mu_omega <- readRDS(paste(norming_path,"mu_omega.rds",sep=""))
sigma_omega <- readRDS(paste(norming_path,"sigma_omega.rds",sep=""))

data <- list(
    N_predicate=N_predicate,
    N_context=N_context,
    N_participant=N_participant,
    N_data=N_data,
    predicate=predicate,
    context=context,
    participant=participant,
    y=y,
    mu_omega=mu_omega,
    sigma_omega=sigma_omega
);

wholly_discrete_path <- file.path("stan code/factivity models/truncation models","wholly_discrete.stan");

wholly_discrete <- cmdstan_model(stan_file=wholly_discrete_path)

## fit the wholly-discrete model:
fit_wholly_discrete <- wholly_discrete$sample(
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

saveRDS(fit_wholly_discrete,file=paste(output_path,"wholly_discrete.rds",sep=""),compress="xz")
