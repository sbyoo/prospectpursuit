function trajectory = convert_trial_to_trajectory(trial, l_traj)

	%% This function takes full length trial into 1-second trajectory. 
	%	This may have overlap, but track the random seed in current case. 
	%	It takes unit length (1-second) as a input too. 
	%	Shape of the trial is n_obs x 4 (which is x_coordinate and y_coordinate of all agents). 
	
	l_trial = length( trial );
	n_chunk = ceil( l_trial/l_traj );
	
	% Initial and last piece should be fixed. 
	% Middle index starts from 
	traj_idx{1} = 1 : l_traj; 
	traj_idx{n_chunk} = l_trial-l_traj+1:l_trial;
	trajectory{1} = trial( traj_idx{1}, : );
	trajectory{n_chunk} = trial( traj_idx{n_chunk}, : );
	
	for nC = 2 : (n_chunk-1)
		sel_range = floor( quantile( traj_idx{nC-1}, 4 ) );
		rng(nC*5); % Random seed assignment. 
		start_pts = randi( [sel_range(2), sel_range(3)], 1, 1 );
		traj_idx{1, nC} = (start_pts+1) : (start_pts+l_traj);
		trajectory{nC}	= trial( traj_idx{1, nC}, : );		
	end
end