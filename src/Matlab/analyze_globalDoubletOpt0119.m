%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Analyze Global Doublet Optimization 01-19-2016
%
% Now analyzing data from 01-21-2016 because this data is better (see
% notebook notes on why)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
path = '../../data/';
filename_nocorr = 'doublet_global_0121.mat';
    % Good contents:
    % camera_array_nocorr (50x5 struct)
    % rmse_array_nocorr (50x1 double)
    % init_ind_nocorr (50x6 double)
    %
    % Bad contents:
    % camera_array_corr (50x5 struct)
    % rmse_array_corr (50x1 double)
    % init_ind_corr (50x6 double)    

filename_corr = 'doublet_global_corr_0121.mat';
    % camera_array_corr (50x5 struct)
    % rmse_array_corr (50x1 double)
    % init_ind_corr (50x6 double)
    
%%
% Load no correction designs
load([path filename_nocorr]);
load([path filename_corr]);
[sorted_rmse_corr, sort_ind_corr] = sort(rmse_array_corr, 'ascend');
[sorted_rmse_nocorr, sort_ind_nocorr] = sort(rmse_array_nocorr, 'ascend');


%% Plot RMSE

figure;
plot(sorted_rmse_corr, 'ro-'); 
hold on
plot(sorted_rmse_nocorr, 'bo-');legend('corr', 'no corr'); hold off
grid on
ylabel('RMS spot size (mm)');
title('Spot Size with and without 4D correction')


%% Plot RMSE vs initial design number
figure; subplot(2,1,1)
plot(rmse_array_nocorr, 'bo-');
ylabel('RMSE spot size (mm)');
xlabel('Inital design ranking');
title('No corr')
grid on;
subplot(2,1,2)
plot(rmse_array_corr, 'ro-');
ylabel('RMSE spot size (mm)');
xlabel('Inital design ranking');
title('Corr')
grid on;


%% Plot Designs - no corr

figure;
for i = 1:16
    h = subplot(4,4,i);
    viz_camera(camera_array_nocorr(sort_ind_nocorr(i), :), h);
    xlim([1500 1570]);
    title([num2str(sorted_rmse_nocorr(i)*1000) ' um' ]);
end
set(gcf, 'position', [p(1) p(2) 800 700])
%% Plot Designs - corr

figure;
for i = 1:16
    h = subplot(4,4,i);
    viz_camera(camera_array_corr(sort_ind_corr(i), :), h);
    xlim([1500 1570]);
    title([num2str(sorted_rmse_corr(i)*1000) ' um' ]);
end
set(gcf, 'position', [p(1) p(2) 800 700])
%%



