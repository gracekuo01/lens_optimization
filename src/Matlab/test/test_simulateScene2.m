%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Simulate Scene
% Simulates resolution target through 50 mm singlet
% Uses "simulateScene" function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

source_file = '../../data/resolution_chart_cropped.png';

% Constants in camera
d0 = 100; 
d1 = 3;     d2 = 100;
r1 = 50;    r2 = -50;
n1 = 1.5;   na = 1;
sd = 11;
EFL = 50;
pixel_pitch = 0.02;
numAngSensors = 10;
f_lenslets = pixel_pitch*d2/(2*(sd+1));
xrange = [-5 5];
yrange = [-5 5];
xrange_source = xrange;
yrange_source = yrange;

% Create camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4
camera(3) = struct('R', r2,'d', d2-7, 'n', na, 'sd', sd);
%%
N = 50000000;
[ rawimg ] = simulateScene( camera, pixel_pitch, numAngSensors,...
    f_lenslets, xrange, yrange, source_file, xrange_source, yrange_source,  N);

figure; imshow(rawimg/(max(max(rawimg))));
