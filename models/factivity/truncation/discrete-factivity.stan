functions {
  real truncated_normal_lpdf(real x, real mu, real sigma, real a, real b) {
    return normal_lpdf(x | mu, sigma) -
      log_diff_exp(normal_lcdf(b | mu, sigma),
		   normal_lcdf(a | mu, sigma));
  }
  
  // the discrete-factivity model likelihood:
  real likelihood_lpdf(
		       real y,
		       real predicate,
		       real world,
		       real sigma
		       ) {
    return log_mix(
		   predicate,
		   truncated_normal_lpdf(y | 1, sigma, 0, 1),
		   truncated_normal_lpdf(y | world, sigma, 0, 1)
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

  // world knowledge log-odds means and standard deviations, obtained from the norming experiment:
  vector[N_context] mu_omega;
  vector<lower=0>[N_context] sigma_omega;
}

parameters {
  // 
  // FIXED EFFECTS
  // 
  
  // predicates:
  vector[N_predicate] z_nu; // by-predicate z-scores for the log-odds of projection
  vector<lower=0>[N_predicate] sigma_nu; // by-predicate standard deviations for the log-odds of projection

  // contexts:
  vector[N_context] z_omega;   // by-context z-scores for the log-odds certainty

  // 
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts for the log-odds of projection:
  real<lower=0> tau_epsilon_nu;	      // global scaling factor
  vector[N_participant] z_epsilon_nu; // by-participant z-scores

  // by-participant random intercepts for the log-odds certainty:
  real<lower=0> tau_epsilon_omega;	 // global scaling factor
  vector[N_participant] z_epsilon_omega; // by-participant z-scores

  // jitter:
  real<lower=0, upper=1> sigma_jitter; // jitter standard deviation
}

transformed parameters {
  vector[N_predicate] nu;	// log-odds of projection
  vector[N_participant] epsilon_nu; // by-participant intercepts for the log-odds of projection
  vector<lower=0, upper=1>[N_data] v; // probability of projection
  vector[N_context] omega; // log-odds certainty
  vector[N_participant] epsilon_omega; // by-participant intercepts for the log-odds certainty
  vector<lower=0, upper=1>[N_data] w; // certainty on the unit interval

  // 
  // DEFINITIONS
  //
  
  // non-centered parameterization of the log-odds of projection:
  for (i in 1:N_predicate) {
    nu[i] = sigma_nu[i] * z_nu[i];
  }

  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = mu_omega[i] + sigma_omega[i] * z_omega[i];
  }

  // non-centered parameteriziation of the participant random intercepts:
  epsilon_nu = tau_epsilon_nu * z_epsilon_nu;
  epsilon_omega = tau_epsilon_omega * z_epsilon_omega;

  // latent parameters before jittering is added:
  for (i in 1:N_data) {
    v[i] = inv_logit(nu[predicate[i]] + epsilon_nu[participant[i]]);
    w[i] = inv_logit(omega[context[i]] + epsilon_omega[participant[i]]);
  }
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // predicates:
  z_nu ~ normal(0, 1);
  sigma_nu ~ exponential(1);

  // contexts:
  z_omega ~ normal(0, 1);

  
  //
  // RANDOM EFFECTS
  //
  
  // by-participant random intercepts:
  tau_epsilon_nu ~ exponential(1);
  z_epsilon_nu ~ normal(0, 1);
  tau_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ normal(0, 1);

  
  //
  // LIKELIHOOD
  // 
  
  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      target += likelihood_lpdf(
				y[i] |
				v[i],
				w[i],
				sigma_jitter
				);
    else
      target += negative_infinity();
  }
}

generated quantities {
  vector[N_data] ll;	  // log-likelihoods (needed for WAIC/PSIS calculations)
  
  // definition:
  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      ll[i] = likelihood_lpdf(
			      y[i] |
			      v[i],
			      w[i],
			      sigma_jitter
			      );
    else
      ll[i] = negative_infinity();
  }
}
