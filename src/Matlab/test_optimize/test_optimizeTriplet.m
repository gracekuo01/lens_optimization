function [ camera, x ] = test_optimizeTriplet( )
clear camera
% constants - all come from Turnhout et. al. (2008)
EFL = 100;    % effective focal length
r1 = 50;     %1/0.020; % radius of curvature of first glass surface
r2 = inf;
r3 = -50;
r4 = 50;     % radius of curvature of last glass surface - solved for later
r5 = 200;
r6 = -50;
d0 = 1500;     % distance from object to first element (not from paper - made up)
d1 = 10;        %  10.346;  % thickness of first element
d2 = 10;       % air gap between first and second element
d3 = 5;         %  2.351;   % thickeness of second element;
d4 = 20;
d5 = 8;       % distance from last surface to image plane - solved for later
d6 = 0;
n1 = 1.6;   % index of refraction of first element (crown glass)
n2 = 1.6;   % index of refraction of second element (flint glass)
n3 = 1.6;   % index of refraction of third element (crown glass)
na = 1;       % index of refraction of air
sd = 33.33/2; % semidiamter of first element
seed = 1089345;   % seed for calculating random rmse
pixel_pitch = .02;
numAngSensors = 5;
N = 1000;      % number of rays traced for original spot diagram
n = 5;        % number of points in each monte carlo correction

% field points
sourcex = [10]; sourcey = [10];

x0 = [1/r1 1/r2 1/r3 1/r4 1/r5 d1 d2 d3 d4 d5 ]; % initial condition

camera = createCamera(x0);
viz_cameraWithRay(camera);

rmse = objectiveFunction(x0);
disp('Initial Condition RMSE:'); disp(rmse);

keyboard

tic
%[x,rmse,exitflag] = fminsearch(@objectiveFunction,x,optimset('Display','iter', 'MaxFunEvals', 150));
[x,rmse,exitflag] = fminsearch(@objectiveFunction,x0);
toc
disp(['c1: ' num2str(x(1))]);
disp(['c2: ' num2str(x(2))]);
disp(['c3: ' num2str(x(3))]);
disp(['d1: ' num2str(x(4))]);
disp(['d2: ' num2str(x(5))]);
disp(['d3: ' num2str(x(6))]);
disp('Final RMSE:'); disp(rmse);
camera = createCamera(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [camera] = createCamera(x)
        % create camera
        % x(1): r2, x(2): r3
        clear camera
        camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
        camera(2) = struct('R', 1/x(1),'d', x(6), 'n', n1, 'sd', sd);
        camera(3) = struct('R', 1/x(2),'d', x(7), 'n', na, 'sd', sd);
        camera(4) = struct('R', 1/x(3),'d', x(8), 'n', n2, 'sd', sd);
        camera(5) = struct('R', 1/x(4),'d', x(9), 'n', na, 'sd', sd);
        camera(6) = struct('R', 1/x(5),'d', x(10), 'n', n3, 'sd', sd);
        camera(7) = struct('R', r6,  'd', d6, 'n', na, 'sd', sd);
        
        camera = calc_lastr(camera, EFL); % set last radius of curvature, r4
        camera = calc_lastd(camera);      % set distance to image plane, d4
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rmse] = objectiveFunction(x)
        addpath('monte_carlo_corr');

        camera = createCamera(x);
        [ xout, xtout, yout, ytout ] = traceRayForward(0, 0, atan(.9*sd/d0), 0, camera);
        if isnan(xout)
            rmse = inf;
            return
        end
        [ xout, xtout, yout, ytout ] = traceRayForward(0, 0, 0, 0, camera);
        if isnan(xout)
            rmse = inf;
            return
        end
        if x(8) < 1
            rmse = inf;
            return
        end

        rmse_points = zeros(size(sourcex));
        for i = 1:numel(sourcex)
            rmse_points(i) = calc_rmseCorr( camera, sourcex(i), sourcey(i), N,...
                seed, pixel_pitch, numAngSensors, n);
            rmse_points(i) = calc_rmseCam( camera, sourcex(i), sourcey(i), N,...
                seed);
        end
        rmse = rms(rmse_points);
        
    end

end

