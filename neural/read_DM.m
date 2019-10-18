fs = fieldnames(DM);
for i = 1:length(fs)
    eval([fs{i} '= DM.' fs{i} ';']); % opposite approach if data loaded directly
end
concatpsth = spiketrain;

%%% Self
% compute speed matrix
self_spd_grid = map_1d(self_vel,n_speed_bins);
% self_dir_grid = map_1d(self_dir,n_dir_bins);
self_dir_grid = map_1d_by_edge(self_dir,linspace(0,2*pi,n_dir_bins+1));
% compute position matrix
self_pos_grid = map_2d([self_posx,self_posy],[n_pos_bins,n_pos_bins]);

%%% Prey
prey_spd_grid = map_1d(prey_vel,n_speed_bins);
prey_dir_grid = map_1d_by_edge(prey_dir,linspace(0,2*pi,n_dir_bins+1));
prey_pos_grid = map_2d([prey_posx,prey_posy],[n_pos_bins,n_pos_bins]);
dist_grid	  = map_1d(dist_fromPrey,n_dist_bins);
angle_grid	  = map_1d_by_edge(angle_toPrey,linspace(0,2*pi,n_angle_bins+1));

%%% Predator
pred_spd_grid = map_1d(pred_vel,n_speed_bins);
pred_dir_grid = map_1d_by_edge(pred_dir,linspace(0,2*pi,n_dir_bins+1));
pred_pos_grid = map_2d([pred_posx,pred_posy],[n_pos_bins,n_pos_bins]);
pred_dist_grid = map_1d(dist_fromPred,n_dist_bins);
pred_angle_grid = map_1d_by_edge(angle_toPred,linspace(0,2*pi,n_angle_bins+1));

DM.spiketrain = concatpsth;

numParams = [n_pos_bins.^2,n_dir_bins,n_speed_bins,...
    n_pos_bins.^2,n_dir_bins,n_speed_bins,...
    n_pos_bins.^2,n_dir_bins,n_speed_bins,...
    n_dist_bins,n_angle_bins, n_dist_bins,n_angle_bins]; % this is used in the model code for parsing input parameters into correct sizes
% what each of the parameter mean for human understanding
vars_explained = {'Pos','Dir','Vel','PreyPos','PreyDir','PreyVel','PredPos','PredDir','PredVel','Dist','Angle','PredDist','PredAngle'};

% type of parameter, determine what the regularization calculation is
% this tells which regularization to use, 2d = position, 1dcirc = angle
typeParams = {'2d','1dcirc','1d','2d','1dcirc','1d','2d','1dcirc','1d','1d','1dcirc', '1d','1dcirc'};
    
reg_weights= repmat( 1e1, numel(vars_explained), 1);
