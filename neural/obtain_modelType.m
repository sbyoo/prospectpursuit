function [modelType,numModels] = obtain_modelType(numParams)
n_var = length(numParams);
n_model_idx = cumsum([diag(fliplr(pascal(n_var+1)))]); % for each number of variables (from most to least, the number of models)
numModels	= trace(fliplr(pascal(n_var+1)))-1; % all combinations given the number of variables to consider
modelType	= NaN(numModels,n_var);

for j = 1:n_var
    M = findcombinations(n_var, j); % nested function to find all combinations nCk
    modelType(n_model_idx(j):n_model_idx(j+1)-1,:) = M;
end

modelType(modelType(:,numParams == 0)==1,:) = [] ; % deal with cases where some of the variables are not existing
numModels = size(modelType,1);

%% function to return the combinations in index form
% n = 6; k = 6;
% M = [1 1 1 1 1 1];
    function M = findcombinations(n,k)
        
        C = combnk(1:n,k);
        M = zeros(size(C,1),n);
        for i = 1:size(C,1)
            M(i,C(i,:)) = 1;
        end
        
    end
end