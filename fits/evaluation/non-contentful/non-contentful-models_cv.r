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
non_contentful <- read.csv(paste0("data/",which,"/",which,".csv"));

## folds:
K <- 5; # number of folds
N_data <- nrow(non_contentful);
folds <- sample(rep(1:K,each=N_data/K));

## fixed effects levels:
N_predicate <- length(unique(non_contentful$predicate));

## random effects levels:
N_participant <- length(unique(non_contentful$participant));

model_names <- c("discrete-factivity","wholly-gradient","discrete-world","wholly-discrete");

N_chains <- 4;
N_samples <- 3000;

for (n in model_names) {
    mu_nu <- readRDS(paste0(factivity_dir,n,"_mu_nu.rds"));
    sigma_nu <- readRDS(paste0(factivity_dir,n,"_sigma_nu.rds"));
    for (f in 1:K) {
        ## non-contentful training data:
        non_contentful_tr <- non_contentful[folds!=f,];
        N_data_tr <- nrow(non_contentful_tr);
        predicate_tr <- non_contentful_tr$predicate_number;
        participant_tr <- non_contentful_tr$participant;
        y_tr <- non_contentful_tr$response;
        
        ## non-contentful test data:
        non_contentful_te <- non_contentful[folds==f,]
        N_data_te <- nrow(non_contentful_te);
        predicate_te <- non_contentful_te$predicate_number;
        participant_te <- non_contentful_te$participant;
        y_te <- non_contentful_te$response;
        
        data <- list(
            N_predicate=N_predicate,
            N_participant=N_participant,
            N_data_tr=N_data_tr,
            predicate_tr=predicate_tr,
            participant_tr=participant_tr,
            y_tr=y_tr,
            N_data_te=N_data_te,
            predicate_te=predicate_te,
            participant_te=participant_te,
            y_te=y_te,
            mu_nu=mu_nu,
            sigma_nu=sigma_nu
        );
        model_path <- file.path("models/evaluation/non-contentful/",paste0(n,"_cv.stan"));
        model <- cmdstan_model(stan_file=model_path);
        model_fit <- model$sample(
                               data=data,
                               refresh=20,
                               seed=1337,
                               chains=4,
                               parallel_chains=N_chains,
                               iter_warmup=3*N_samples,
                               iter_sampling=3*N_samples,
                               thin=3,
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
