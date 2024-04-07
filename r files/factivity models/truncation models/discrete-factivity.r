library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # Uncomment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## The directory where your output files will be saved:
output_path <- "stan code/factivity models/truncation models/results"
g
## Adjust as desired.

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

data <- list(
    N_predicate=N_predicate,
    N_context=N_context,
    N_participant=N_participant,
    N_data=N_data,
    predicate=predicate,
    context=context,
    participant=participant,
    y=y
);

discrete_factivity_path <- file.path("stan code/factivity models/truncation models","discrete_factivity.stan");

discrete_factivity <- cmdstan_model(stan_file=discrete_factivity_path)

## fit the discrete-factivity model:
fit_discrete_factivity <- discrete_factivity$sample(
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

saveRDS(fit_discrete_factivity,file=paste(output_path,"discrete_factivity.rds",sep=""),compress="xz")
