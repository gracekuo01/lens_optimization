load('simplex_v_dls_1initpoint_0202.mat');

sourcex = [0 60 120];
sourcey = [0 60 120];

cam_xrange = [1500 1580];
cam_yrange = [-20 20];

N = 1000;

figure;
h = subplot(3,4,1);
viz_camera(camera_init, h);
xlim(cam_xrange); ylim(cam_yrange);
title(sprintf('Initial Design \n RMSE: %4.2f um', rmse_init*1000));
for i = 1: numel(sourcex)
    h = subplot(3,4,1+i);
    viz_spotdiag(camera_init, sourcex(i), sourcey(i), N, [], h);
    rmse_spot = calc_rmseCam(camera_init, sourcex(i), sourcey(i), N);
    title([num2str(rmse_spot*1000) ' um']);
end

h = subplot(3,4,5);
viz_camera(camera_dls_p01, h);
xlim(cam_xrange); ylim(cam_yrange);
title(sprintf('DLS Optimization \n Time Elapsed: %3.2f s \n RMSE: %3.2f um',...
    time_dls_p01, rms(rmse_dls_p01)*1000));
for i = 1: numel(sourcex)
    h = subplot(3,4,5+i);
    viz_spotdiag(camera_dls_p01, sourcex(i), sourcey(i), N, [], h);
    rmse_spot = calc_rmseCam(camera_dls_p01, sourcex(i), sourcey(i), N);
    title([num2str(rmse_spot*1000) ' um']);
end

h = subplot(3,4,9);
viz_camera(camera_simplex, h);
xlim(cam_xrange); ylim(cam_yrange);
title(sprintf('Simplex Optimization \n Time Elapsed: %3.2f s \n RMSE: %3.2f um',...
    time_simplex, rmse_simplex*1000))
for i = 1: numel(sourcex)
    h = subplot(3,4,9+i);
    viz_spotdiag(camera_simplex, sourcex(i), sourcey(i), N, [], h);
    rmse_spot = calc_rmseCam(camera_simplex, sourcex(i), sourcey(i), N);
    title([num2str(rmse_spot*1000) ' um']);
end