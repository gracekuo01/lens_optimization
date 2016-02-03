function [ c, rmse_init] = test_optimize_dls( corr )%[ camera_array, rmse_array, time_elapsed] = test_optimize_dls( corr )
clear camera
clear camera_array
% constants - all come from Turnhout et. al. (2008)
EFL = 100;    % effective focal length
c1 = [-0.045 -0.0225 0 0.0225 0.045];     %1/0.020; % radius of curvature of first glass surface
c2 = c1;
c3 = c1;
r4 = inf;     % radius of curvature of last glass surface - solved for later
d0 = 1500;     % distance from object to first element (not from paper - made up)
d1 = [1 4 7 10 13];        %  10.346;  % thickness of first element
d2 = [1 4 7 10 13];       % air gap between first and second element
d3 = [1 4 7 10 13];         %  2.351;   % thickeness of second element;
d4 = 0;       % distance from last surface to image plane - solved for later
n1 = 1.618;   % index of refraction of first element (crown glass)
n2 = 1.717;   % index of refraction of second element (flint glass)
na = 1;       % index of refraction of air
sd = 33.33/2; % semidiamter of first element
seed = 1089345;   % seed for calculating random rmse
pixel_pitch = .02;
numAngSensors = 5;
N = 1000;      % number of rays traced for original spot diagram
n = 5;        % number of points in each monte carlo correction
Ndesigns = 50; % save the top Ndesigns
rmse_array = zeros(Ndesigns,1);
min_glass = 1; % min thickness of glass
min_air = 0;   % min spacing between elements

% field points
sourcex = [0 60 120]; sourcey = [0 60 120];



j1 = 4; j2 = 2; j3 = 5; j4 = 3; j5 = 3; j6 = 3;
c = createCamera([c1(j1) c2(j2) c3(j3) d1(j4) d2(j5) d3(j6), 0]);
[c, dend] = calc_lastd(c);

x0 = [c1(j1) c2(j2) c3(j3) d1(j4) d2(j5) d3(j6) dend];

figure; h = subplot(2,2,1);
viz_camera(c, h); title('Initial Point')
h = subplot(2,2,2); viz_spotdiag(c, 60, 60, 1000,[], h); 
rmse_init = rms(objectiveFunction(x0));
return
title(['Initial RMSE: ' num2str(rmse_init*1000) ' um']);
disp('Starting local optimization...')

options.Algorithm = {'levenberg-marquardt',.01};
tic
[x,resnorm,residual,exitflag,output]  = lsqnonlin(@objectiveFunction,x0, [], [], options);
time_elapsed = toc
rmse = objectiveFunction(x);
rmse_array = rmse;
camera_array = createCamera(x);

h = subplot(2,2,3);
viz_camera(camera_array, h); title('Final Design')
h = subplot(2,2,4); viz_spotdiag(camera_array, 60, 60, 1000,[], h);
title(['Final RMSE: ' num2str(rms(rmse)*1000) ' um']);

disp(['RMSE: ' num2str(rmse)])
disp('Done with local optimization!')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [camera] = createCamera(x)
        % create camera
        % x(1): r2, x(2): r3
        clear camera
        camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
        camera(2) = struct('R', 1/x(1),'d', x(4), 'n', n1, 'sd', sd);
        camera(3) = struct('R', 1/x(2),'d', x(5), 'n', na, 'sd', sd);
        camera(4) = struct('R', 1/x(3),'d', x(6), 'n', n2, 'sd', sd);
        camera(5) = struct('R', r4,  'd', x(7), 'n', na, 'sd', sd);
        camera = calc_lastr(camera, EFL); % set last radius of curvature, r4
        %camera = calc_lastd(camera);      % set distance to image plane, d4
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rmse] = objectiveFunction(x)
        addpath('monte_carlo_corr');
        
        if x(4) < min_glass || x(5) < min_air || x(6) < min_glass
            rmse = inf;
            return;
        end

        camera = createCamera(x);
        [ xout, xtout, yout, ytout ] = traceRayForward(0, 0, atan(.9*sd/d0), 0, camera);
        if isnan(xout)
            rmse = inf;
        else  
            rmse = zeros(size(sourcex));
            for i = 1:numel(sourcex)
                if strcmp(corr, 'corr')
                    rmse(i) = calc_rmseCorr( camera, sourcex(i), sourcey(i), N,...
                        seed, pixel_pitch, numAngSensors, n);
                elseif strcmp(corr, 'nocorr')
                    rmse(i) = calc_rmseCam( camera, sourcex(i), sourcey(i), N,...
                        seed);
                end
            end
            %rmse = rms(rmse_points);
        end        
    end

end


