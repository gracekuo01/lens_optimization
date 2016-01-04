%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Test EFL solver
%
% Create a sample camera, calc EFL, 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set up camera
clear camera
camera(1) = struct('R', inf,  'd', 100,   'n', 1, 'sd', inf);   % Object plane
camera(2) = struct('R', 50, 'd', 1,  'n', 1.5, 'sd', 5);
camera(3) = struct('R', -50, 'd', 100,   'n', 1, 'sd', 5);

ELF = calc_efl(camera);

[camera, R] = calc_lastr(camera, 50);

EFL = calc_efl(camera)
R
