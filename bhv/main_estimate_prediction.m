function main_estimate_prediction( )

	%% Current function is to estimate what order of physics that agents use for their strategic prediction. 
	%	try to replicate the original paper from Yoo et al., 2019.
    %   The input is cell array with n_trial x 1. In each entry, it
    %   contains 4 column, which corresponds to subj_x_pos, subj_y_pos, prey_x_pos, prey_y_pos in monitor pixel. 
	
    %   NOTE) It does not use graident descent but perform grid search over parameter space. 
	clear all; close all; clc;
	
	% Load the data
	exc_path    = fileparts( which( mfilename ) ); cd( exc_path ); addpath(exc_path);
	data_path   = fullfile( exc_path, ['/data']); 
	subjID      = {'[K]'};
	
	%% hard coded inputs (matching with the paper).
	l_order = 3;        % how many orders of physics are used for testing.
    l_match = 7;        % Initial n-points are matched (since the multiorder derivatives are being used, initial points are matched).
	l_traj	= 61;       % hard-coded length for describing the length. (61 (1seconds) for other)
	n_rnd   = 7921;      % number of random trajectories (for example dataset, the number of data set match with this)
	no_inertia = false;  % test the effect of inertia.
	if no_inertia
		iner_str = 'intertia_on';
	else
		iner_str = 'intertia_off';		
	end
	
	% The prediction - force matrix: 201 x 201;
	n_params	= 201; % the resolution of grids to test.
	vect_pred	= linspace( -200, 200, n_params );
	vect_force	= linspace( -1, 1, n_params );
		
	fig_on = true;  % Figure related variables.
	for iSubj = 1 : length(subjID)
        % Load the data.
        cd( data_path );        
		load( [ subjID{iSubj}, '1prey_0pred_data.mat'] );
        cd( exc_path );
        
		% data driven numerical information: length of trials.
		rng(1234);
		rand_idx  = datasample( [1:length( traj_data )], 1, n_rnd, 'replace', false );
		traj_data = traj_data(rand_idx);
		
		%
		n_trial  = length( traj_data );
		iCnt	 = 0; good_fit = 0;
		min_cost = zeros( 1, l_order );
		cost_val = cell( n_trial, 1 ); min_sub = cell( 1, l_order );
		overall_hm	= zeros( n_params, n_params, l_order );
		raw_hm		= zeros( n_params, n_params, l_order );
        for iTr = 1 : n_trial
            if size( traj_data{iTr}, 1 ) > l_traj
                % Make a function that takes full trajectory and spit out the
                trajectory = convert_trial_to_trajectory(traj_data{iTr}, l_traj);
                
                % calculate the derivation of the prediction.
                for iTJ = 1 : length( trajectory )
                    iCnt = iCnt+1;
                    
                    subj_pos = trajectory{iTJ}(:, 1:2);  
                    prey_pos = cell(1, l_order+1);
                    for iO = 1 : l_order+1 % There might be cleaner code, but I am just lazy.
                        prey_pos{iO} = trajectory{iTJ}(:, 3:4); % 1st column is filled with positional information.
                    end
                    
                    % Calculating the inertia.
                    %   Inertia is defined as difference of subject position over one time point.
                    if no_inertia
                        inertia	= zeros(size(subj_pos, 1), 2);
                    else
                        inertia	= [zeros(1, 2); diff( subj_pos )];
                    end
                    
                    % Obtain the cost in grid search.
                    %   Can obtain trajectory of generative model at the
                    %   second output argument of the infer_traj func.
                    cost_val{iTJ} = zeros( n_params, n_params, l_order);
                    for iPP = 1 : n_params
                        for iFP = 1 : n_params
                            [cost_val{iCnt, 1}(iPP, iFP, :), ~] = infer_traj(subj_pos, inertia, prey_pos, ...
                                vect_pred(iPP), vect_force(iFP), l_order, l_traj, l_match);
                        end
                    end
                    
                    for nO = 1 : l_order
                        [min_cost(iCnt, nO), min_idx] = min( reshape( cost_val{iCnt}(:, :, nO), 1, n_params^2) );
                        [i_row, i_col] = ind2sub( [n_params, n_params], min_idx);
                        min_sub{1, nO}(iCnt, :) = [i_row, i_col];
                        
                        % Overall heatmap of the cost function.
                        %   In current version, it is euclidean distance
                        %   between the actual and model trajectory.
                        min_hm = min(min(cost_val{iCnt, 1}(:, :, nO)) );
                        max_hm = max(max(cost_val{iCnt, 1}(:, :, nO)) );
                        
                        norm_hm = (cost_val{iCnt, 1}(:, :, nO) - min_hm)./(max_hm-min_hm);
                        overall_hm(:, :, nO) = overall_hm(:, :, nO) + norm_hm;
                        raw_hm(:, :, nO) = raw_hm(:, :, nO) + cost_val{iCnt, 1}(:, :, nO);
					end
                    
					if min_sub{1, 2}(iCnt, 1) >0
						good_fit = good_fit+1;
					end
					
                    %% Plotting part.
                    if fig_on && min_sub{1, 2}(iCnt, 1) >0 && rem(iCnt, 100) == 99 % The flag should be turned on.
                        for iO = 1 : l_order
                            sel_sub = min_sub{1, iO}(iCnt, : );
                            [~, best_traj] = infer_traj(subj_pos, inertia, prey_pos, ...
                                vect_pred(sel_sub(1)), vect_force(sel_sub(2)), l_order, l_traj, l_match);
                            figure_trajectory( trajectory{iTJ}, best_traj{iO}, true ); drawnow;
                        end
                    end
				end
			end
			
			if good_fit > 500
				break;
			end
        end
		
        %% Calculating the minimum cost resulting physical derivation.
		[~, min_meth] = min(min_cost, [], 2);
		n_meth	 = zeros( l_order, 1 );
		for nO = 1 : l_order
			non_same_idx = sort( unique( [find( diff( min_cost(:, [1, 2]),[], 2)~=0); find(diff(min_cost(:, [2, 3]), [], 2)~=0) ] ) );
			n_meth(nO, 1)= sum(min_meth(non_same_idx) == nO);
		end
		cost_all = nansum( min_cost ) ;
		cd( exc_path );
		save('temp.mat', 'min_sub', 'min_cost');
	end
