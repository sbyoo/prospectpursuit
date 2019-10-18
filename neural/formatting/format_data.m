function format_data(  )

	% Add number of filter for predator position (x, y) and see whether it performs better or not. 
	dates	 = '20171209';
	FileName = [dates, '_Pacman.mat'];
	load(FileName);

	% Trial length
	st_idx	= 2; shift_bins	= 31;
	n_tr	=  length( psths );

	% function to calculate distance for two vector coordinates	
	cal_dist = @(x,y) sqrt(sum(x.^2+y.^2,2)); 
	
	% Concatenated psth
	concat_psth = [];
	
	% Concatenated pos, dir, velocity 
	subj_posx	= [];
	subj_posy	= [];
	subj_vel	= [];
	subj_dir	= [];
	
	prey_posx	= [];
	prey_posy	= [];
	prey_vel	= [];
	prey_dir	= [];

	pred_posx	= [];
	pred_posy	= [];
	pred_vel	= [];
	pred_dir	= [];	
	
	dist_fromPrey = [];
	dist_fromPred = [];
	angle_toPrey  = [];
	angle_toPred  = [];
	
	t_len	= []; % Time (seconds) in each frame
	n_prey	= [];
	n_npc	= [];
	tr_idx	= [];
	%%% For Each Trial, extract some variables
	for iTr = 1: n_tr				
		%%% Prey switch
		%	which prey is pursuited (for unswitched trials only)
		if vars{iTr}.numPrey > 1
			pursuit_idx = detect_unswitch(vars{iTr}.self_pos{1}, vars{iTr}.prey_pos);
		else
			pursuit_idx = 1;
		end
		
		if ~isnan( pursuit_idx )
			if ( vars{iTr}.numPrey == 1 & vars{iTr}.numNPCs == 2 )
				% Subject Information
				subj_posx = [ subj_posx; vars{iTr}.self_pos{1}(st_idx:end, 1) ];
				subj_posy = [ subj_posy; vars{iTr}.self_pos{1}(st_idx:end, 2) ];
				
				self_vels = sqrt( sum( diff( vars{iTr}.self_pos{1} ).^2, 2 ) );
				subj_vel  = [ subj_vel; self_vels ];
				
				self_dir = wrapTo2Pi( atan2( diff( vars{iTr}.self_pos{1}(:, 2)),  diff( vars{iTr}.self_pos{1}(:, 1)) ) );
				subj_dir = [ subj_dir; self_dir ];
				
				% Prey Information
				prey_posx = [ prey_posx; vars{iTr}.prey_pos{pursuit_idx}(st_idx:end, 1) ];
				prey_posy = [ prey_posy; vars{iTr}.prey_pos{pursuit_idx}(st_idx:end, 2) ];
				
				other_vels = sqrt( sum( diff( vars{iTr}.prey_pos{pursuit_idx} ).^2, 2 ) );
				prey_vel  = [ prey_vel; other_vels ];
				
				other_dir = wrapTo2Pi( atan2( diff( vars{iTr}.prey_pos{pursuit_idx}(:, 2)), ...
					diff( vars{iTr}.prey_pos{pursuit_idx}(:, 1)) ) );
				prey_dir = [ prey_dir; other_dir ];
				
				% Predator Information
				pred_posx = [ pred_posx; vars{iTr}.pred_pos{1}(st_idx:end, 1) ];
				pred_posy = [ pred_posy; vars{iTr}.pred_pos{1}(st_idx:end, 2) ];
				
				enemy_vels = sqrt( sum( diff( vars{iTr}.pred_pos{1} ).^2, 2 ) );
				pred_vel  = [ pred_vel; enemy_vels ];
				
				enemy_dir = wrapTo2Pi( atan2( diff( vars{iTr}.pred_pos{1}(:, 2)), ...
					diff( vars{iTr}.pred_pos{1}(:, 1)) ) );
				pred_dir = [ pred_dir; enemy_dir ];
				
				% Egocentric info
				dist_fromPrey = [ dist_fromPrey; ...
					cal_dist(vars{iTr}.prey_pos{pursuit_idx}(st_idx:end,1) - vars{iTr}.self_pos{1}(st_idx:end,1),...
					vars{iTr}.prey_pos{pursuit_idx}(st_idx:end,2)-vars{iTr}.self_pos{1}(st_idx:end,2))];
				
				dist_fromPred = [ dist_fromPred; ...
					cal_dist(vars{iTr}.pred_pos{1}(st_idx:end,1) - vars{iTr}.self_pos{1}(st_idx:end,1),...
					vars{iTr}.pred_pos{1}(st_idx:end,2)-vars{iTr}.self_pos{1}(st_idx:end,2))];
				
				angle_toPrey = [ angle_toPrey; ...
					wrapTo2Pi(atan2(vars{iTr}.prey_pos{pursuit_idx}(st_idx:end,2)-vars{iTr}.self_pos{1}(st_idx:end,2),...
					vars{iTr}.prey_pos{pursuit_idx}(st_idx:end,1)-vars{iTr}.self_pos{1}(st_idx:end,1)))];
				
				angle_toPred = [ angle_toPred; ...
					wrapTo2Pi(atan2(vars{iTr}.pred_pos{1}(st_idx:end,2)-vars{iTr}.self_pos{1}(st_idx:end,2),...
					vars{iTr}.pred_pos{1}(st_idx:end,1)-vars{iTr}.self_pos{1}(st_idx:end,1)))];
				
				% Neural info
				tr_psth = psths{iTr}(:,shift_bins+1:end-shift_bins)';
				concat_psth = [ concat_psth; tr_psth];
				
				% time resolution
				len_dpts = size( tr_psth, 1 );
				t_len = [t_len; length(vars{iTr}.time_res(2:end)) ];
				
				% number of prey
				n_prey = [n_prey; vars{iTr}.numPrey];
				n_npc  = [n_npc; vars{iTr}.numNPCs];
				
				% trial-index
				tr_idx = [tr_idx; repmat( iTr, len_dpts, 1)];
			end
		end
	end
	
	%%%% Trial-level exclusion
	trial_exclusion_idx = find( t_len > 1199 );	%% remove time-out	
	artifact_idx = [];
	for iE = 1: length(trial_exclusion_idx)
		idcs = find( tr_idx == trial_exclusion_idx(iE) );
		artifact_idx = [artifact_idx; idcs];
	end
	
	% Removing emptied ones.
	concat_psth(artifact_idx,:) = [];

	subj_posx(artifact_idx)	= [];
	subj_posy(artifact_idx) = [];
	subj_dir(artifact_idx)	= [];
	subj_vel(artifact_idx)	= [];
	
	prey_posx(artifact_idx)	= [];
	prey_posy(artifact_idx) = [];
	prey_dir(artifact_idx)	= [];
	prey_vel(artifact_idx)	= [];

	pred_posx(artifact_idx)	= [];
	pred_posy(artifact_idx) = [];
	pred_dir(artifact_idx)	= [];
	pred_vel(artifact_idx)	= [];
	
	dist_fromPrey(artifact_idx) = [];
	dist_fromPred(artifact_idx) = [];
	angle_toPrey(artifact_idx) = [];
	angle_toPred(artifact_idx) = [];
	
	trial_exclusion_idx = setdiff( 1:n_tr, unique(tr_idx) ); 
	create_DM;
	
	% Match the format
	numParams = [225, 12, 12, 225, 12, 12, 225, 12, 12, 12, 12, 12, 12];
	reg_weights = repmat(10, 1, length(numParams));
	vars_explained = {'Pos', 'Dir', 'Vel', 'PreyPos', 'PredDir', 'PredVel', ...
		'PredPos', 'PredDir', 'PredVel', 'Dist', 'Angle', 'PredDist', 'PredAngle'};
	
	cd('../Data');
	savestr = ['Data_H', dates, '.mat'];
	save(savestr, 'DM', 'numParams', 'reg_weights', 'vars_explained');
	cd('..');
end