library(cmdstanr);
options(mc.cores=parallel::detectCores());
# cmdstanr::install_cmdstan(overwrite=TRUE); # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_dir <- "fits/factivity/truncation/results/";
## adjust as desired.

## the directory where your norming files are saved:
norming_dir <- "fits/norming/truncation/results/";
## adjust as desired.

## preprocessing:
source("fits/preprocessing/degen_tonhauser_projection.r");

## folds:
K <- 5; # number of folds
N_data <- nrow(projection);
folds <- sample(rep(1:K,each=N_data/K));

## fixed effects levels:
N_predicate <- length(unique(projection$predicate));
N_context <- length(unique(projection$context));

## random effects levels:
N_participant <- length(unique(projection$participant));

## omega means and standard deviations from the norming-gradient model:
mu_omega <- readRDS(paste0(norming_dir,"mu_omega.rds"));
sigma_omega <- readRDS(paste0(norming_dir,"sigma_omega.rds"));

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

N_chains <- 4;
N_samples <- 3000;

## fit and save all four models:
for (n in model_names) {
    for (f in 1:K) {
        ## projection training data:
        projection_tr <- projection[folds!=f,];
        N_data_tr <- nrow(projection_tr);
        predicate_tr <- projection_tr$predicate_number;
        context_tr <- projection_tr$context_number;
        participant_tr <- projection_tr$participant;
        y_tr <- projection_tr$response;
        
        ## projection test data:
        projection_te <- projection[folds==f,]
        N_data_te <- nrow(projection_te);
        predicate_te <- projection_te$predicate_number;
        context_te <- projection_te$context_number;
        participant_te <- projection_te$participant;
        y_te <- projection_te$response;

        data <- list(
            N_predicate=N_predicate,
            N_context=N_context,
            N_participant=N_participant,
            N_data_tr=N_data_tr,
            predicate_tr=predicate_tr,
            context_tr=context_tr,
            participant_tr=participant_tr,
            y_tr=y_tr,
            N_data_te=N_data_te,
            predicate_te=predicate_te,
            context_te=context_te,
            participant_te=participant_te,
            y_te=y_te,
            mu_omega=mu_omega,
            sigma_omega=sigma_omega
        );
        
        model_path <- file.path("models/factivity/truncation/",paste0(n,"_cv.stan"));
        model <- cmdstan_model(stan_file=model_path);
        model_fit <- model$sample(
                               data=data,
                               refresh=20,
                               seed=1337,
                               chains=4,
                               parallel_chains=N_chains,
                               iter_warmup=6*N_samples,
                               iter_sampling=6*N_samples,
			       thin=6,
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