end


function [cost_val, model_pos] = infer_traj(subj_pos, inertia, prey_pos, pred_param, force_param, l_order, l_traj, l_match)

    %% This function provides inferred trajectory as well as the cost (either SSE or MLE).
    %   Input is the positions of agents, inclusion of the inertia,
    %   parameters (prediction and force), orders of physics you want to test, and initial point matches. 
    %   This only has physics-based prediction model but 
	max_spd		= 23; % in pixel unit
	
	prey_vect	= zeros( l_traj, 2, l_order );
	cost_val	= zeros( 1, 1, l_order );
	model_pos	= cell( l_order, 1 );
	for nO = 2 : l_order+1
		% Note) the initial value is filled with zeros.
		% Note) In original code, it works like Taylor expansion.
		%	Thus, delta(position)+(0.5)delta(velocity)+(0.25)delta(acceleration)+...        
		const = 1^(nO-2); % This const can be other value than 1. 
		prey_pos{1, nO} = const*diff(prey_pos{1, nO-1});

		% Estimate the next position: current position + tau*(dPos/dt)
		%   generic equation format: pred_pos = curr_pos + tau*(diff_info);
		prey_vect(:, :, nO-1) = [ zeros(nO-1, 2);  prey_pos{1, nO} ];
		exp_pos = pred_param*sum(prey_vect, 3);
		model_pos{nO-1, 1}(1:l_match, :) = subj_pos(1:l_match, : );
		dir_vect = zeros(l_traj, 2);
		for iPath = l_match+1 : l_traj
			dir_vect(iPath, :) = exp_pos(iPath, :)-model_pos{nO-1, 1}(iPath-1, :);
			
			% Force parameter
			dir_vect(iPath, :) = force_param*(dir_vect(iPath, :));
			
			% Inertia
			dir_vect(iPath, :) = dir_vect(iPath, :)+inertia(iPath-1, :);
			
			% Normalize
			mag_vect = norm(dir_vect(iPath, :));
			dir_vect(iPath, :) = (dir_vect(iPath, :)./(mag_vect) );

			% Scaled to max speed
			scaled_vect = max_spd*dir_vect(iPath, :);
			
			% Update the model position.
			model_pos{nO-1, 1}(iPath, :) = model_pos{nO-1, 1}(iPath-1, :)+scaled_vect;
		end

		% Compare the cost between predicted position and actual position.
		orig_rng	= (l_match+1:l_traj-1);
		fut_rng		= (l_match:l_traj-2);
		cost_val(1, 1, nO-1) = nansum( sqrt( nansum( subj_pos(orig_rng, :) - model_pos{nO-1, 1}(fut_rng, :) ).^2) );
	end
end