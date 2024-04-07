## the directory where your output files will be saved:
output_path <- "r files/factivity models/truncation models/results"
## adjust as desired.

## preprocessing:
source("r files/preprocessing/degen_tonhauser_projection.r")

## read in the discrete-factivity model:
fit_discrete_factivity <- readRDS(paste(output_path,"discrete-factivity.rds",sep=""))
## read in the wholly-gradient model:
fit_wholly_gradient <- readRDS(paste(output_path,"wholly-gradient.rds",sep=""))
## read in the discrete-world model:
fit_discrete_world <- readRDS(paste(output_path,"discrete-world.rds",sep=""))
## read in the wholly-discrete model:
fit_wholly_discrete <- readRDS(paste(output_path,"wholly-discrete.rds",sep=""))

## fixed effects levels:
N_predicate <- length(unique(projection$verb))
N_context <- length(unique(projection$context))

## gather posteriors from the discrete-factivity model:
discrete_factivity_mu_nu <- rep(0,N_verb)
discrete_factivity_sigma_nu <- rep(0,N_verb)
for (i in 1:N_verb) {
    discrete_factivity_mu_nu[i] <- mean(fit_discrete_factivity$draws("nu")[,,i])
    discrete_factivity_sigma_nu[i] <- sd(fit_discrete_factivity$draws("nu")[,,i])
}
discrete_factivity_mu_omega <- rep(0,N_context)
discrete_factivity_sigma_omega <- rep(0,N_context)
for (i in 1:N_context) {
    discrete_factivity_mu_omega[i] <- mean(fit_discrete_factivity$draws("omega")[,,i])
    discrete_factivity_sigma_omega[i] <- sd(fit_discrete_factivity$draws("omega")[,,i])
}
saveRDS(discrete_factivity_mu_nu,paste(output_path,"discrete-factivity_mu_nu.rds",sep=""))
saveRDS(discrete_factivity_sigma_nu,paste(output_path,"discrete-factivity_sigma_nu.rds",sep=""))
saveRDS(discrete_factivity_mu_omega,paste(output_path,"discrete-factivity_mu_omega.rds",sep=""))
saveRDS(discrete_factivity_sigma_omega,paste(output_path,"discrete-factivity_sigma_omega.rds",sep=""))

## gather posteriors from the wholly-gradient model:
wholly_gradient_mu_nu <- rep(0,N_verb)
wholly_gradient_sigma_nu <- rep(0,N_verb)
for (i in 1:N_verb) {
    wholly_gradient_mu_nu[i] <- mean(fit_wholly_gradient$draws("nu")[,,i])
    wholly_gradient_sigma_nu[i] <- sd(fit_wholly_gradient$draws("nu")[,,i])
}
wholly_gradient_mu_omega <- rep(0,N_context)
wholly_gradient_sigma_omega <- rep(0,N_context)
for (i in 1:N_context) {
    wholly_gradient_mu_omega[i] <- mean(fit_wholly_gradient$draws("omega")[,,i])
    wholly_gradient_sigma_omega[i] <- sd(fit_wholly_gradient$draws("omega")[,,i])
}
saveRDS(wholly_gradient_mu_nu,paste(output_path,"wholly-gradient_mu_nu.rds",sep=""))
saveRDS(wholly_gradient_sigma_nu,paste(output_path,"wholly-gradient_sigma_nu.rds",sep=""))
saveRDS(wholly_gradient_mu_omega,paste(output_path,"wholly-gradient_mu_omega.rds",sep=""))
saveRDS(wholly_gradient_sigma_omega,paste(output_path,"wholly-gradient_sigma_omega.rds",sep=""))

## gather posteriors from the discrete-world model:
discrete_world_mu_nu <- rep(0,N_verb)
discrete_world_sigma_nu <- rep(0,N_verb)
for (i in 1:N_verb) {
    discrete_world_mu_nu[i] <- mean(fit_discrete_world$draws("nu")[,,i])
    discrete_world_sigma_nu[i] <- sd(fit_discrete_world$draws("nu")[,,i])
}
discrete_world_mu_omega <- rep(0,N_context)
discrete_world_sigma_omega <- rep(0,N_context)
for (i in 1:N_context) {
    discrete_world_mu_omega[i] <- mean(fit_discrete_world$draws("omega")[,,i])
    discrete_world_sigma_omega[i] <- sd(fit_discrete_world$draws("omega")[,,i])
}
saveRDS(discrete_world_mu_nu,paste(output_path,"discrete-world_mu_nu.rds",sep=""))
saveRDS(discrete_world_sigma_nu,paste(output_path,"discrete-world_sigma_nu.rds",sep=""))
saveRDS(discrete_world_mu_omega,paste(output_path,"discrete-world_mu_omega.rds",sep=""))
saveRDS(discrete_world_sigma_omega,paste(output_path,"discrete-world_sigma_omega.rds",sep=""))

## gather posteriors from the wholly-discrete model:
wholly_discrete_mu_nu <- rep(0,N_verb)
wholly_discrete_sigma_nu <- rep(0,N_verb)
for (i in 1:N_verb) {
    wholly_discrete_mu_nu[i] <- mean(fit_wholly_discrete$draws("nu")[,,i])
    wholly_discrete_sigma_nu[i] <- sd(fit_wholly_discrete$draws("nu")[,,i])
}
wholly_discrete_mu_omega <- rep(0,N_context)
wholly_discrete_sigma_omega <- rep(0,N_context)
for (i in 1:N_context) {
    wholly_discrete_mu_omega[i] <- mean(fit_wholly_discrete$draws("omega")[,,i])
    wholly_discrete_sigma_omega[i] <- sd(fit_wholly_discrete$draws("omega")[,,i])
}
saveRDS(wholly_discrete_mu_nu,paste(output_path,"wholly-discrete_mu_nu.rds",sep=""))
saveRDS(wholly_discrete_sigma_nu,paste(output_path,"wholly-discrete_sigma_nu.rds",sep=""))
saveRDS(wholly_discrete_mu_omega,paste(output_path,"wholly-discrete_mu_omega.rds",sep=""))
saveRDS(wholly_discrete_sigma_omega,paste(output_path,"wholly-discrete_sigma_omega.rds",sep=""))

