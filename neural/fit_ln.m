all_selected_model = NaN(n_neuron,1); % matrix to save the best model
GLM_out = repmat(struct('trainFit',[],'testFit',[],'param',[]),n_neuron,nboot); % structure to save the fitting results

num_var_in_model = 0;
parfor (iN = 1:n_neuron, numWorkers)
	% for iN = 1 : n_neuron
	%% Prepare design matrix (Highly flexible part, can add in more stuff here)
	fprintf('Now Fitting For Neuron %i...\n',iN); % print out current Neuron
	for iboot = 1:nboot
		grids = {self_pos_grid,self_dir_grid,self_spd_grid,...
			prey_pos_grid,prey_dir_grid,prey_spd_grid,...
			pred_pos_grid,pred_dir_grid,pred_spd_grid,...
			dist_grid,angle_grid,pred_dist_grid,pred_angle_grid};
		
		% make a bootstrapped sample
		if nboot>1
			rng(iboot,'twister');
			maxSample = length(grids{1});
			sample_idx = datasample(1:maxSample, maxSample, 'replace', 'true');
			grids = cellfun(@(thiscell)thiscell(sample_idx,:),grids,'UniformOutput',false);
			spiketrain = concatpsth(sample_idx, iN); % spike
		else
			spiketrain = concatpsth(:,iN); % spike
		end
		
		assert(all(n_var==... % check for same length of inputs
			[length(vars_explained),length(typeParams),length(reg_weights),length(grids)]));
		
		testFit		= cell(numModels,1);
		trainFit	= cell(numModels,1);
		param		= cell(numModels,1);
		selected_model = NaN;
		
		% [Firing rate smoothing] compute a filter, which will be used to smooth the firing rate
		filter = gaussmf(-4:4,[2 0]); filter = filter/sum(filter);
		fr = spiketrain*SampleRate;
		smooth_fr = conv(fr,filter,'same'); % for plotting
		
		%% Start fitting all
		fprintf('(2/5) Fitting all linear-nonlinear (LN) models\n')
		num_var_in_model    = 1;
		stopflag  = false;
		while  num_var_in_model <= n_var % && continueflag % stepwise fitting for progressively complex models
			modelIdx = find(sum(modelType,2)==num_var_in_model); % models with n variables
			if num_var_in_model>1
				temp = find(all(modelType(:,find(modelType(selected_model,:)))==1,2)); % models containing the last selected model
				modelIdx = intersect(modelIdx,temp);
			end
			
			for i = 1:length(modelIdx)
				n = modelIdx(i); % which model
				A = horzcat(grids{modelType(n,:)==1}); % input design matrix
				fprintf('\t- Fitting model %d of %d\n', n, numModels);
				[testFit{n},trainFit{n},param{n}] = fit_model(A,1/SampleRate,spiketrain,filter,modelType(n,:),numFolds,typeParams,reg_weights,numParams);
			end
			
			%% find the simplest model that best describes the spike train
			testFit_mat = cell2mat(testFit);
			modelsToCompare = find(arrayfun(@(i)~isempty(testFit{i}),1:length(testFit)));
			LLH_values = reshape(testFit_mat(:,3),numFolds,[]); % 3rd col is LLH
			[~,top] = max(nanmean(LLH_values));
			
			if ~stopflag % when fitting the final full model because stop criteria reached reached don't select again
				if num_var_in_model == 1
					selected_model = modelsToCompare(top);
				elseif signrank(LLH_values(:,top),testFit{selected_model}(:,3),'tail','right')>= p_threshold
					stopflag = true;
					if num_var_in_model< n_var % go directly to fit full model
						num_var_in_model = n_var-1;
					end
					% stop fitting if the more complex model does not significantly improves performance
					% and continue to fit full model % update 20180814
				elseif signrank(LLH_values(:,top),testFit{selected_model}(:,3),'tail','right')< p_threshold
					selected_model = modelsToCompare(top);
				end
			end
			num_var_in_model = num_var_in_model+1; % progressively add more parameters based on the first result
		end
		
		% re-set if selected model is not above baseline
		pval_baseline = signrank(testFit{selected_model}(:,3),[],'tail','right');
		if pval_baseline >= p_threshold
			selected_model = NaN;
		end
		fprintf('(3/5) Performing forward model selection\n')
		if isnan(selected_model)
			fprintf('Ooops... no model was selected.');
		else
			fprintf('Selected Model = ');disp(vars_explained(modelType(selected_model,:)==1))
		end
		all_selected_model(iN) = selected_model; % what is the best model for this neuron
		
		GLM_out(iN,iboot).trainFit = trainFit;
		GLM_out(iN,iboot).testFit = testFit;
		GLM_out(iN,iboot).param = param;
	end
end