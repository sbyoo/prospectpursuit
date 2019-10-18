function [testFit,trainFit,param_mean] = fit_model(A,dt,spiketrain,filter,modelType,numFolds,typeParams,reg_weights,numParams)
%% Description
% This code will section the data into 10 different portions. Each portion
% is drawn from across the entire recording session. It will then
% fit the model to 9 sections, and test the model performance on the
% remaining section. This procedure will be repeated 10 times, with all
% possible unique testing sections. The fraction of variance explained, the
% mean-squared error, the log-likelihood increase, and the mean square
% error will be computed for each test data set. In addition, the learned
% parameters will be recorded for each section.


%% Initialize matrices and section the data for k-fold cross-validation

[~,numCol] = size(A);

% initialize matrices
testFit = nan(numFolds,9); % model performance
trainFit = nan(numFolds,9); % model performance
paramMat = nan(numFolds,numCol);

rng('default') % for reproducibility
cv = cvpartition(spiketrain,'KFold',numFolds); % make cross-validation data subsets % make sure the test spike number are similar
%% perform k-fold cross validation
for k = 1 :numFolds
    test_ind  = find(test(cv,k)); % get test indices
    smooth_fr = (conv(spiketrain,filter,'same'))./dt;
    test_spikes = spiketrain(test_ind); %test spiking
    smooth_fr_test = smooth_fr(test_ind);
    test_A = A(test_ind,:);
    
    % training data
    train_ind = setdiff(1:numel(spiketrain),test_ind);
    train_spikes = spiketrain(train_ind);
    smooth_fr_train = smooth_fr(train_ind);   
    train_A = A(train_ind,:);
    
    opts = optimset('Gradobj','on','Hessian','on','Display','off','Algorithm','trust-region');
    
    data{1} = train_A; data{2} = train_spikes;
    if k == 1
        init_param = 1e-3*randn(numCol, 1);
    else
        init_param = param;
    end
    
    % Optimization Equation
    [param] = fminunc(@(param) ln_poisson_model(param,data,modelType,typeParams,reg_weights,numParams),init_param,opts);
    
    %%%%%%%%%%%%% TEST DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    fr_hat_test = exp(test_A * param)/dt;
    smooth_fr_hat_test = fr_hat_test; % 20181003
    %     smooth_fr_hat_test = conv(fr_hat_test,filter,'same'); %returns vector same size as original
        
    % compute llh increase from "mean firing rate model" - NO SMOOTHING
    r = exp(test_A * param); n = test_spikes; meanFR_test = nanmean(test_spikes);
    
    log_llh_test_model = nansum(r-n.*log(r)+log(factorial(n)))/sum(n); % why is there sum(n)??
    %note: log(gamma(n+1)) will be unstable if n is large (which it isn't here)
    log_llh_test_null = nansum(meanFR_test-n.*log(meanFR_test)+log(factorial(n)))/sum(n);

    log_llh_increase_test = (-log_llh_test_model + log_llh_test_null);
    log_llh_increase_test = log(2)*log_llh_increase_test;
    
    null_deviance = 2*(-log_llh_test_null);
    model_deviance = 2*(-log_llh_test_model);
    dev_ratio = 1-model_deviance/null_deviance;
    
    % compare between test fr and model fr
    sse = sum((smooth_fr_hat_test-smooth_fr_test).^2);
    sst = sum((smooth_fr_test-mean(smooth_fr_test)).^2);
    varExplain_test = 1-(sse/sst);
    
    % compute correlation
    correlation_test = corr(smooth_fr_test,smooth_fr_hat_test,'type','Pearson');

    % compute MSE
    mse_test = nanmean((smooth_fr_hat_test-smooth_fr_test).^2);
    
    % compute AIC,BIC
    totalnumParam = size(A,2);
    totalnumObs = size(A,1);
    [aic,bic] = aicbic(log_llh_test_model,totalnumParam,totalnumObs);
    % fill in all the relevant values for the test fit cases
    testFit(k,:) = [varExplain_test correlation_test log_llh_increase_test mse_test sum(n) numel(test_ind) aic bic dev_ratio];
    
    
    %%%%%%%%%%%%% TRAINING DATA %%%%%%%%%%%%%%%%%%%%%%%
    % compute the firing rate
    fr_hat_train = exp(train_A * param)/dt;
    smooth_fr_hat_train = fr_hat_train; 
    
    % compute log-likelihood
    r_train = exp(train_A * param); n_train = train_spikes; meanFR_train = nanmean(train_spikes);
    log_llh_train_model = nansum(r_train-n_train.*log(r_train)+log(factorial(n_train)))/sum(n_train); % llh per spike
    log_llh_train_null = nansum(meanFR_train-n_train.*log(meanFR_train)+log(factorial(n_train)))/sum(n_train); % llh per spike
    log_llh_increase_train = (-log_llh_train_model + log_llh_train_null);
    log_llh_increase_train = log(2)*log_llh_increase_train;
    
    null_deviance = 2*(-log_llh_train_null);
    model_deviance = 2*(-log_llh_train_model);
    dev_ratio = 1-model_deviance/null_deviance;
    
     % compare between test fr and model fr
    sse = sum((smooth_fr_hat_train-smooth_fr_train).^2);
    sst = sum((smooth_fr_train-mean(smooth_fr_train)).^2);
    
    varExplain_train = 1-(sse/sst);
    
    % compute correlation
    correlation_train = corr(smooth_fr_train,smooth_fr_hat_train,'type','Pearson');
    
    % compute MSE
    mse_train = nanmean((smooth_fr_hat_train-smooth_fr_train).^2);
    [aic,bic] = aicbic(log_llh_train_model,totalnumParam,totalnumObs);
    trainFit(k,:) = [varExplain_train correlation_train log_llh_increase_train mse_train sum(n_train) numel(train_ind) aic bic, dev_ratio];
    
    % save the parameters
    paramMat(k,:) = param;
    
    
end

param_mean = nanmean(paramMat);

return
