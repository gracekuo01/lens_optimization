%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Simulate Scene through best doublet for no correction case
% doublet_global_0121.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

source_file = '../../data/resolution_chart_cropped.png';
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
    
load([path filename_nocorr]);
[sorted_rmse_nocorr, sort_ind_nocorr] = sort(rmse_array_nocorr, 'ascend');
% get the number 1 (best) camera
camera = camera_array_nocorr(sort_ind_nocorr(16), :);
m = calc_mag(camera);
%%

% Constants in camera
dend = camera(end).d;
sd = camera(end).sd;
pixel_pitch = 0.02;
numAngSensors = 1;
f_lenslets = pixel_pitch*dend/(2*(sd+1));
xrange = [-10 10];
yrange = [-10 10];
xrange_source = round(xrange/m);
yrange_source = round(yrange/m);

%%
N = 5000000;
[ rawimg ] = simulateScene( camera, pixel_pitch, numAngSensors,...
    f_lenslets, xrange, yrange, source_file, xrange_source, yrange_source,  N);

figure; imshow(rawimg/(max(max(rawimg))));
