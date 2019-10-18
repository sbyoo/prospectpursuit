function [tuning_curve,ste_tuning,vect] = compute_1d_tuning_curve_by_edge(variable,fr,edges)

%bin it
var_vec = edges;
numBin = length(edges)-1;

tuning_curve = nan(numBin,1);
ste_tuning = nan(numBin,1);

% compute mean fr for each bin
for n = 1:numBin
    tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable < var_vec(n+1)));
    ste_tuning(n) = ste(fr(variable >= var_vec(n) & variable < var_vec(n+1)));
    
    if n == numBin
        tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable <= var_vec(n+1)));
        ste_tuning(n) = ste(fr(variable >= var_vec(n) & variable <= var_vec(n+1)));
    end
      
end

vect = .5*(edges(2:end)+edges(1:end-1)); % center of bins

return