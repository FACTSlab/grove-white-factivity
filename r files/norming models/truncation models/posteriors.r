## the directory where your output files will be saved:
output_path <- "r files/norming models/truncation models/results"
## adjust as desired.

## preprocessing:
source("r files/preprocessing/degen_tonhauser_norming.r");

## read in model of the norming data:
fit_norming_gradient <- readRDS(paste(output_path,"norming_gradient.rds",sep=""))

## global stuff...

## fixed effects levels:
N_context <- length(unique(norming$context))

## gather posteriors from norming model:
mu_omega <- rep(0,N_context)
sigma_omega <- rep(0,N_context)
for (i in 1:N_context) {
    mu_omega[i] <- mean(fit_norming_gradient$draws("omega")[,,i])
    sigma_omega[i] <- sd(fit_norming_gradient$draws("omega")[,,i])
}
saveRDS(mu_omega,paste(output_path,"mu_omega.rds",sep=""))
saveRDS(sigma_omega,paste(output_path,"sigma_omega.rds",sep=""))
