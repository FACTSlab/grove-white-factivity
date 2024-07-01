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
  
  // the discrete-factivity model likelihood:
  real likelihood_lpdf(
		       real y,
		       real predicate,
		       real anti,
		       real world,
		       real eta,
		       real k1,
		       real k2,
		       real phi
		       ) {
    real mu_0 = k1 - eta;
    real mu_1 = k2 + eta;
    
    return log_mix(
		   inv_logit(predicate),
		   ordered_beta_lpdf(y | k1, k2, mu_1, phi),
		   log_mix(
			   inv_logit(anti),
			   ordered_beta_lpdf(y | k1, k2, mu_0, phi),
			   ordered_beta_lpdf(y | k1, k2, world, phi)
			   )
		   );
  }
}

data {
  // the Degen and Tonhauser (2021) projection experiment:
  int<lower=1> N_predicate;	      // number of predicates
  int<lower=1> N_context;	      // number of contexts
  int<lower=1> N_participant;	      // number of participants
  int<lower=1> N_data;		      // number of data points
  vector<lower=0, upper=1>[N_data] y; // response (between 0 and 1)
  array[N_data] int<lower=1, upper=N_predicate> predicate; // map from data points to predicates
  array[N_data] int<lower=1, upper=N_context> context; // map from data points to contexts
  array[N_data] int<lower=1, upper=N_participant> participant; // map from data points to participants

  // context log-odds means and standard deviations, obtained from the norming experiment:
  vector<lower=0>[N_context] sigma_omega;
  vector[N_context] mu_omega;
}

parameters {
  // 
  // FIXED EFFECTS
  // 
  
  // factivity parameters:
  vector<lower=0>[N_predicate] sigma_nu; // by-predicate standard deviations for the log-odds of projection
  vector[N_predicate] z_nu; // by-predicate z-scores for the log-odds of projection

  // anti-veridicality parameters:
  vector<lower=0>[N_predicate] sigma_alpha; // by-predicate standard deviations for the log-odds of an anti-veridicality entailment 
  vector[N_predicate] z_alpha; // by-predicate z-scores for the log-odds of an anti-veridicality entailment

  // contexts:
  vector[N_context] z_omega;   // by-context z-scores for the log-odds certainty

  
  // 
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts for the log-odds of projection:
  real<lower=0> sigma_epsilon_nu;     // global scaling factor
  vector[N_participant] z_epsilon_nu; // by-participant z-scores

  real<lower=0> sigma_epsilon_alpha;
  vector[N_participant] z_epsilon_alpha;

  // by-participant random intercepts for the log-odds certainty:
  real<lower=0> sigma_epsilon_omega;	 // global scaling factor
  vector[N_participant] z_epsilon_omega; // by-participant z-scores

  // by-participant random intercepts for the log cutpoints absolute value
  real<lower=0> sigma_epsilon_k1;     // global scaling factor
  vector[N_participant] z_epsilon_k1; // by-participant z-scores
  real<lower=0> sigma_epsilon_k2;     // global scaling factor
  vector[N_participant] z_epsilon_k2; // by-participant z-scores
  
  // likelihood parameters:
  real log_k;		      // ordered beta cutpoint log absolute value
  real eta;		      // difference between cutpoints and 0/1 components
  real<lower=0> phi;	      // beta sample size
}

transformed parameters {
  vector[N_predicate] nu;	// log-odds of projection
  vector[N_participant] epsilon_nu; // by-participant intercepts for the log-odds of projection
  vector[N_data] v;  // log-odds of projection with participant intercepts added
  vector[N_predicate] alpha;	// log-odds of anti-veridicality
  vector[N_participant] epsilon_alpha; // by-participant intercepts for the log-odds of anti-veridicality
  vector[N_data] a; // log-odds of anti-veridicality with participant intercepts added
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
  
  // non-centered parameterization of the log-odds of projection:
  for (i in 1:N_predicate) {
    nu[i] = sigma_nu[i] * z_nu[i];
    alpha[i] = sigma_alpha[i] * z_alpha[i];
  }

  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = mu_omega[i] + sigma_omega[i] * z_omega[i];
  }

  // non-centered parameteriziation of the participant random intercepts:
  epsilon_nu = sigma_epsilon_nu * z_epsilon_nu;
  epsilon_alpha = sigma_epsilon_alpha * z_epsilon_alpha;
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;
  epsilon_k1 = sigma_epsilon_k1 * z_epsilon_k1;
  epsilon_k2 = sigma_epsilon_k2 * z_epsilon_k2;

  // by-participant cutpoint absolute values:
  for (i in 1:N_participant) {
    k1[i] = - exp(log_k + epsilon_k1[i]);
    k2[i] = exp(log_k + epsilon_k2[i]);
  }
  
  // latent parameters:
  for (i in 1:N_data) {
    v[i] = nu[predicate[i]] + epsilon_nu[participant[i]];
    a[i] = alpha[predicate[i]] + epsilon_alpha[participant[i]];
    w[i] = omega[context[i]] + epsilon_omega[participant[i]];
  }
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // predicates:
  sigma_nu ~ exponential(1);
  z_nu ~ normal(0, 1);
  sigma_alpha ~ exponential(1);
  z_alpha ~ normal(0, 1);

  // contexts:
  z_omega ~ normal(0, 1);

  
  //
  // RANDOM EFFECTS
  //
  
  // by-participant random intercepts:
  sigma_epsilon_nu ~ exponential(1);
  z_epsilon_nu ~ normal(0, 1);
  sigma_epsilon_alpha ~ exponential(1);
  z_epsilon_alpha ~ normal(0, 1);
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ normal(0, 1);
  sigma_epsilon_k1 ~ exponential(1);
  z_epsilon_k1 ~ normal(0, 1);
  sigma_epsilon_k2 ~ exponential(1);
  z_epsilon_k2 ~ normal(0, 1);


  //
  // LIKELIHOOD
  // 

  // parameters:
  log_k ~ normal(log(4), 1);
  eta ~ normal(0, 1);
  phi ~ exponential(0.1);

  // definition:
  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      target += likelihood_lpdf(
				y[i] |
				v[i],
				a[i],
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
			      v[i],
			      a[i],
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
