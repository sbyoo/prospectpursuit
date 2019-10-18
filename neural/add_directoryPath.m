function add_directoryPath( )

	%% Get the name of current directory
	cur_path = fileparts( which( mfilename ) );
	
	%% Add the function directory to the path	
	%	Note) If there is any sub-directory to add, put them below
	addpath( fullfile( cur_path, 'util_function' ) );
	addpath( genpath( [ cur_path, '/util_function'] ) );
	
end