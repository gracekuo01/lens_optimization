function [ camera, x ] = test_optimizeSingletCorr( )
clear camera
x0 = [50, 10]; % initial condition
tic
rmse = objectiveFunction(x0)
toc

%[x,rmse,exitflag] = fminsearch(@objectiveFunction,x,optimset('Display','iter', 'MaxFunEvals', 150));
[x,rmse,exitflag] = fminsearch(@objectiveFunction,x0);
x
rmse
%exitflag


        % Constants
        sd = 10;  % semidiamter
        n = 1.5;  % index of refraction
        so = 150; % distance from object to lens
        si = 150; % distance from lens to image plane
        sourcex = 5; % source position x
        sourcey = 5; % source position y
        pixel_pitch = 0.02;
        numAngSensors = 10;
        efl = 75;
camera(1) = struct('R', inf,  'd', so,   'n', 1, 'sd', inf);   % Object plane
camera(2) = struct('R', x(1), 'd', x(2), 'n', n, 'sd', sd);
camera(3) = struct('R', inf, 'd', si,   'n', 1, 'sd', sd);

camera = calc_lastr(camera, efl);
camera = calc_lastd(camera);
viz_cameraWithRay(camera, 0, 0, atan(.9*sd/so), 0, 'fwd');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rmse] = objectiveFunction(x)
        addpath('monte_carlo_corr');
        % Variables
        % x(1): R1 radius of curvature of first surface  - init: inf
        % x(2): R2 radius of curvature of second surface - init: -38.7
        % x(3): spacing between first and second surface - init: 10
        
        % Constants
        sd = 10;  % semidiamter
        n = 1.5;  % index of refraction
        so = 150; % distance from object to lens
        si = 150; % distance from lens to image plane
        sourcex = [0 10]; % source position x
        sourcey = [0 0]; % source position y
        pixel_pitch = 0.02;
        numAngSensors = 10;
        efl = 75;
        
        % Set up camera
        camera(1) = struct('R', inf,  'd', so,   'n', 1, 'sd', inf);   % Object plane
        camera(2) = struct('R', x(1), 'd', x(2), 'n', n, 'sd', sd);
        camera(3) = struct('R', inf, 'd', si,   'n', 1, 'sd', sd);
        
        camera = calc_lastr(camera, efl);
        camera = calc_lastd(camera);
        
        N = 100; % number of rays to trace
        seed = 416;
        n = 5;
        
        [ xout, xtout, yout, ytout ] = traceRayForward(0, 0, atan(.9*sd/so), 0, camera);
        if isnan(xout)
            rmse = inf;
        else  
            rmse_points = zeros(size(sourcex));
            for i = 1:numel(sourcex)
            rmse_points(i) = calc_rmseCorr( camera, sourcex(i), sourcey(i), N,...
                seed, pixel_pitch, numAngSensors, n);
            %rmse_points(i) = calc_rmseCam( camera, sourcex(i), sourcey(i), N,...
            %    seed);
            end
            rmse = rms(rmse_points);
        end
        
        
    end

end


