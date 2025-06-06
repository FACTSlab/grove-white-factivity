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

## folds:
K <- 5; # number of folds
N_data <- nrow(replication);
folds <- sample(rep(1:K,each=N_data/K));

## fixed effects levels:
N_predicate <- length(unique(replication$predicate));
N_context <- length(unique(replication$context));

## random effects levels:
N_participant <- length(unique(replication$participant));

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

N_chains <- 4;
N_samples <- 3000;

for (n in model_names) {
    mu_nu <- readRDS(paste0(factivity_dir,n,"_mu_nu.rds"));
    sigma_nu <- readRDS(paste0(factivity_dir,n,"_sigma_nu.rds"));
    mu_omega <- readRDS(paste0(factivity_dir,n,"_mu_omega.rds"));
    sigma_omega <- readRDS(paste0(factivity_dir,n,"_sigma_omega.rds"));
    for (f in 1:K) {
        ## replication training data:
        replication_tr <- replication[folds!=f,];
        N_data_tr <- nrow(replication_tr);
        predicate_tr <- replication_tr$predicate_number;
        context_tr <- replication_tr$context_number;
        participant_tr <- replication_tr$participant;
        y_tr <- replication_tr$response;
        
        ## replication test data:
        replication_te <- replication[folds==f,]
        N_data_te <- nrow(replication_te);
        predicate_te <- replication_te$predicate_number;
        context_te <- replication_te$context_number;
        participant_te <- replication_te$participant;
        y_te <- replication_te$response;

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
            mu_nu=mu_nu,
            sigma_nu=sigma_nu,
            mu_omega=mu_omega,
            sigma_omega=sigma_omega
        );
        
        model_path <- file.path("models/evaluation/replication/",paste0(n,"_cv.stan"));
        model <- cmdstan_model(stan_file=model_path);
        model_fit <- model$sample(
                               data=data,
                               refresh=20,
                               seed=1337,
                               chains=4,
                               parallel_chains=N_chains,
                               iter_warmup=15*N_samples,
                               iter_sampling=15*N_samples,
                               thin=15,
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
