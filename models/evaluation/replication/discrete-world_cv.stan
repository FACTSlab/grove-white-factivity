functions {
  real truncated_normal_lpdf(real x, real mu, real sigma, real a, real b) {
    return normal_lpdf(x | mu, sigma) -
      log_diff_exp(normal_lcdf(b | mu, sigma),
		   normal_lcdf(a | mu, sigma));
  }

  // the discrete-world model likelihood:
  real likelihood_lpdf(
		       real y,
		       real predicate,
		       real world,
		       real sigma
		       ) {
    return log_mix(
		   world,
		   truncated_normal_lpdf(y | 1, sigma, 0, 1),
		   truncated_normal_lpdf(y | predicate, sigma, 0, 1)
		   );
  }
}

data {
  // our replication of the Degen and Tonhauser (2021) projection experiment:
  int<lower=1> N_predicate;		    // number of predicates
  int<lower=1> N_context;		    // number of contexts
  int<lower=1> N_participant;		    // number of participants
  int<lower=1> N_data_tr;		    // number of training data points
  int<lower=1> N_data_te;		    // number of test data points
  vector<lower=0, upper=1>[N_data_tr] y_tr; // training response (between 0 and 1)
  vector<lower=0, upper=1>[N_data_te] y_te; // test response (between 0 and 1)
  array[N_data_tr] int<lower=1, upper=N_predicate> predicate_tr; // map from training data points to predicates
  array[N_data_te] int<lower=1, upper=N_predicate> predicate_te; // map from test data points to predicates
  array[N_data_tr] int<lower=1, upper=N_context> context_tr; // map from training data points to contexts
  array[N_data_te] int<lower=1, upper=N_context> context_te; // map from test data points to contexts
  array[N_data_tr] int<lower=1, upper=N_participant> participant_tr; // map from training data points to participants
  array[N_data_te] int<lower=1, upper=N_participant> participant_te; // map from training data points to participants

  // predicate log-odds means and standard deviations, obtained from the projection experiment:
  vector[N_predicate] mu_nu;
  vector<lower=0>[N_predicate] sigma_nu;
  
  // context log-odds means and standard deviations, obtained from the projection experiment:
  vector[N_context] mu_omega;
  vector<lower=0>[N_context] sigma_omega;
}

parameters {
  // 
  // FIXED EFFECTS
  // 
  
  // predicates:
  vector[N_predicate] z_nu; // by-predicate z-scores for the log-odds of projection

  // contexts:
  vector[N_context] z_omega;   // by-context z-scores for the log-odds certainty

  // 
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts for the log-odds of projection:
  real<lower=0> sigma_epsilon_nu;     // global scaling factor
  vector[N_participant] z_epsilon_nu; // by-participant z-scores

  // by-participant random intercepts for the log-odds certainty:
  real<lower=0> sigma_epsilon_omega;	 // global scaling factor
  vector[N_participant] z_epsilon_omega; // by-participant z-scores

  // jitter:
  real<lower=0, upper=1> sigma_e; // jitter standard deviation
}

transformed parameters {
  vector[N_predicate] nu;	// log-odds of projection
  vector[N_participant] epsilon_nu; // by-participant intercepts for the log-odds of projection
  vector<lower=0, upper=1>[N_data_tr] v_tr; // probability of projection for training data
  vector<lower=0, upper=1>[N_data_te] v_te; // probability of projection for test data
  vector[N_context] omega;		    // log-odds certainty
  vector[N_participant] epsilon_omega; // by-participant intercepts for the log-odds certainty
  vector<lower=0, upper=1>[N_data_tr] w_tr; // certainty on the unit interval for training data
  vector<lower=0, upper=1>[N_data_te] w_te; // certainty on the unit interval for test data

  // 
  // DEFINITIONS
  //
  
  // non-centered parameterization of the log-odds of projection:
  for (i in 1:N_predicate) {
    nu[i] = mu_nu[i] + sigma_nu[i] * z_nu[i];
  }

  // non-centered parameterization of the log-odds certainty:
  for (i in 1:N_context) {
    omega[i] = mu_omega[i] + sigma_omega[i] * z_omega[i];
  }

  // non-centered parameteriziation of the participant random intercepts:
  epsilon_nu = sigma_epsilon_nu * z_epsilon_nu;
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;

  // latent parameters before jittering is added (training data):
  for (i in 1:N_data_tr) {
    v_tr[i] = inv_logit(nu[predicate_tr[i]] + epsilon_nu[participant_tr[i]]);
    w_tr[i] = inv_logit(omega[context_tr[i]] + epsilon_omega[participant_tr[i]]);
  }

  // latent parameters before jittering is added (training data):
  for (i in 1:N_data_te) {
    v_te[i] = inv_logit(nu[predicate_te[i]] + epsilon_nu[participant_te[i]]);
    w_te[i] = inv_logit(omega[context_te[i]] + epsilon_omega[participant_te[i]]);
  }

}

model {
  //
  // FIXED EFFECTS
  // 
  
  // predicates:
  z_nu ~ std_normal();

  // contexts:
  z_omega ~ std_normal();

  
  //
  // RANDOM EFFECTS
  //
  
  // by-participant random intercepts:
  sigma_epsilon_nu ~ exponential(1);
  z_epsilon_nu ~ std_normal();
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ std_normal();

  
  //
  // LIKELIHOOD
  // 
  
  for (i in 1:N_data_tr) {
    if (y_tr[i] >= 0 && y_tr[i] <= 1)
      target += likelihood_lpdf(
				y_tr[i] |
				v_tr[i],
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
				 v_tr[i],
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
				 v_te[i],
				 w_te[i],
				 sigma_e
				 );
    else
      ll_te[i] = negative_infinity();
  }
}
