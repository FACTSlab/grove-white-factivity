library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE) # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## choose whether bleached or templatic:
which <- "bleached";
## which <- "templatic";

## the directory where your output files will be saved:
output_dir <- paste0("fits/evaluation/non-contentful/results-",which,"/");
## adjust as desired.

## the directory where your factivity files are saved:
factivity_dir <- "fits/factivity/truncation/results/";
## adjust as desired.

## preprocessing:
non_contentful <- read.csv(paste0("data/",which,"/",which,".csv");

## fixed effects levels:
N_predicate <- length(unique(non_contentful$predicate));

## random effects levels:
N_participant <- length(unique(non_contentful$participant));

## non-contentful data:
N_data <- nrow(non_contentful);
predicate <- non_contentful$predicate_number;
participant <- non_contentful$participant;
y <- non_contentful$response;

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

for (n in model_names) {
    mu_nu <- readRDS(paste0(factivity_dir,n,"_mu_nu.rds"));
    sigma_nu <- readRDS(paste0(factivity_dir,n,"_sigma_nu.rds"));
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
    model_path <- file.path("models/evaluation/non-contentful",paste0(n,".stan"));
    model <- cmdstan_model(stan_file=model_path);
    model_fit <- model$sample(
                           data=data,
                           refresh=20,
                           seed=1337,
                           chains=4,
                           parallel_chains=4,
                           iter_warmup=12000,
                           iter_sampling=12000,
                           adapt_delta=0.99,
                           output_dir=output_dir
                       );   
    saveRDS(model_fit,file=paste0(output_dir,n,".rds"),compress="xz");
}
