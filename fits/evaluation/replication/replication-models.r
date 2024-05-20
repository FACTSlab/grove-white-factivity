library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_dir <- "fits/evaluation/replication/results/";
## adjust as desired.

## the directory where your factivity files are saved:
factivity_dir <- "fits/factivity/truncation/results/";
## adjust as desired.

## preprocessing:
replication <- read.csv("data/replication/replication.csv");

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

## model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");
model_names <- c("discrete-world","wholly-discrete");

for (n in model_names) {
    mu_nu <- readRDS(paste0(factivity_dir,n,"_mu_nu.rds"));
    sigma_nu <- readRDS(paste0(factivity_dir,n,"_sigma_nu.rds"));
    mu_omega <- readRDS(paste0(factivity_dir,n,"_mu_omega.rds"));
    sigma_omega <- readRDS(paste0(factivity_dir,n,"_sigma_omega.rds"));
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
    model_path <- file.path("models/evaluation/replication/",paste0(n,".stan"));
    model <- cmdstan_model(stan_file=model_path);
    model_fit <- model$sample(
                           data=data,
                           refresh=20,
                           seed=1337,
                           chains=4,
                           parallel_chains=4,
                           iter_warmup=45000,
                           iter_sampling=45000,
                           thin=3,
                           adapt_delta=0.99,
                           output_dir=output_dir
                       );   
    saveRDS(model_fit,file=paste0(output_dir,n,".rds"),compress="xz");
}
