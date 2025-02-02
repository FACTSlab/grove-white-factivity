library(cmdstanr);
options(mc.cores=parallel::detectCores());
## cmdstanr::install_cmdstan(overwrite=TRUE); # un-comment this line to update or install cmdstanr (e.g., if you're running a Stan model for the first time).

## the directory where your output files will be saved:
output_dir <- "fits/norming/truncation/results/";
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

model_names <- c("norming-gradient_cv","norming-discrete_cv");

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
        model_path <- file.path("models/norming/truncation/",paste0(n,".stan"));
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
        saveRDS(model_fit,file=paste0(output_dir,n,"_fold",f,".rds"),compress="xz");
    }
}

## model comparisons:
library(tidyr);
ll_ng <- readRDS(paste0(output_dir,"norming-gradient_cv_fold",1,".rds"))$draws("ll_te");
for (f in 2:K) {
    ll_ng <- array(
        c(ll_ng,readRDS(paste0(output_dir,"norming-gradient_cv_fold",f,".rds"))$draws("ll_te")),
        dim=c(N_samples,N_chains,f*N_data/K)
    );
}
ll_ng <- as.data.frame(t(as.data.frame(aperm(ll_ng,c(3,1,2)))));
names(ll_ng) <- c(1:N_data);
row.names(ll_ng) <- NULL;
ll_ng <- pivot_longer(ll_ng,cols=c(1:N_data));
ll_ng$l <- exp(as.numeric(ll_ng$value))
estimates_ng <- aggregate(ll_ng$l,by=list(ll_ng$name),FUN=mean);
names(estimates_ng) <- c("data_point","epd");
estimates_ng$elpd <- log(estimates_ng$epd);
estimates_ng <- estimates_ng[c("data_point","elpd")];
saveRDS(estimates_ng,paste0(output_dir,"estimates_ng.rds"));
elpd_ng <- sum(estimates_ng$elpd);
elpd_se_ng <- sqrt(N_data*var(estimates_ng$elpd));

ll_nd <- readRDS(paste0(output_dir,"norming-discrete_cv_fold",1,".rds"))$draws("ll_te");
for (f in 2:K) {
    ll_nd <- array(
        c(ll_nd,readRDS(paste0(output_dir,"norming-discrete_cv_fold",f,".rds"))$draws("ll_te")),
        dim=c(N_samples,N_chains,f*N_data/K)
    );
}
ll_nd <- as.data.frame(t(as.data.frame(aperm(ll_nd,c(3,1,2)))));
names(ll_nd) <- c(1:N_data);
row.names(ll_nd) <- NULL;
ll_nd <- pivot_longer(ll_nd,cols=c(1:N_data));
ll_nd$l <- exp(as.numeric(ll_nd$value));
estimates_nd <- aggregate(ll_nd$l,by=list(ll_nd$name),FUN=mean);
names(estimates_nd) <- c("data_point","epd");
estimates_nd$elpd <- log(estimates_nd$epd);
estimates_nd <- estimates_nd[c("data_point","elpd")];
saveRDS(estimates_nd,paste0(output_dir,"estimates_nd.rds"));
elpd_nd <- sum(estimates_nd$elpd);
elpd_se_nd <- sqrt(N_data*var(estimates_nd$elpd));

elpd_diff_se <- sqrt(N_data*var(estimates_ng$elpd-estimates_nd$elpd));
