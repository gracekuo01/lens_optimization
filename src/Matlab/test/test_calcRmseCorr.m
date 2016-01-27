%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Test calculate RMSE with correction algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
sourcex = 0;
sourcey = 0;
N = 1000;
n = 5;
seed = 5968703;

% Create camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4

ABCD_parax = calc_abcd(camera);
ABCD_parax(1,2) = 0;

tic
[ rmse ] = calc_rmseCorr( camera, sourcex, sourcey, N,...
     seed, pixel_pitch, numAngSensors, n)
toc
tic
[rmse ] = calc_rmseCam( camera, sourcex, sourcey, N, seed)
toc