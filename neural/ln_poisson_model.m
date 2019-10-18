function [f, df, hessian] = ln_poisson_model(param,data,modelType,typeParams,reg_weights,numParams)

% global numParams
X = data{1}; % subset of A
Y = data{2}; % number of spikes
n_var = length(numParams); % total number of variables

% compute the firing rate
u = X * param;
rate = exp(u);

% roughness regularizer weight - note: these are tuned using the sum of f,
% and thus have decreasing influence with increasing amounts of data
b = reg_weights;

% start computing the Hessian
rX = bsxfun(@times,rate,X);       
hessian_glm = rX'*X;

%% find the parameters and compute their roughness penalties

% initialize parameter-relevant variables
J = zeros(n_var,1);
J_g = cell(n_var,1);
J_h = cell(n_var,1);

% parse the parameters
[allparams] = find_param(param,modelType,numParams);% global variable from before

% compute the contribution for f, df, and the hessian
for i = 1:length(allparams)
    if ~isempty(allparams{i})
        switch typeParams{i}
            case '2d'
                [J(i),J_g{i},J_h{i}] = rough_penalty_2d(allparams{i},b(i)); 
            case '1d'
                [J(i),J_g{i},J_h{i}] = rough_penalty_1d(allparams{i},b(i));
            case '1dcirc'
                [J(i),J_g{i},J_h{i}] = rough_penalty_1d_circ(allparams{i},b(i));
            case '0d'
                [~,J_g{i},J_h{i}] = rough_penalty_1d_circ(allparams{i},0);
                J(i) =  b(i).*sum(abs(allparams{i}));
        end
    end
end

%% compute f, the gradient, and the hessian 
f = sum(rate-Y.*u) + sum(J);
df = real(X' * (rate - Y) + vertcat(J_g{:}));
hessian = hessian_glm + blkdiag(J_h{:});

% f = sum(rate-Y.*u) + J_pos + J_hd + J_spd+J_NPC;
% df = real(X' * (rate - Y) + [J_pos_g; J_hd_g; J_spd_g; J_NPC_g]);
% hessian = hessian_glm + blkdiag(J_pos_h,J_hd_h,J_spd_h,J_NPC_h);

%% smoothing functions called in the above script
function [J,J_g,J_h] = rough_penalty_2d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(sqrt(numParam),1)*[-1 1],0:1,sqrt(numParam)-1,sqrt(numParam));
    DD1 = D1'*D1;
    M1 = kron(eye(sqrt(numParam)),DD1); M2 = kron(DD1,eye(sqrt(numParam)));
    M = (M1 + M2);
    DD1 = D1'*D1;
    
    J = beta*0.5*param'*M*param;
    J_g = beta*M*param;
    J_h = beta*M;

function [J,J_g,J_h] = rough_penalty_1d_circ(param,beta)
    
    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    
    % to correct the smoothing across first and last bin
    DD1(1,:) = circshift(DD1(2,:),[0 -1]);
    DD1(end,:) = circshift(DD1(end-1,:),[0 1]);
    
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;

function [J,J_g,J_h] = rough_penalty_1d(param,beta)

    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    J = beta*0.5*param'*DD1*param;
    J_g = beta*DD1*param;
    J_h = beta*DD1;
   
%% function to find the right parameters given the model type
function [allparams] = find_param(param,modelType,numParams)

assert(length(numParams)== size(modelType,2)); % make sure the length matches

numParams(modelType==0) = 0; % only include the parameters which are in the model
end_idx = cumsum(numParams);

allparams = cell(length(numParams),1);
allparams{1} = param(1:end_idx(1));
for jj = 2:length(numParams)
allparams{jj} = param(end_idx(jj-1)+1:end_idx(jj));
end

