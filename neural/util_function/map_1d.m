function [grid,vect,N] = map_1d(var_1d, nbins)

	% Map the 1-dimensional variables. 
	[N,edges_1d,bin] = histcounts(var_1d, nbins);

	% Making into dummyvariable with more smart way.
	if max(unique(bin))<nbins % if the last bin is empty
		empty_bin	= find(N == 0)';
		n_empty		= length(empty_bin);

		bin = [bin; empty_bin]; % Fill in arbitrary bins so that it won't be omitted.
		
		fprintf('%4.2d bins are empty	\n', n_empty)
		fprintf( 'consider reduce the number of bins\n');
	end
	grid = dummyvar(bin);
	
	if exist('n_empty', 'var' )
		grid(end-n_empty, :) = []; % Final stage: removed inserted empty bin data from whole.
	end
	vect = mean([edges_1d(1:end-1);edges_1d(2:end)]); % center of bins
end