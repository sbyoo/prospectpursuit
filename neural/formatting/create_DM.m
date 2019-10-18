% state the number of bins to use for recorded variables
%%% Self
DM.self_vel = subj_vel;
DM.self_dir = subj_dir;
DM.self_posx = subj_posx;
DM.self_posy = subj_posy;

%%% Prey
DM.prey_vel = prey_vel;
DM.prey_dir = prey_dir;
DM.prey_posx = prey_posx;
DM.prey_posy = prey_posy;

%%% Pred
DM.pred_vel = pred_vel;
DM.pred_dir = pred_dir;
DM.pred_posx = pred_posx;
DM.pred_posy = pred_posy;

DM.dist_fromPrey = dist_fromPrey;
DM.angle_toPrey  = angle_toPrey;
DM.dist_fromPred = dist_fromPred;
DM.angle_toPred  = angle_toPred;

DM.spiketrain = concat_psth;

DM.n_dir_bins	= 12;
DM.n_speed_bins = 12;
DM.n_pos_bins	= 15;
DM.n_dist_bins	= 12;
DM.n_angle_bins = 12;