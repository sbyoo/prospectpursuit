function [grid,vect,N] = map_1d_by_edge(var_1d,edges)

	[N,~,bin] = histcounts(var_1d,edges);

	grid = dummyvar(bin);

	if max(unique(bin))<length(edges)-1 % if the last bin is empty
		warning('Last bin is empty, consider reduce the number of bins\n');
		grid = [grid, zeros(size(grid,1),1)]; % add zeros to last col
	end

	vect = mean([edges(1:end-1);edges(2:end)]); % center of bins

end