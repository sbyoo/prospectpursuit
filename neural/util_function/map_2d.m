function [grid, N_2d] = map_2d(var_2d,n_bins)

	% 2D variables are included ( observartion x n matrix).
	% Edges are separated by the row.
	[N_2d,edges_2d(1, :), edges_2d(2, :), bin(:, 1), bin(:, 2)]...
		= histcounts2(var_2d(:, 1),var_2d(:, 2),n_bins(1));
	
	n_sq_bins = n_bins(1).^2;
	twoD_bins = sub2ind(n_bins, bin(:, 1), bin(:, 2));
	l_uq = max(unique(twoD_bins));
	
	if l_uq < (n_bins(1)^2)
		n_miss = (n_bins(1)^2)-l_uq;
		for iM = 1 : n_miss
			twoD_bins = [twoD_bins; n_sq_bins-iM+1];
		end
	end
	grid = dummyvar(twoD_bins);
	
	% Small tweak to manage artifically added bins
	if length(bin) ~= length(twoD_bins)
		delta_bin = length(twoD_bins)-length(bin);
		grid(end-delta_bin+1:end, :) = []; % Final stage: removed inserted empty bin data from whole.
	end
	
end