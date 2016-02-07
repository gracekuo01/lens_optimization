function [ all_cameras, all_rmse, all_time ] = compare_simplex_4d( )
dbstop if error
clear camera
clear camera_array

EFL = 100;    % effective focal length
c_range = [-0.045 0.045]; % range of initial curvatures (c1 - c3)
d_range = [ 1 13];       % range of inital distances (d1 - d3)
r4 = inf;     % radius of curvature of last glass surface - solved for later
d0 = 1500;     % distance from object to first element (not from paper - made up)
d4 = 0;       % distance from last surface to image plane - solved for later
n1 = 1.618;   % index of refraction of first element (crown glass)
n2 = 1.717;   % index of refraction of second element (flint glass)
na = 1;       % index of refraction of air
sd = 33.33/2; % semidiamter of first element
seed = 1089345;   % seed for calculating random rmse
pixel_pitch = .02;
numAngSensors = 10;
N = 1000;      % number of rays traced for original spot diagrams
n = 10;        % number of points in each monte carlo correction
Ndesigns = 60; % save the top Ndesigns
min_glass = 1; % min thickness of glass
min_air = 0;   % min spacing between elements
corr = 'corr';

% field points
sourcex = [0 60 120]; sourcey = [0 60 120];

load('all_cameras_0202.mat')
init_cameras = all_cameras(:,:,1);
clear all_cameras
clear all_rmse
clear all_time


% all_rmse = zeros(Ndesigns, 5);
% all_time = zeros(Ndesigns, 4);
% 
% % get Ndesigns random inital starting points in range. elinimate (and
% % replace) infeasible ones
% disp('Getting initial designs...'); tic
% x0 = zeros(Ndesigns, 7);
% for k = 1:Ndesigns
%     goodDes = 0;
%     while (~goodDes)
%         rng('shuffle')
%         c = (rand(1,3))*(c_range(2)-c_range(1))+c_range(1);
%         d = (rand(1,3))*(d_range(2)-2d_range(1))+d_range(1);
%         camera_init = createCamera([c(1) c(2) c(3) d(1) d(2) d(3), d4]);
%         [camera_init, dend] = calc_lastd(camera_init);
%         x = [c(1) c(2) c(3) d(1) d(2) d(3), dend];
%         test_rmse = objectiveFunctionSimp(x);
%         if ~isinf(test_rmse)
%             goodDes = 1;
%             all_cameras(k,:,1) = camera_init;
%             x0(k,:) = x;
%             all_rmse(k,1) = test_rmse;
%         end    
%     end
%     disp(sprintf('Completed %d / %d inital designs', k, Ndesigns));
% end
% disp('Completed Inital Designs in'); toc

disp('Starting local optimization...')
for k = 1:Ndesigns
    x0 = getXFromCam(init_cameras(k, :));
    % Simplex optimization
    tic
    [x,rmse] = fminsearch(@objectiveFunctionSimp,x0);
    all_time(k,1) = toc;
    all_rmse(k,1) = rmse;
    all_cameras(k,:,1) = createCamera(x);
%     disp('simplex done')
%     
%     % Damped Least Squares
%     % lam = 0.1
%     options.Algorithm = {'levenberg-marquardt',0.01};
%     tic
%     [x]  = lsqnonlin(@objectiveFunctionDLS,x0(k,:), [], [], options);
%     all_time(k,2) = toc;
%     all_rmse(k,3) = objectiveFunctionSimp(x);
%     all_cameras(k,:,3) = createCamera(x);
%     
%     % lam = 0.01
%     options.Algorithm = {'levenberg-marquardt',0.01};
%     options.TolX = 1e-12;
%     tic
%     [x]  = lsqnonlin(@objectiveFunctionDLS,x0(k,:), [], [], options);
%     all_time(k,3) = toc;
%     all_rmse(k,4) = objectiveFunctionSimp(x);
%     all_cameras(k,:,4) = createCamera(x);
%     
%     % lam = 0.001
%     options.Algorithm = {'levenberg-marquardt',0.001};
%     tic
%     [x]  = lsqnonlin(@objectiveFunctionDLS,x0(k,:), [], [], options);
%     all_time(k,4) = toc;
%     all_rmse(k,5) = objectiveFunctionSimp(x);
%     all_cameras(k,:,5) = createCamera(x);
    
    disp(sprintf('Optimized %d / %d designs', k, Ndesigns))
    disp(['RMSE: ' num2str(all_rmse(k,:))])
end

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
    function [rmse] = objectiveFunctionDLS(x)
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
        end        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rmse] = objectiveFunctionSimp(x)
        rmse_points = objectiveFunctionDLS(x);
        rmse = rms(rmse_points);
    end

end

function x = getXFromCam( camera )
x(1) = 1/camera(2).R;
x(2) = 1/camera(3).R;
x(3) = 1/camera(4).R;
x(4) = camera(2).d;
x(5) = camera(3).d;
x(6) = camera(4).d;
x(7) = camera(5).d;
end



