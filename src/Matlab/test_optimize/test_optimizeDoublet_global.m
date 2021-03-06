function [ camera_array, rmse_array, init_ind ] = test_optimizeDoublet_global( corr )
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

disp('Survey of landscape...')
% initial survey of the field
all_points = zeros(5,5,5,5,5,5);
for j1 = 1:5
    for j2 = 1:5
        for j3 = 1:5
            for j4 = 1:5
                for j5 = 1:5
                    for j6 = 1:5
                        
                        x = [c1(j1) c2(j2) c3(j3) d1(j4) d2(j5) d3(j6) 0];
                        c = createCamera(x);
                        [c, dend ] = calc_lastd(c);
                        x(7) = dend;
                        all_points(j1, j2, j3, j4, j5, j6) = objectiveFunction(x);
                        
                    end
                end
            end
        end
        disp([num2str(((j2+5*(j1-1))/25)*100) '% complete'])
    end
end

disp('Survey of the landscape complete')
disp('Starting local optimization...')

% get the best points
copy = all_points;
init_ind = zeros(Ndesigns, 6);

for k = 1:Ndesigns
    [best, index] = min(copy(:));
    copy(index) = inf;
    [j1, j2, j3, j4, j5, j6] = ind2sub(size(copy), index);
    init_ind(k, :) = [j1, j2, j3, j4, j5, j6];
    x0 = [c1(j1) c2(j2) c3(j3) d1(j4) d2(j5) d3(j6) dend];
    
    [x,rmse,exitflag] = fminsearch(@objectiveFunction,x0);
    rmse_array(k) = rmse;
    camera_array(k,:) = createCamera(x);
    disp([num2str(k) ' / ' num2str(Ndesigns) ' complete'])
    disp(['RMSE: ' num2str(rmse)])
   
end

disp('Done with local optimization!')


% % x0 = [1/r1 .015, 0.025 d1 d2 d3]; % initial condition
% % 
%  camera = createCamera(x0);
% viz_cameraWithRay(camera);
% keyboard
% 
% rmse = objectiveFunction(x0);
% disp('Initial Condition RMSE:'); disp(rmse);
% 
% tic
% %[x,rmse,exitflag] = fminsearch(@objectiveFunction,x,optimset('Display','iter', 'MaxFunEvals', 150));
% [x,rmse,exitflag] = fminsearch(@objectiveFunction,x0);
% toc
% disp(['c1: ' num2str(x(1))]);
% disp(['c2: ' num2str(x(2))]);
% disp(['c3: ' num2str(x(3))]);
% disp(['d1: ' num2str(x(4))]);
% disp(['d2: ' num2str(x(5))]);
% disp(['d3: ' num2str(x(6))]);
% disp('Final RMSE:'); disp(rmse);
% camera = createCamera(x);


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
            rmse_points = zeros(size(sourcex));
            for i = 1:numel(sourcex)
                if strcmp(corr, 'corr')
                    rmse_points(i) = calc_rmseCorr( camera, sourcex(i), sourcey(i), N,...
                        seed, pixel_pitch, numAngSensors, n);
                elseif strcmp(corr, 'nocorr')
                    rmse_points(i) = calc_rmseCam( camera, sourcex(i), sourcey(i), N,...
                        seed);
                end
            end
            rmse = rms(rmse_points);
        end        
    end

end


