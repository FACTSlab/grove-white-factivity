library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # Uncomment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_path <- "stan code/norming models/truncation models/results"
## adjust as desired.

## preprocessing:
source("r files/preprocessing/degen_tonhauser_norming.r");

## global stuff...

## fixed effects levels:
N_context <- length(unique(norming$context))

## random effects levels:
N_participant <- length(unique(norming$participant))

## individual experiments...

## norming data:
N_data <- nrow(norming)
context <- norming$context_number
participant <- norming$participant
y <- norming$response

data <- list(
    N_context=N_context,
    N_participant=N_participant,
    N_data=N_data,
    context=context,
    participant=participant,
    y=y
);

norming_discrete_path <- file.path("stan code/norming models/truncation models","norming_discrete.stan");

norming_discrete <- cmdstan_model(stan_file=norming_discrete_path)

## fit the norming-discrete model:
fit_norming_discrete <- norming_discrete$sample(
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

saveRDS(fit_norming_discrete,file=paste(output_path,"norming_discrete.rds",sep=""),compress="xz")
