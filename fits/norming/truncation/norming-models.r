library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE); # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_path <- "models/norming/truncation/results";
## adjust as desired.

## preprocessing:
source("fits/preprocessing/degen_tonhauser_norming.r");

## fixed effects levels:
N_context <- length(unique(norming$context));

## random effects levels:
N_participant <- length(unique(norming$participant));

## norming data:
N_data <- nrow(norming);
context <- norming$context_number;
participant <- norming$participant;
y <- norming$response;

data <- list(
    N_context=N_context,
    N_participant=N_participant,
    N_data=N_data,
    context=context,
    participant=participant,
    y=y
);

model_names <- c("norming-gradient","norming-discrete");

## fit and save both models:
for (n in model_names) {
    model_path <- file.path("models/norming/truncation",paste(n,".stan",sep=""));
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
                           output_dir=output_path
                       );
    saveRDS(model_fit,file=paste(output_path,n,".rds",sep=""),compress="xz");
}

## extract means and standard deviations for the posterior omegas of the noming-gradient model:
norming_gradient_fit <- readRDS(paste(output_path,"norming-gradient.rds",sep=""));
mu_omega <- rep(0,N_context);
sigma_omega <- rep(0,N_context);
for (i in 1:N_context) {
    mu_omega[i] <- mean(norming_gradient_fit$draws("omega")[,,i]);
    sigma_omega[i] <- sd(norming_gradient_fit$draws("omega")[,,i]);
}
saveRDS(mu_omega,paste(output_path,"mu_omega.rds",sep=""));
saveRDS(sigma_omega,paste(output_path,"sigma_omega.rds",sep=""));
