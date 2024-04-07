library(cmdstanr)
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

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

norming_gradient_path <- file.path("stan code/norming models/truncation models","norming_gradient.stan");

norming_gradient <- cmdstan_model(stan_file=norming_gradient_path)

## fit the norming-gradient model:
fit_norming_gradient <- norming_gradient$sample(
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

saveRDS(fit_norming_gradient,file=paste(output_path,"norming_gradient.rds",sep=""),compress="xz")
