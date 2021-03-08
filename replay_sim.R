# Example of RL in a square maze with some walls in it
# With or without Replay
# Very simple instaitaion of backward replay at end of episode/trial
# Start position can be random

## Written by Nicolas Schuck, Jan 2021 

require(viridis)
source('/gdrive/workbench/R/tools/misc/gen_functions.R')
make_transitionmat = dget('/gdrive/workbench/gitrepos/replay_review_simulations/make_transitionmat.R')
# environment
maze = NULL
maze$nactions = 4 # left right up down
maze$actionnames = c('up', 'right', 'down', 'left')
maze$m = 20 # size of gridworld (number of tiles along one axis)
maze$nstates = maze$m*maze$m
maze$target_y = 6 # reward location y coord
maze$target_x = 5 # reward location x coord
maze$wall_coords_y = list(c(2, 10, 8, 10), c(12, 10, 19, 10))
maze$wall_coords_x = list(c(10, 2, 10, 19))
maze = make_transitionmat(maze)

nepisodes = 250
maxwalklength = 1000
niter = 20
nreplays = c(0, 1, 5)

nsteps = avgrew = array(0, dim = c(nepisodes, niter, length(nreplays)))

alpha = 0.6
temp = 1
gamma = 0.99

ShowInfo = ShowPath = ShowReplayQ =  FALSE

for (replaylevel in 1:length(nreplays)) { # the same Q learner with different amounts of replay
	cat(paste('(# replays:', nreplays[replaylevel], 'starting): \n'))
	for (citer in 1:niter) { # repeat simulations for stability of results
		Q = matrix(0, maze$nstates, 4)
		a = S = rew = array(NA, dim = c(maxwalklength, nepisodes))
		# random start position in minimum distance
		S[1, ] = sample(which(maze$cmaze == 1 & maze$targetdist > 10), nepisodes, replace = TRUE) # random start position far enough from goal

		for (episode in 1:nepisodes) { # one episode is a walk until the goal was found
			for (trial in 2:maxwalklength) {
				actionprobs = exp(temp*Q[S[trial-1, episode],])/sum(exp(temp*Q[S[trial-1, episode],]))
				# determine action according to softmax
				a[trial, episode] = sample(1:4, 1, prob = actionprobs)
				# get next state
				S[trial, episode] = which(maze$T[S[trial-1, episode], a[trial, episode], ] == 1)
				# observe reward
				rew[trial, episode] = maze$R[S[trial-1, episode], a[trial, episode]]
				# one step backup!
				Q[S[trial-1, episode], a[trial, episode]] = Q[S[trial-1, episode], a[trial, episode]] + alpha*(rew[trial, episode] + gamma*max(Q[S[trial, episode], ]) - Q[S[trial-1, episode], a[trial, episode]])

				# if target was found, exit, and replay if nreplays > 0
				if (rew[trial, episode] > 0) {
					if (nreplays[replaylevel] > 0) {
						for (ct in 1:nreplays[replaylevel]) {

							repisode = episode #for cross episode replay: sample(max(1, episode-5):episode, 1)
							nrtrials = 1000 - sum(is.na(S[,repisode]))
							# grab sequence of states etc leading up to goal
							stateseq = S[nrtrials-seq(1, nrtrials - 1, 1), repisode]
							actionseq = a[nrtrials-seq(1, nrtrials - 1, 1)+1, repisode]
							rewardseq = rew[nrtrials-seq(1, nrtrials - 1, 1)+1, repisode]

							if (ShowReplayQ) {
								# store max Q values before(!) replay
								cQpre = matrix(apply(Q, 1, function(x) x[which.max(abs(x))]), 20, 20)
							}

							# REPLAY (backwards)
							for (crtrial in 2:(trial-1)) {
								Q[stateseq[crtrial], actionseq[crtrial]] = Q[stateseq[crtrial], actionseq[crtrial]] + alpha*(rewardseq[crtrial] + gamma*Q[stateseq[crtrial-1], actionseq[crtrial-1]] - Q[stateseq[crtrial], actionseq[crtrial]])
							}

							# illustration functions
							if (ShowReplayQ & episode == 1) {
								# max Q values after(!) replay

								cQpost = matrix(apply(Q, 1, function(x) x[which.max(abs(x))]), 20, 20)

								# normalize preQ (for coloring, to make sure pre and post are on same scale)
								cmax = max(cQpost, na.rm = TRUE)
								cmin = -min(cQpost, na.rm = TRUE)
								cQpre[cQpre>0] = cQpre[cQpre>0]/cmax
								cQpre[cQpre<0] = cQpre[cQpre<0]/cmin
								cQpre[maze$wall] = NA

								# normalize postQ (for coloring, to make sure pre and post are on same scale)
								cQpost[cQpost>0] = cQpost[cQpost>0]/cmax
								cQpost[cQpost<0] = cQpost[cQpost<0]/cmin
								cQpost[maze$wall] = NA
								# remove low Q values to avoid visual over-interpretation
								cQpost[abs(cQpost) < 0.1] = NA
								cQpre[abs(cQpre) < 0.1] = NA

								image(cQpre, col = hcl.colors(20, 'Blue-Red 2'), axes = FALSE)
								image(cQpost, col = hcl.colors(20, 'Blue-Red 2'), axes = FALSE)
								browser()
							}
						}
					}
					break
				}
				if (ShowInfo) {
					cat(paste('trial:', trial, 'x', state_x[S[trial-1, episode]], 'y', state_y[S[trial-1, episode]], '->', actionnames[a[trial, episode]], '->', 'x', state_x[S[trial, episode]], 'y', state_y[S[trial, episode]], 'R:', r, '|', '\n'))
				}

				if (ShowPath & (trial > 10)) {
					cmaze = maze2
					cmaze[cbind(state_y[S[(trial-10):trial, episode]], state_x[S[(trial-10):trial, episode]])] = seq(-10, -1, length.out = 11)
					image(cmaze, zlim = c(-10, 2))
					Sys.sleep(0.01)
				}
			}
			if (ShowReplayQ & nreplays[replaylevel] > 0 & (episode == 50 | episode == 250)) {
				cQpost = matrix(apply(Q, 1, function(x) x[which.max(abs(x))]), 20, 20)
				cmax = max(cQpost, na.rm = TRUE)
				cmin = -min(cQpost, na.rm = TRUE)
				cQpost[cQpost>0] = cQpost[cQpost>0]/cmax
				cQpost[cQpost<0] = cQpost[cQpost<0]/cmin
				cQpost[maze$wall] = NA
				# remove low Q values to avoid visual over-interpretation
				cQpost[abs(cQpost) < 0.1] = NA
				image(cQpost, col = hcl.colors(20, 'Blue-Red 2'), axes = FALSE)
				browser()
			}
			nsteps[episode, citer, replaylevel] = trial
			avgrew[episode, citer, replaylevel] = mean(rew[1:trial, episode], na.rm = TRUE)
		}
		cat(paste((citer/niter)*100, '% |'))
	}
	cat(paste('| \n'))
}

