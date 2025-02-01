functions {
  real ordered_beta_lpdf(real y, real k1, real k2, real logit_mu, real phi) {
    real fromk1 = inv_logit(logit_mu - k1);
    real fromk2 = inv_logit(logit_mu - k2);
    real alpha = 1 - fromk1;
    real delta = fromk1 - fromk2;
    real gamma = fromk2;
    real mu = inv_logit(logit_mu);
    real alpha0 = mu * phi;
    real beta0 = (1 - mu) * phi;
    real result;

    if (y == 0)
      result = bernoulli_lpmf(1 | alpha);
    else if (y == 1)
      result = bernoulli_lpmf(1 | gamma);
    else
      result = bernoulli_lpmf(1 | delta) + beta_lpdf(y | alpha0, beta0);

    return result; 
  }

  // the norming model likelihood:
  real likelihood_lpdf(
		       real y,
		       real world,
		       real eta,
		       real k1,
		       real k2,
		       real phi
		       ) {
    real mu_1 = eta;
    real mu_0 = - eta;
    return log_mix(
		   inv_logit(world),
		   ordered_beta_lpdf(y | k1, k2, mu_1, phi),
		   ordered_beta_lpdf(y | k1, k2, mu_0, phi)
		   );
  }
}

data {
  // the Degen and Tonhauser (2021) norming experiment:
  int<lower=1> N_context;	      // number of contexts
  int<lower=1> N_participant;	      // number of participants
  int<lower=1> N_data;		      // number of data points
  vector<lower=0, upper=1>[N_data] y; // response (between 0 and 1)
  array[N_data] int<lower=1, upper=N_context> context; // map from data points to contexts
  array[N_data] int<lower=1, upper=N_participant> participant; // map from data points to participants
}

parameters {
  // 
  // FIXED EFFECTS
  // 
  
  // contexts:
  vector[N_context] z_omega;   // by-context z-scores for the log-odds certainty
  vector<lower=0>[N_context] sigma_omega; // by-context standard deviations for the log-odds certainty


  // 
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts for the log-odds certainty:
  real<lower=0> sigma_epsilon_omega;	 // global scaling factor
  vector[N_participant] z_epsilon_omega; // by-participant z-scores

  // by-participant random intercepts for the log cutpoint absolute value
  real<lower=0> sigma_epsilon_k1;     // global scaling factor
  vector[N_participant] z_epsilon_k1; // by-participant z-scores
  real<lower=0> sigma_epsilon_k2;     // global scaling factor
  vector[N_participant] z_epsilon_k2; // by-participant z-scores
  
  // likelihood parameters:
  real<lower=0> log_k;			// ordered beta cutpoints absolute value
  real<lower=0> eta; 			// absolute value of the 0/1 component
  real<lower=0> phi;		// beta sample size
}

transformed parameters {
  vector[N_context] omega;	// log-odds certainty
  vector[N_participant] epsilon_omega; // by-participant intercepts for the log-odds certainty
  vector[N_data] w;	 // log-odds certainty with participant intercepts added
  vector[N_participant] epsilon_k1; // by-participant intercepts for the first cutpoint
  vector<upper=0>[N_participant] k1; // the first cutpoint (cannot go above 0)
  vector[N_participant] epsilon_k2; // by-participant intercepts for the second cutpoint
  vector<lower=0>[N_participant] k2; // the second cutpoint (cannot go below 0)

  
  // 
  // DEFINITIONS
  //
  
  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = sigma_omega[i] * z_omega[i];
  }

  // non-centered parameteriziation of the participant random intercepts:
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;
  epsilon_k1 = sigma_epsilon_k1 * z_epsilon_k1;
  epsilon_k2 = sigma_epsilon_k2 * z_epsilon_k2;

  // by-participant cutpoint absolute values:
  for (i in 1:N_participant) {
    k1[i] = - exp(log_k + epsilon_k1[i]);
    k2[i] = exp(log_k + epsilon_k2[i]);
  }

  // latent parameters before jittering is added:
  for (i in 1:N_data) {
    w[i] = omega[context[i]] + epsilon_omega[participant[i]];
  }
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // contexts:
  sigma_omega ~ exponential(1);
  z_omega ~ std_normal;

  
  //
  // RANDOM EFFECTS
  //
  
  // by-participant random intercepts:
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ std_normal;
  sigma_epsilon_k1 ~ exponential(1);
  z_epsilon_k1 ~ std_normal;
  sigma_epsilon_k2 ~ exponential(1);
  z_epsilon_k2 ~ std_normal;


  //
  // LIKELIHOOD
  // 

  // parameters:
  log_k ~ normal(log(4), 1);
  eta ~ normal(1.5, 1);
  phi ~ exponential(0.1);
  
  // definition:
  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      target += likelihood_lpdf(
				y[i] |
				w[i],
				eta,
				k1[participant[i]],
				k2[participant[i]],
				phi
				);
    else
      target += negative_infinity();
  }
}

generated quantities {
  vector[N_data] ll; // log-likelihoods (needed for WAIC/PSIS calculations)
  
  // definition:
  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      ll[i] = likelihood_lpdf(
			      y[i] |
			      w[i],
			      eta,
			      k1[participant[i]],
			      k2[participant[i]],
			      phi
			      );
    else
      ll[i] = negative_infinity();
  }
}
