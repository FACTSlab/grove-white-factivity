functions {
  real truncated_normal_lpdf(real x, real mu, real sigma, real a, real b) {
    return normal_lpdf(x | mu, sigma) -
      log_diff_exp(normal_lcdf(b | mu, sigma),
		   normal_lcdf(a | mu, sigma));
  }

  // the norming-gradient model likelihood:
  real likelihood_lpdf(
		       real y,
		       real world,
		       real sigma
		       ) {
    return truncated_normal_lpdf(y | world, sigma, 0, 1);
  }
}

data {
  // data from the the Degen and Tonhauser (2021) norming experiment:
  int<lower=1> N_context;		    // number of contexts (items)
  int<lower=1> N_participant;		    // number of participants
  int<lower=1> N_data_tr;		    // number of training data points
  int<lower=1> N_data_te;		    // number of test data points
  vector<lower=0, upper=1>[N_data_tr] y_tr; // training response (between 0 and 1)
  vector<lower=0, upper=1>[N_data_te] y_te; // test response (between 0 and 1)
  array[N_data_tr] int<lower=1, upper=N_context> context_tr; // map from training data points to contexts
  array[N_data_te] int<lower=1, upper=N_context> context_te; // map from test data points to contexts
  array[N_data_tr] int<lower=1, upper=N_participant> participant_tr; // map from test data points to participants
  array[N_data_te] int<lower=1, upper=N_participant> participant_te; // map from test data points to participants
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
  vector<lower=0, upper=1>[N_data_tr] w_tr;  // certainty on the unit interval for training data
  vector<lower=0, upper=1>[N_data_te] w_te;  // certainty on the unit interval for test data

  // 
  // DEFINITIONS
  //
  
  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = sigma_omega[i] * z_omega[i];
  }

  // non-centered parameterization of the participant random intercepts:
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;

  // latent parameter before jittering is added (training data):
  for (i in 1:N_data_tr) {
    w_tr[i] = inv_logit(omega[context_tr[i]] + epsilon_omega[participant_tr[i]]);
  }

  // latent parameter before jittering is added (test data):
  for (i in 1:N_data_te) {
    w_te[i] = inv_logit(omega[context_te[i]] + epsilon_omega[participant_te[i]]);
  } 
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // contexts:
  z_omega ~ normal(0, 1);
  sigma_omega ~ exponential(1);

  
  //
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts:
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ normal(0, 1);


  //
  // LIKELIHOOD
  // 

  for (i in 1:N_data_tr) {
    if (y_tr[i] >= 0 && y_tr[i] <= 1)
      target += likelihood_lpdf(
				y_tr[i] |
				w_tr[i],
				sigma_e
				);
    else
      target += negative_infinity();
  }
}

generated quantities {
  vector[N_data_tr] ll_tr;	// log-likelihoods on training data
  vector[N_data_te] ll_te;	// log-likelihoods on test data
  
  // definitions:
  for (i in 1:N_data_tr) {
    if (y_tr[i] >= 0 && y_tr[i] <= 1)
      ll_tr[i] = likelihood_lpdf(
				 y_tr[i] |
				 w_tr[i],
				 sigma_e
				 );
    else
      ll_tr[i] = negative_infinity();
  }
  for (i in 1:N_data_te) {
    if (y_te[i] >= 0 && y_te[i] <= 1)
      ll_te[i] = likelihood_lpdf(
				 y_te[i] |
				 w_te[i],
				 sigma_e
				 );
    else
      ll_te[i] = negative_infinity();
  }
}

