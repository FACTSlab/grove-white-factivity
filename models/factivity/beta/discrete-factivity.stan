functions { 
  // the discrete-factivity model likelihood:
  real likelihood_lpdf(
		       real y,
		       real predicate,
		       real world,
		       real eta,
		       real phi
		       ) {
    real mu_1 = inv_logit(eta);

    real alpha1 = mu_1 * phi;
    real beta1 = (1 - mu_1) * phi;

    real alphaw = world * phi;
    real betaw = (1 - world) * phi;
    
    return log_mix(
		   predicate,
		   beta_lpdf(y | alpha1, beta1),
		   beta_lpdf(y | alphaw, betaw)
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
  
  // veridicality parameters:
  vector<lower=0>[N_predicate] sigma_nu; // by-predicate standard deviations for the log-odds of projection
  vector[N_predicate] z_nu; // by-predicate z-scores for the log-odds of projection

  // contexts:
  vector[N_context] z_omega;   // by-context z-scores for the log-odds certainty

  
  // 
  // RANDOM EFFECTS
  // 
  
  // by-participant random intercepts for the log-odds of veridicality:
  real<lower=0> sigma_epsilon_nu;     // global scaling factor
  vector[N_participant] z_epsilon_nu; // by-participant z-scores

  // by-participant random intercepts for the log-odds certainty:
  real<lower=0> sigma_epsilon_omega;	 // global scaling factor
  vector[N_participant] z_epsilon_omega; // by-participant z-scores
  
  // likelihood parameters:
  real<lower=0> eta;		// absolute value of 0/1 component
  real<lower=0> phi;		// beta sample size
}

transformed parameters {
  vector[N_predicate] nu;	// log-odds of projection
  vector[N_participant] epsilon_nu; // by-participant intercepts for the log-odds of projection
  vector[N_data] v;  // log-odds of projection with participant intercepts added
  vector[N_context] omega;	// log-odds certainty
  vector[N_participant] epsilon_omega; // by-participant intercepts for the log-odds certainty
  vector[N_data] w;	 // log-odds certainty with participant intercepts added
  vector<lower=0, upper=1>[N_data] y1; // transformed data
  
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
  epsilon_nu = sigma_epsilon_nu * z_epsilon_nu;
  epsilon_omega = sigma_epsilon_omega * z_epsilon_omega;

  // latent parameters:
  for (i in 1:N_data) {
    v[i] = inv_logit(nu[predicate[i]] + epsilon_nu[participant[i]]);
    w[i] = inv_logit(omega[context[i]] + epsilon_omega[participant[i]]);
    y1[i] = (y[i] * (N_data - 1) + 0.5) / N_data;
  }
}

model {
  //
  // FIXED EFFECTS
  // 
  
  // predicates:
  sigma_nu ~ exponential(1);
  z_nu ~ std_normal;

  // contexts:
  z_omega ~ std_normal;

  
  //
  // RANDOM EFFECTS
  //
  
  // by-participant random intercepts:
  sigma_epsilon_nu ~ exponential(1);
  z_epsilon_nu ~ std_normal;
  sigma_epsilon_omega ~ exponential(1);
  z_epsilon_omega ~ std_normal;


  //
  // LIKELIHOOD
  // 

  // parameters:
  eta ~ normal(1.5, 1);
  phi ~ exponential(0.1);

  // definition:
  for (i in 1:N_data) {
    if (y1[i] > 0 && y1[i] < 1)
      target += likelihood_lpdf(
				y1[i] |
				v[i],
				w[i],
				eta,
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
    if (y1[i] > 0 && y1[i] < 1)
      ll[i] = likelihood_lpdf(
			      y1[i] |
			      v[i],
			      w[i],
			      eta,
			      phi
			      );
    else
      ll[i] = negative_infinity();
  }
}
