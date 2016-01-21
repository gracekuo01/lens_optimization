function [ ] = analyze_globalDoubletOpt0119( )
%
% Analyze Global Doublet Optimization 01-19-2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
path = '../../data/';
filename_corr = 'doublet_global_corr_0119.mat';
filename_nocorr = 'doublet_global_nocorr_0120.mat';

% Load correction designs
load([path filename_corr]);
camera_designs_corr = camera_array;
rmse_corr = rmse_array;
[sorted_rmse_corr, sort_ind_corr] = sort(rmse_array, 'ascend');

% Load no correction designs
load([path filename_nocorr]);
camera_designs_nocorr = camera_array;
rmse_nocorr = rmse_array;
[sorted_rmse_nocorr, sort_ind_nocorr] = sort(rmse_array, 'ascend');
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure; subplot(2,2,1);
plot(sorted_rmse_corr, 'r');
subplot(2,2,3);
plot(sorted_rmse_nocorr, 'b');


for i = 1:25-1
    [ dist_t_corr(i), dist_c_corr(i), dist_d_corr(i) ] = calcDistBetweenCameras (...
        camera_designs_corr(sort_ind_corr(i), :), camera_designs_corr(sort_ind_corr(i+1), :));
    [ dist_t_nocorr(i), dist_c_nocorr(i), dist_d_nocorr(i) ] = calcDistBetweenCameras (...
        camera_designs_nocorr(sort_ind_nocorr(i), :), camera_designs_nocorr(sort_ind_nocorr(i+1), :));
end

subplot(2,2,2); n = 1.5:24.5;
plot(n, dist_c_corr, 'r', n, dist_c_nocorr, 'b');
subplot(2,2,4);
plot(n, dist_d_corr, 'r', n, dist_d_nocorr, 'b');
%%
figure;
for i = 1:25
    h = subplot(5,5,i);
    viz_camera(camera_designs_nocorr(sort_ind_nocorr(i), :), h);
    xlim([1500 1570]);
    title([num2str(sorted_rmse_nocorr(i)*1000) ' um' ]);
end
%%
figure;
for i = 1:25
    h = subplot(5,5,i);
    viz_camera(camera_designs_corr(sort_ind_corr(i), :), h);
    xlim([1500 1570]);
    title([num2str(sorted_rmse_corr(i)*1000) ' um' ]);
end
%%


end

function [ x ] = extractVars ( camera )
x(1) = 1/camera(2).R;
x(2) = 1/camera(3).R;
x(3) = 1/camera(4).R;
x(4) = camera(2).d;
x(5) = camera(3).d;
x(6) = camera(4).d;
end

function [ dist_total, dist_c, dist_d ] = calcDistBetweenCameras ( camera1, camera2 )
x1 = extractVars( camera1 );
x2 = extractVars( camera2 );
dist_total = sqrt(sum((x1 - x2).^2));
dist_c = sqrt(sum((x1(1:3) - x2(1:3)).^2));
dist_d = sqrt(sum((x1(4:6) - x2(4:6)).^2));
end

function [ length ] = calcCameraLength ( camera )
length = camera(2).d + camera(3).d + camera(4).d;
end