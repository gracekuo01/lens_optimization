%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Test Monte Carlo Correction
%
% Uses 75 mm lens ray data from Zemax to test Monte Carlo Correction
% function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('..');

% Load ray data collected in Zemax 
load('../../data/rays75mm.mat');

sd = 5;
pixel_pitch = 0.01;
numAngSensors = 10;
xrange = [-0.2 0.2];
yrange = [-0.2 0.2];
si = 150; 
N = 100;
n = 1.5185; % at 550 nm

% bin data and display figure
binned_data = binData(rays(:,:,2), pixel_pitch, numAngSensors, xrange, yrange, sd, si);
image = cellfun(@sum,cellfun(@sum, binned_data, 'UniformOutput', 0));
figure; imagesc(image); colorbar;


% set up real and paraxial system for correction
clear camera
camera(1) = struct('R', inf,   'd', 150,    'n', 1, 'sd', inf);   % Object plane
camera(2) = struct('R', inf,   'd', 1,      'n', n, 'sd', sd);
camera(3) = struct('R', -39.2, 'd', 149.35, 'n', 1, 'sd', sd);

ABCD_parax = [1 150; 0 1]*[1 0; -1/75 1]*[1 150; 0 1];

[ corrected_img, xout, yout, xtout, ytout] = monteCarloCorrection( binned_data, pixel_pitch,...
    numAngSensors, xrange, yrange, sd, si, N, camera, ABCD_parax);

figure; imagesc(corrected_img); colorbar;

rmse = calc_rmse(xout, yout, 0, 0)