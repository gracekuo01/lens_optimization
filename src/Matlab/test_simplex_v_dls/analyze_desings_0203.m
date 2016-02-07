load('simplex_v_dls_designs_0203.mat');
% includes: all_cameras 60x5x5 struct - last dimension: init, simplex,
%                           dls-lam = 0.01, dls-lam = 0.01, dls-lam = 0.001
%                           (yes 3 and 4 are the same)
%                           tolX = 1e-12
%          all_rmse 60x5 double -  column are the same as last dimension
%                           above
%          all_time 60x4 double - columns are init, simplex,
%                           dls-lam = 0.01, dls-lam = 0.01, dls-lam = 0.001
%                           Time elaspse for local optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mean_rmse = mean([all_rmse(:,2) all_rmse(:,4)],2);% all_rmse(:,5)],2);
[sorted_rmse_simp, sorted_ind_simp] = sort(all_rmse(:,2), 'ascend');
[sorted_rmse_dlsp01, sorted_ind_dlsp01] = sort(all_rmse(:,4), 'ascend');
[sorted_rmse_dlsp001, sorted_ind_dlsp001] = sort(all_rmse(:,5), 'ascend');
[sorted_rmse_mean, sorted_ind_mean] = sort(mean_rmse, 'ascend');
design_num = 1:(size(all_rmse,1));

figure;
subplot(3,1,1);
plot(design_num, all_rmse(sorted_ind_simp,2)*1000, 'o-', design_num, all_rmse(sorted_ind_simp, 4)*1000,'o-', ...
    design_num, all_rmse(sorted_ind_simp, 5)*1000, 'o-');
title('RSME Sorted by Simplex');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylim([0 100])
grid on
subplot(3,1,2);
plot(design_num, all_rmse(sorted_ind_dlsp01,2)*1000,'o-',  design_num, all_rmse(sorted_ind_dlsp01, 4)*1000,'o-', ...
    design_num, all_rmse(sorted_ind_dlsp01, 5)*1000,'o-');
title('RSME Sorted by DLS \lambda = 0.01');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylim([0 100])
grid on
subplot(3,1,3);
plot(design_num, all_rmse(sorted_ind_dlsp001,2)*1000,'o-',  design_num, all_rmse(sorted_ind_dlsp001, 4)*1000,'o-', ...
    design_num, all_rmse(sorted_ind_dlsp001, 5)*1000, 'o-');
title('RSME Sorted by DLS \lambda = 0.001');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylim([0 100])
grid on

figure;
plot(design_num, all_rmse(sorted_ind_mean,2)*1000,'o-',  design_num, all_rmse(sorted_ind_mean, 4)*1000,'o-', ...
    design_num, all_rmse(sorted_ind_mean, 5)*1000, 'o-');
title('RSME Sorted by mean rmse');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylim([0 200])
ylabel('RMSE (um)');
grid on

figure;
plot(design_num, all_rmse(sorted_ind_simp,2)*1000,'o-',  design_num, all_rmse(sorted_ind_dlsp01, 4)*1000,'o-', ...
    design_num, all_rmse(sorted_ind_dlsp001, 5)*1000, 'o-');
title('RSME after Local Optimization');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylim([0 200])
ylabel('RMSE (um)');
grid on

%%

[sorted_time, sorted_time_simp] = sort(all_time(:,1), 'ascend');
[sorted_time, sorted_time_dlsp01] = sort(all_time(:,3), 'ascend');
[sorted_time, sorted_time_dlsp001] = sort(all_time(:,4), 'ascend');

figure;
plot(design_num, all_time(:,1), 'o-', design_num, all_time(:,3), '-o', design_num, all_time(:,4), '-o');
title('Time Elapsed During Optimization');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylabel('Time Elapsed (s)');
grid on

figure;
plot(design_num, all_time(sorted_time_simp,1), 'o-',...
    design_num, all_time(sorted_time_dlsp01,3), '-o', design_num, all_time(sorted_time_dlsp001,4), '-o');
title('Time Elapsed During Optimization');
legend('Simplex', 'DLS \lambda = 0.01', 'DLS \lambda = 0.001');
ylabel('Time Elapsed (s)');
grid on

%%
N = 5; xrange = [1500 1700]; yrange = [-40 40];
shift = 0;
figure;
for i = 1:N
    h = subplot(N,3,3*(i-1)+1);
    viz_camera(all_cameras(sorted_ind_simp(i+shift),:,2), h);
    %xlim(xrange); ylim(yrange);%axis normal
    title(sprintf('RMSE: %2.0f um \n Vol: %3.1f cm^3', ...
        all_rmse(sorted_ind_simp(i+shift), 2)*1000, calc_cameraVol(all_cameras(sorted_ind_simp(i+shift),:,2))/100));
    
    h = subplot(N,3,3*(i-1)+2);
    viz_camera(all_cameras(sorted_ind_dlsp01(i+shift),:,4), h);
    %xlim(xrange); ylim(yrange);%axis normal
    title(sprintf('RMSE: %2.0f um \n Vol: %3.1f cm^3', ...
        all_rmse(sorted_ind_dlsp01(i+shift), 4)*1000, calc_cameraVol(all_cameras(sorted_ind_dlsp01(i+shift),:,4))/100));
    
    h = subplot(N,3,3*(i-1)+3);
    viz_camera(all_cameras(sorted_ind_dlsp001(i+shift),:,5), h);
    %xlim(xrange); ylim(yrange);%axis normal
    title(sprintf('RMSE: %2.0f um \n Vol: %3.1f cm^3', ...
        all_rmse(sorted_ind_dlsp001(i+shift), 5)*1000, calc_cameraVol(all_cameras(sorted_ind_dlsp001(i+shift),:,5))/100));

end
    
%%

figure; n = 25;
 h = subplot(3,1,1);
viz_camera(all_cameras(sorted_ind_dlsp01(n),:,1),h);
%xlim(xrange); ylim(yrange);
title('initial')
l1 = calc_length(all_cameras(sorted_ind_dlsp01(n),:,1))

 h = subplot(3,1,2);
viz_camera(all_cameras(sorted_ind_dlsp01(n),:,2),h);
%xlim(xrange); ylim(yrange);
title(sprintf('simplex: rmse = %2.1f', 1000*all_rmse(sorted_ind_dlsp01(n),2)));
l2 = calc_length(all_cameras(sorted_ind_dlsp01(n),:,2))

 h = subplot(3,1,3);
viz_camera(all_cameras(sorted_ind_dlsp01(n),:,4),h);
%xlim(xrange); ylim(yrange);
title(sprintf('DLS p01: rmse = %2.1f', 1000*all_rmse(sorted_ind_dlsp01(n),4)));
l3 = calc_length(all_cameras(sorted_ind_dlsp01(n),:,4))
%%
% Rays through weird cameras

for i = 1:3
    figure(1);
h = subplot(3,1,i)
sourcex= 60*(i-1);
sd = all_cameras(sorted_ind_simp(1), 2, 2).sd;
x = sourcex*ones(7, 1);
y = zeros(size(x)); yt =y;
sd_pos = [-.9 -.6 -.3 0 .3 .6 .9];
xt = -atan((sourcex-sd*sd_pos)/1500);
viz_cameraWithRay(all_cameras(sorted_ind_simp(1), :, 2), x, y, xt, yt, 'fwd', h);
viz_spotdiag(all_cameras(sorted_ind_simp(1), :, 2), sourcex, sourcex, 1000)
end