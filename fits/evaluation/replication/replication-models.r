library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_path <- paste0("fits/evaluation/replication/results");
## adjust as desired.

## the directory where your factivity files are saved:
factivity_path <- "fits/factivity/truncation/results";
## adjust as desired.

## preprocessing:
replication <- read.csv("data/replication/replication.csv")

## fixed effects levels:
N_predicate <- length(unique(replication$predicate));
N_context <- length(unique(replication$context));

## random effects levels:
N_participant <- length(unique(replication$participant));

## non-contentful data:
N_data <- nrow(replication);
predicate <- replication$predicate_number;
context <- replication$context_number;
participant <- replication$participant;
y <- replication$response;

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

for (n in model_names) {
    mu_nu <- readRDS(paste0(factivity_path,n,"mu_nu.rds"));
    sigma_nu <- readRDS(paste0(factivity_path,n,"sigma_nu.rds"));
    data <- list(
        N_predicate=N_predicate,
        N_context <- N_context,
        N_participant=N_participant,
        N_data=N_data,
        predicate=predicate,
        context=context,
        participant=participant,
        y=y,
        mu_nu=mu_nu,
        sigma_nu=sigma_nu
    );
    model_path <- file.path("models/evaluation/replication",paste0(n,".stan"));
    model <- cmdstan_model(stan_file=model_path);
    model_fit <- model$sample(
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
    saveRDS(model_fit,file=paste0(output_path,n,".rds"),compress="xz");
}
