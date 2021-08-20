all: figure1/fig1c_numsteps.pdf

figure1/fig1c_numsteps.pdf: replay_sim.R make_transitionmat.R gen_functions.R
	Rscript replay_sim.R
