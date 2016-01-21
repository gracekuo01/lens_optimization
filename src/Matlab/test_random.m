function [ rmse ] = test_random( camera_in )
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
sourcex = [0 10]; sourcey = [0 10];

x = extractVars(camera_in)
rmse = objectiveFunction(x);
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
            return
        end

        camera = createCamera(x);
        [ xout, xtout, yout, ytout ] = traceRayForward(0, 0, atan(.9*sd/d0), 0, camera);
        if isnan(xout)
            rmse = inf;
        else  
            rmse_points = zeros(size(sourcex));
            for i = 1:numel(sourcex)
            %rmse_points(i) = calc_rmseCorr( camera, sourcex(i), sourcey(i), N,...
            %    seed, pixel_pitch, numAngSensors, n);
            rmse_points(i) = calc_rmseCam( camera, sourcex(i), sourcey(i), N,...
                seed);
            end
            rmse = rms(rmse_points);
        end        
    end

end



function [ x ] = extractVars ( camera )
x(1) = 1/camera(2).R;
x(2) = 1/camera(3).R;
x(3) = 1/camera(4).R;
x(4) = camera(2).d;
x(5) = camera(3).d;
x(6) = camera(4).d;
x(7) = camera(5).d;
end





