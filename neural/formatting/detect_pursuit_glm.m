function [ dist, ang, dtws ] = detect_pursuit_glm( vector, angle, dtw_res )

	% Compare distance and angle
	%	If the distance is smaller, give 1 and vice versa.
	%	If the angle is smaller, give vice versa.

	dist1 = vector( 1 : end - 1, 1 );
	dist2 = vector( 1 : end - 1, 2 );

	ang1 = angle( :, 1 );
	ang2 = angle( :, 2 );

    dtw1 = dtw_res( 1 : end - 1, 1 );
	dtw2 = dtw_res( 1 : end - 1, 2 );
    
	subt_dist	= dist1 - dist2;
	subt_ang	= ang1 - ang2;
    subt_dtw    = dtw1 - dtw2;
    
	dist( :, 1 )	= subt_dist < 0;
	dist( :, 2	)	= ~dist( :, 1 );

	ang( :, 1 )	= subt_ang < 0;
	ang( :, 2 )	= ~ang( :, 1 );
    
    dtws( :, 1 )	= subt_dtw < 0;
    dtws( :, 2 )	= ~dtws( :, 1 );
end