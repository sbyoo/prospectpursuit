function pursuit_idx = detect_unswitch(subj_pos, preys_pos)
    t_len = length(subj_pos);
	% The input in this function is 2 prey coordinates.
	init_t_buffer = 31;
	end_buffer	  = 10;
	time_window   = 15;
	filt_span	  = 5;
	n_prey		  = size(preys_pos, 2 );
	for iPrey = 1 : n_prey		
		%% Part 1. Vector generation
		% Generate vector between prey and player
		vector.raw{iPrey } = [ subj_pos( :, 1 ) - preys_pos{ iPrey }( :, 1 ), ...
			subj_pos( :, 2 ) - preys_pos{ iPrey }( :, 2 ) ];	% Distance and direction of the vector.
		
		%% Part 2. Calculate the magnitude of the vectors
		%   This supposed to detect the distance.
		vector.mag( :, iPrey ) = sqrt( sum( ( vector.raw{ iPrey } ).^2, 2 ) );
		l_sld_data = t_len - time_window; % It ends time t before ending point
		for iSld = 1 : l_sld_data
			vector.sld_mag( iSld, iPrey ) = nanmean( vector.mag( iSld: iSld + time_window, iPrey ) );
		end
		
		%% Part 3. Calculate the angle of the vectors
		%   Angle in radian value
		[ angle.chase(:, iPrey) , angle.sld(:, iPrey) ] = compute_angle_glm( subj_pos, preys_pos{ iPrey }, t_len-1, time_window );
		angle.abs_sld(:, iPrey) = abs( angle.sld(:, iPrey) ) ;
		
		%% Part 4. Path similarity metric
		for iSld = 1 : l_sld_data
			stats.dtw_res(iSld, iPrey) = dtw( subj_pos( iSld: iSld + time_window, : ), preys_pos{ iPrey }( iSld: iSld + time_window, : ) );
		end
		
		%% Part 4. Path similarity metric	
		if iPrey == n_prey
			[ comp.dist, comp.ang, comp.dtw ]  = detect_pursuit_glm( vector.sld_mag, angle.abs_sld, stats.dtw_res );
			
			% Arbitrary proportion between dtw_res and distance
			pursuit	 = ( comp.dist.* comp.ang  );
			for iLen = 1 : n_prey
				pursuit( :, iLen ) = smooth( pursuit( :, iLen ), filt_span*2, 'lowess' );
			end
			pursuit = pursuit+1;
			diff_pursuit = diff( pursuit, [], 2 );			
			distinct	 = find( pursuit(:, 1) ~= pursuit(:, 2 ) );
			
			% Detect the flip of the sign.
			sign_pursuit		= sign( diff_pursuit(distinct) );
			[~, pursuit_idx]	= min( pursuit(distinct, :), [], 2 );
			
			% Find particular decision switch
			switched = numel( unique( sign_pursuit(init_t_buffer:end-end_buffer) ) );
			
			if switched > 1 ||isempty(pursuit_idx) % for Kirk, there are cases where there are 3 NPCs on screen
				pursuit_idx = nan;
            else
				pursuit_idx = pursuit_idx(end);
			end
		end
	end
end