### PLOT PERFORMANCE
cmeans = apply(nsteps, c(1, 3), mean, na.rm = TRUE)
csds = apply(nsteps, c(1, 3), std.error)
matplot(cmeans, type = 'l', ylim = c(0, 1000), col = viridis(10, option = 'E')[c(1, 7, 10)], lty = 1, lwd = 2, bty = 'n', cex.axis = 1.2, cex.lab = 1.2, ylab = 'Number of steps to goal', xlab = 'Episode')
for (i in 1:3) {
	se_shadows(1:nepisodes, cmeans[,i], csds[,i], ccol = viridis(10, option = 'E', , alpha = 0.2)[c(1, 7, 10)[i]])
}
legend('topright', legend = c('No replay', 'Replay (1x)', 'Replay (5x)'), lty = 1, lwd = 3, bty = 'n', col = viridis(10, option = 'E')[c(1, 7, 10)], cex = 1.2)

dim(nsteps)
colMeans(apply(nsteps, c(2, 3), function(x) min(which(x<50))))

#### PLOT REWARD RATE
cmeans = apply(avgrew, c(1, 3), mean)
csds = apply(avgrew, c(1, 3), std.error)
matplot(cmeans, type = 'l', col = viridis(10, option = 'E')[c(1, 7, 10)], lty = 1, lwd = 2, bty = 'n', cex.axis = 1.2, cex.lab = 1.2, ylab = 'Mean reward collected', xlab = 'Episode')
for (i in 1:3) {
	se_shadows(1:nepisodes, cmeans[,i], csds[,i], ccol = viridis(10, option = 'E', , alpha = 0.2)[c(1, 7, 10)[i]])
}
legend('bottomright', legend = c('No replay', 'Replay (1x)', 'Replay (5x)'), lty = 1, lwd = 3, bty = 'n', col = viridis(10, option = 'E')[c(1, 7, 10)], cex = 1.2)
