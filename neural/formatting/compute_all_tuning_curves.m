%% Description
% This will compute the firing rate tuning curves for position, head
% direction, running speed, and theta phase.

% take out times when the animal ran >= 50 cm/s
% posx_c(too_fast) = []; posy_c(too_fast) = []; 
% direction(too_fast) = [];
% speed(too_fast) = [];
% phase(too_fast) = [];

boxends = [1920 1080]; % screen resolution

% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(posx,posy,smooth_fr,n_pos_bins,[0 0],boxends);
[dir_curve] = compute_1d_tuning_curve(dir,smooth_fr,n_dir_bins,0,2*pi);
[speed_curve] = compute_1d_tuning_curve(vel,smooth_fr,n_speed_bins,min(subj_vel),max(subj_vel));

NPC_curve = NaN(1,size(NPC_grid,2));
for i = 1:size(NPC_grid,2)
    NPC_curve(i) = smooth_fr'*NPC_grid(:,i)/sum(NPC_grid(:,i));
end