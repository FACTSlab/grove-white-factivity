library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE); # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_dir <- "fits/factivity/truncation/results/";
## adjust as desired.

## the directory where your norming files are saved:
norming_dir <- "fits/norming/truncation/results/";
## adjust as desired.

## preprocessing:
source("fits/preprocessing/degen_tonhauser_projection.r");

## fixed effects levels:
N_predicate <- length(unique(projection$predicate));
N_context <- length(unique(projection$context));

## random effects levels:
N_participant <- length(unique(projection$participant));

## projection data:
N_data <- nrow(projection);
predicate <- projection$predicate_number;
context <- projection$context_number;
participant <- projection$participant;
y <- projection$response;

## omega means and standard deviations from the norming-gradient model:
mu_omega <- readRDS(paste0(norming_dir,"mu_omega.rds"));
sigma_omega <- readRDS(paste0(norming_dir,"sigma_omega.rds"));

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

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

## fit and save all four models:
for (n in model_names) {
    model_path <- file.path("models/factivity/truncation",paste0(n,".stan"));
    model <- cmdstan_model(stan_file=model_path);
    model_fit <- model$sample(
                           data=data,
                           refresh=20,
                           seed=1337,
                           chains=4,
                           parallel_chains=4,
                           iter_warmup=15000,
                           iter_sampling=15000,
                           adapt_delta=0.99,
                           output_dir=output_dir
                       );
    saveRDS(model_fit,file=paste0(output_dir,n,".rds"),compress="xz");
}

## extract means and standard deviations for the posterior nus and omegas of all four models:
for (n in model_names) {
    model_fit <- readRDS(paste0(output_dir,n,".rds"));
    mu_nu <- rep(0,N_predicate);
    sigma_nu <- rep(0,N_predicate);
    for (i in 1:N_predicate) {
        mu_nu[i] <- mean(model_fit$draws("nu")[,,i]);
        sigma_nu[i] <- sd(model_fit$draws("nu")[,,i]);
    }
    saveRDS(mu_nu,paste0(output_dir,n,"_mu_nu.rds"));
    saveRDS(sigma_nu,paste0(output_dir,n,"_sigma_nu.rds"));
    mu_omega <- rep(0,N_context);
    sigma_omega <- rep(0,N_context);
    for (i in 1:N_context) {
        mu_omega[i] <- mean(model_fit$draws("omega")[,,i]);
        sigma_omega[i] <- sd(model_fit$draws("omega")[,,i]);
    }
    saveRDS(mu_omega,paste0(output_dir,n,"_mu_omega.rds"));
    saveRDS(sigma_omega,paste0(output_dir,n,"_sigma_omega.rds"));
}
