library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE); # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_dir <- "fits/norming/inflation/results/";
## adjust as desired.

## preprocessing:
source("fits/preprocessing/degen_tonhauser_norming.r");

## folds:
K <- 5; # number of folds
N_data <- nrow(norming);
folds <- sample(rep(1:K,each=N_data/K));

## fixed effects levels:
N_context <- length(unique(norming$context));

## random effects levels:
N_participant <- length(unique(norming$participant));

model_names <- c("norming-gradient","norming-discrete");

N_chains <- 4;     # number of chains
N_samples <- 3000; # number of samples per chain

fit and save both models:
for (n in model_names) {
    for (f in 1:K) {
        ## norming training data:
        norming_tr <- norming[folds!=f,];
        N_data_tr <- nrow(norming_tr);
        context_tr <- norming_tr$context_number;
        participant_tr <- norming_tr$participant;
        y_tr <- norming_tr$response;

        ## norming test data:
        norming_te <- norming[folds==f,];
        N_data_te <- nrow(norming_te);
        context_te <- norming_te$context_number;
        participant_te <- norming_te$participant;
        y_te <- norming_te$response;

        data <- list(
            N_context=N_context,
            N_participant=N_participant,
            N_data_tr=N_data_tr,
            context_tr=context_tr,
            participant_tr=participant_tr,
            y_tr=y_tr,
            N_data_te=N_data_te,
            context_te=context_te,
            participant_te=participant_te,
            y_te=y_te
        );      
        model_path <- file.path("models/norming/inflation/",paste0(n,"_cv.stan"));
        model <- cmdstan_model(stan_file=model_path);
        model_fit <- model$sample(
                               data=data,
                               refresh=20,
                               seed=1337,
                               chains=N_chains,
                               parallel_chains=N_chains,
                               iter_warmup=N_samples,
                               iter_sampling=N_samples,
                               adapt_delta=0.99,
                               output_dir=output_dir
                           );
        saveRDS(model_fit,file=paste0(output_dir,n,"_cv_fold",f,".rds"),compress="xz");
    }
}

## model comparisons:
library(tidyr);

for (n in model_names) {
    ll <- readRDS(paste0(output_dir,n,"_cv_fold",1,".rds"))$draws("ll_te");
    for (f in 2:K) {
        ll <- array(
            c(ll,readRDS(paste0(output_dir,n,"_cv_fold",f,".rds"))$draws("ll_te")),
            dim=c(N_samples,N_chains,f*N_data/K)
        );
    }
    ll <- as.data.frame(t(as.data.frame(aperm(ll,c(3,1,2)))));
    names(ll) <- c(1:N_data);
    row.names(ll) <- NULL;
    ll <- pivot_longer(ll,cols=c(1:N_data));
    ll$l <- exp(as.numeric(ll$value));
    estimates <- aggregate(ll$l,by=list(ll$name),FUN=mean);
    names(estimates) <- c("data_point","epd");
    estimates$data_point <- as.numeric(estimates$data_point);
    estimates$elpd <- log(estimates$epd);
    estimates <- estimates[c("data_point","elpd")];
    saveRDS(estimates,paste0(output_dir,"elpd_",n,".rds"),compress="xz");
}
