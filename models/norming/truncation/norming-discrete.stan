functions {
  real truncated_normal_lpdf(real x, real mu, real sigma, real a, real b) {
    return normal_lpdf(x | mu, sigma) -
      log_diff_exp(normal_lcdf(b | mu, sigma),
		   normal_lcdf(a | mu, sigma));
  }
  
  // the norming-discrete model likelihood:
  real likelihood_lpdf(
		       real y,
		       real world,
		       real sigma
		       ) {
    return log_mix(
		   world,
		   truncated_normal_lpdf(y | 1, sigma, 0, 1),
		   truncated_normal_lpdf(y | 0, sigma, 0, 1)
		   );
  }
}

data {
  // data from the the Degen and Tonhauser (2021) norming experiment:
  int<lower=1> N_context;	      // number of contexts (items)
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

  // jitter:
  real<lower=0, upper=1> sigma_e; // jitter standard deviation 
}

transformed parameters {
  vector[N_context] omega;	// log-odds certainty
  vector[N_participant] epsilon_omega; // by-participant random intercepts for the log-odds certainty
  vector<lower=0, upper=1>[N_data] w;  // certainty on the unit interval

  // 
  // DEFINITIONS
  //
  
  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = sigma_omega[i] * z_omega[i];
  }

  // non-centered parameterization of the participant random intercepts:
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;

  // latent parameter before jittering is added:
  for (i in 1:N_data) {
    w[i] = inv_logit(omega[context[i]] + epsilon_omega[participant[i]]);
  }
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // contexts:
  z_omega ~ std_normal();
  sigma_omega ~ exponential(1);

  
  //
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts:
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ std_normal();


  //
  // LIKELIHOOD
  // 

  for (i in 1:N_data) {
    if (y[i] >= 0 && y[i] <= 1)
      target += likelihood_lpdf(
				y[i] |
				w[i],
				sigma_e
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
			      sigma_e
			      );
    else
      ll[i] = negative_infinity();
  }
}

