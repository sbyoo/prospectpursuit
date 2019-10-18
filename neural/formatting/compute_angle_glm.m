function [ angleout, sld_angle ] = compute_angle_glm( subj_data, prey_data, len_data, time_window )

	% Condition 1. Distance is getting closer
	% Condition 2. Form vector of player( t -1 ) and player( t ). 
	%			   In addition, form vector of player( t - 1) and prey( t - 1 ).
	%			   Then, calculate angle between those vectors.

	% Vector formation
	%	1 ) player( t ) and player( t - 1 ).
	vect_temp_player = subj_data( 2: end, : ) - subj_data( 1 : end - 1, : );

	% Making it to unit vector
	vMag_temp_player = sqrt( sum( vect_temp_player.^2 , 2 ) );
	vMag_temp_player = repmat( vMag_temp_player, 1, 2 );
	vect_temp_player = vect_temp_player./ vMag_temp_player;

	%	2 ) player( t - 1 ) and prey( t - 1 )
    vect_player_prey = prey_data( 1 : end - 1, : ) - subj_data( 1 : end - 1, : );
    
    % Making it to unit vector
    vMag_temp_prey		= sqrt( sum( vect_player_prey.^2 , 2 ) );
    vMag_temp_prey		= repmat( vMag_temp_prey, 1, 2 );
    vect_player_prey	= vect_player_prey./vMag_temp_prey;
	
    %	3 ) Angle calutation
    angle = zeros( len_data, 1 );
    for iData = 1 : len_data
        vect1 = vect_temp_player( iData, : );
        vect2 = vect_player_prey( iData, : );
        angle( iData, 1 ) = mod( atan2(vect1(1)*vect2(2)-vect2(1)*vect1(2),vect1(1)*vect2(1)+vect1(2)*vect2(2)), 2*pi );
    end
	angleout = rad2deg( angle );
	angleout = wrapTo180( angleout );
	
	%	4 ) Sliding window
	len_slided_data = len_data - time_window;
	sld_angle = zeros( len_slided_data, 1 );
    for iSld = 1 : len_slided_data
        sld_angle( iSld, 1 ) = nanmean( angleout( iSld: iSld + time_window, 1 ));
    end
end