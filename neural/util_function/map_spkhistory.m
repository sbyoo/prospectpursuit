function iN_hist_map = map_spkhistory(psth,ext_psth,k,offset)
    
	st_idx = 2; % starting from either the first timepoint or the second timepoint
	% this is to match the behaviour vector length because Michael wanted to
	% exclude the first behaviour recording frame for there were no velocity/direction (THANK YOU!).
	shift_bins = 31; %+1; % ext_psth{1}(:,t+31)= psth{1}(:,t); % this is determined by using 0.5s extended ITI
	n_hist_bins = k; % I want k = 10 bins history (t-10):(t-1)

	n_neuron = size(psth{1},1);
	n_trial  = length(psth);
	iN_hist_map = cell(n_trial,n_neuron);

	for iTr = 1:length(psth)
		if offset~=0
			all_indices		= 1:size(psth{iTr},2); % Note) Change according to variable names
			left_shift		= all_indices(1+abs(offset):end);
			right_shift		= all_indices(1:end-abs(offset));
			all_ext_indices = 1:size(ext_psth{iTr},2);
			left_ext_shift		= all_ext_indices(1+abs(offset):end);
			right_ext_shift		= all_ext_indices(1:end-abs(offset));
			if offset < 0
				psth{iTr} = psth{iTr}(:,left_shift);
				ext_psth{iTr} = ext_psth{iTr}(:,left_ext_shift);
			elseif offset>0
				psth{iTr} = psth{iTr}(:,right_shift);
				ext_psth{iTr} = ext_psth{iTr}(:,right_ext_shift);
			end
		end
		org_len = size(psth{iTr},2);
		hist_map = NaN(org_len-st_idx+1,n_hist_bins);
		
		for iN = 1:n_neuron
			for t = st_idx:org_len
				hist_map(t-st_idx+1,1:n_hist_bins) = ext_psth{iTr}(iN,[(t-n_hist_bins):(t-1)]+shift_bins);
			end
			
			% Temporary fix (exclude the last bin)
			iN_hist_map{iTr,iN} = hist_map(1:end, : );
		end
	end
end