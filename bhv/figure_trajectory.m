function figure_trajectory(trajectory, model_path, init_and_end)

	%% The cell array input with 6-columns are the input. 
	cmap_subj  = [0, 0, 0];
	cmap_prey  = [.65, .2, .2];
	cmap_model = [.65, .65, .65];
	
	lw = 1.15; ft_size = 15;
	l_traj = size(trajectory, 1);
	
	fig_h = figure(); hold on;
	pl(1) = plot( trajectory(:, 1), trajectory(:, 2), '-', 'color', cmap_subj, 'linewidth', lw );
	pl(2) = plot( trajectory(:, 3), trajectory(:, 4), '-', 'color', cmap_prey, 'linewidth', lw );
	pl(3) = plot( model_path(:, 1), model_path(:, 2), '-', 'color', cmap_model, 'linewidth', lw );
	
	if init_and_end
		plot( trajectory(1, 1), trajectory(1, 2), 'o', 'color', cmap_subj, 'linewidth', lw );
		plot( trajectory(1, 3), trajectory(1, 4), 'o', 'color', cmap_prey, 'linewidth', lw );
		plot( model_path(1, 1), model_path(1, 2), 'o', 'color', cmap_model, 'linewidth', lw );
	
		plot( trajectory(l_traj, 1), trajectory(l_traj, 2), 'o', 'markerfacecolor', cmap_subj, 'markeredgecolor', cmap_subj, 'linewidth', lw );
		plot( trajectory(l_traj, 3), trajectory(l_traj, 4), 'o', 'markerfacecolor', cmap_prey, 'markeredgecolor', cmap_prey, 'linewidth', lw );
		plot( model_path(l_traj, 1), model_path(l_traj, 2), 'o', 'markerfacecolor', cmap_model, 'linewidth', lw );	
	end
	legend( pl, {'subject', 'prey', 'model', }, 'box', 'off', 'fontsize', ft_size );
end