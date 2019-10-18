%% Description of main function.

% This script runs model in a bottom-up way exhaustively and can be
% modified to top-down way of search. 
% 1. fit all single models exhaustively.
% 2. determine the best and add one var.
% 3. continue until llkd does not increase with adding more variables

% The shuffle is intended to find false positive rate on your data for sanity check. 

% Input data example in our repo is design matrix format. 
% Later it is transformed into one hot encoding style input. That one hot
% is determined by bin size (for Yoo et al., 2019, we used 15 for each
% monitor dimension, 12 for direction and angle). 

% Details are described in Yoo et al., 2019 and original inspiration is
% from Hardcastle et al. 2017, Neuron. 


clear; clc
warning('off', 'all');

paths.exc_path = fileparts(which(mfilename)); cd(paths.exc_path);
add_directoryPath();

%% make directory
if ~exist('./Results','dir')
    mkdir('./Results')
end

%% parameters %Change Me % 
SampleRate  = 60;	% Hz, Data-determined, please don't change for this data
numWorkers  = 6;	% maximum number of workers 0 = not parallel
numFolds    = 10;	% cross-validation folds
p_threshold = 0.05; % p-value threshold for signrank tests
nboot		= 1;	% number of bootstrap samples, if = 1 means no bootstrap

%% load the data
% Data is in ./Data folder and contains the behavior variables and 
fprintf('(1/5) Loading data from example session \n')
DataDir = './Data';
date = '171209';
cd(fileparts(mfilename('fullpath')));
FileName = dir(fullfile(DataDir,['*',date,'*']));FileName =fullfile(FileName(1).folder,FileName(1).name);
load(FileName)
[modelType,numModels] = obtain_modelType(numParams);
n_var = numel(numParams);


%% Paralellel Setting
if numWorkers~=0 && isempty(gcp('nocreate'))
    parpool('local',numWorkers);
end

%% Add shuffle to test the false positive rates.
%	The easiest way is the permute the spike rates.
%	The shape of spike train is 'n_data_pts x n_neurons'
orig_DM		= DM;
shuffle_on	= true;
if shuffle_on
	init_idx  = 1;
	n_shuffle = 100;
	for iShf = init_idx : n_shuffle+init_idx
		[d_pts, n_neuron] = size(orig_DM.spiketrain);
		for iN = 1 : n_neuron
			idx = datasample(1:d_pts, d_pts, 'replace', true);
			DM.spiketrain(:, iN) = orig_DM.spiketrain(idx, iN);
		end
		read_DM;
		
		%% fit model
		fit_ln;
		
		%% Preparation for saving
		saveName = sprintf('%s_shuffle_run%03d.mat',date,iShf);
		timestamp = datetime('now');
		save(fullfile('./Results',saveName),'GLM_out','all_selected_model', 'modelType','timestamp');
	end
else
	%% fit model
	fit_ln;
	
	%% Preparation for saving
	i = 1;
	saveName = sprintf('%s_shuffle_run%03d.mat', date,i);
	while exist(fullfile('./Results',saveName),'file')~=0
		i = i+1;
		saveName = sprintf('%s_shuffle_run%03d.mat',date,i);
	end
	timestamp = datetime('now');
	save(fullfile('./Results',saveName),'GLM_out','all_selected_model', 'modelType','timestamp');
end