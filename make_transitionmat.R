make_transitionmat = function(maze, show_maze = TRUE) {
	maze$stateind = 1:maze$nstates # position coordinates for each state
	maze$state_y = ((maze$stateind-1) %% maze$m) + 1
	maze$state_x = floor((maze$stateind-1) / maze$m) + 1
	maze$targetdist = sqrt((maze$state_y - maze$target_y)^2 + (maze$state_x - maze$target_x)^2) # euclidean distance of all positions from traget

	# set up transition matrix
	maze$T = array(0, c(maze$nstates, maze$nactions, maze$nstates))

	for (state in 1:maze$nstates) {
		# action 1: up
		idx = which((maze$state_y == (maze$state_y[state] + 1)) & (maze$state_x == (maze$state_x[state] + 0)))
		maze$T[state,1,idx] = 1
		# action 2: right
		idx = which((maze$state_y == (maze$state_y[state] + 0)) & (maze$state_x == (maze$state_x[state] + 1)))
		maze$T[state,2,idx] = 1
		# action 3: down
		idx = which((maze$state_y == (maze$state_y[state] - 1)) & (maze$state_x == (maze$state_x[state] + 0)))
		maze$T[state,3,idx] = 1
		# action 4: left
		idx = which((maze$state_y == (maze$state_y[state] + 0)) & (maze$state_x == (maze$state_x[state] - 1)))
		maze$T[state,4,idx] = 1
	}


	# insert wall
	maze$wall = NULL
	# horizontal walls
	for (i in 1:length(maze$wall_coords_x)) {
		maze$wall = c(maze$wall, which(maze$state_x == maze$wall_coords_x[[i]][1] & (maze$state_y > maze$wall_coords_x[[i]][2] & maze$state_y < maze$wall_coords_x[[i]][4])))
	}

  # vertical walls
	for (i in 1:length(maze$wall_coords_y)) {
		maze$wall = c(maze$wall, which(maze$state_y == maze$wall_coords_y[[i]][2] & (maze$state_x > maze$wall_coords_y[[i]][1] & maze$state_x < maze$wall_coords_y[[i]][3])))
	}

	# block all transitions from and into the wall
	maze$T[,,maze$wall] = 0
	maze$T[maze$wall,,] = 0

	# set reward function: 0 everywhere, and -0.1 if bumping into the wall
	cT = maze$T
	maze$R = (apply(cT, c(1, 2), max) - 1)*0.1

	# add reward location to reward function
	maze$R[which(maze$state_y == maze$target_y & maze$state_x == maze$target_x),] = 1

	# transition to previous position if hitting wall or edge
	X = apply(maze$T[, , ], c(1, 2), max)
	for (i in 1:maze$nstates) {
		if (any(X[i,]==0)) {
			maze$T[i,which(X[i,] == 0),i] = 1
		}
	}

	connectmat = apply(maze$T, c(1, 3), max)


  if (show_maze) {
		layout(t(1:2))
		# make gray maze image
		cmaze = matrix(1, maze$m, maze$m)
		cmaze[maze$wall] = 0
		cmaze[which(maze$state_y == maze$target_y & maze$state_x == maze$target_x)] = 2
		image(cmaze, col = hcl.colors(10, 'Grays'), axes = FALSE)

		# show reward function
		tmp = matrix(apply(maze$R, 1, mean), 20, 20)
		tmp[tmp == -0.025] = -1
		tmp[tmp == -0.05] = -1
		tmp[tmp == 0] = NA
		tmp[maze$wall] = NA
		image(tmp, col = hcl.colors(20, 'Blue-Red 2'), axes = FALSE)

	}

	return(maze)

}
