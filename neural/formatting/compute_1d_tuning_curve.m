function [tuning_curve,ste_tuning,vect] = compute_1d_tuning_curve(variable,fr,numBin,minVal,maxVal)

%bin it
var_vec = linspace(minVal,maxVal,numBin+1);

tuning_curve = nan(numBin,1);
ste_tuning = nan(numBin,1);

% compute mean fr for each bin
for n = 1:numBin
    tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable < var_vec(n+1)));
    ste_tuning(n)	= ste(fr(variable >= var_vec(n) & variable < var_vec(n+1)));
    
    if n == numBin
        tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable <= var_vec(n+1)));
        ste_tuning(n) = ste(fr(variable >= var_vec(n) & variable <= var_vec(n+1)));
    end
      
end

vect = mean([var_vec(1:end-1);var_vec(2:end)]); % center of bins


return