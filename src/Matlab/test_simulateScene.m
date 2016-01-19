%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Simulate Scene
% What does an image look like through a given camera?
% simulates BW smile through 50 mm  singlet
% does NOT used "simulateScene" script
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
f_lenslets = pixel_pitch*d2/(2*12);
xrange = [-5 5];
yrange = [-5 5];
xrange_source = xrange;
yrange_source = yrange;


ImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
ImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
rawimg = zeros(ImgSize);

%%
filename = '../../data/sample_BW.png';
truth_img = rgb2gray(imread(filename));
truth_img = double(round(truth_img/max(max(truth_img))));
figure; imshow(truth_img);
%%

% Create camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4
camera(3) = struct('R', r2,'d', d2-7, 'n', na, 'sd', sd);

%%
% Test Image: 4x4 mm  white square, centered in frame
% Trace 80,000 rays: every 5 um (0.005 mm), trace 100 rays with random
% angles
N = 25000000;
pupil_radius = camera(end).sd;
dist_to_pupil = camera(end).d;


x_ind_rand = (rand(N,1)*(size(truth_img, 1)-1))+1;
y_ind_rand = (rand(N,1)*(size(truth_img, 2)-1))+1;
x_rand = (x_ind_rand - size(truth_img, 1)/2)*(xrange_source(2)/(size(truth_img, 1)/2));
y_rand = (y_ind_rand - size(truth_img, 2)/2)*(yrange_source(2)/(size(truth_img, 2)/2));
x_ind_rand = round(x_ind_rand);
y_ind_rand = round(y_ind_rand);

Ns = round(1.28*N + 2.5*sqrt(N) + 100);
x_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
y_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
I = find(sqrt(x_pupil_rand.^2+y_pupil_rand.^2)<=pupil_radius);
x_pupil_rand = x_pupil_rand(I(1:N));
y_pupil_rand = y_pupil_rand(I(1:N));

xt_rand = atan((x_pupil_rand - x_rand)/dist_to_pupil);
yt_rand = atan((y_pupil_rand - y_rand)/dist_to_pupil);



for i = 1:N
    if (mod(i, 1000000) == 1)
        tic
    end
    I = truth_img(x_ind_rand(i), y_ind_rand(i));
    if (I ~= 0)
        
        [ xout, xtout, yout, ytout ] = traceRayForward_withLenslets(...
            x_rand(i), y_rand(i), xt_rand(i), yt_rand(i), camera,...
            f_lenslets, pixel_pitch );
        % Check ray is in field of view
        if ~(xout > xrange(2) || xout <= xrange(1) || yout > yrange(2) || yout <= yrange(1) || ...
                isnan(xout) || isinf(xout) || isinf(yout))
            % Determine pixel location
            pixX = floor((xout-xrange(1))/(pixel_pitch/numAngSensors))+1;
            pixY = floor((yout-yrange(1))/(pixel_pitch/numAngSensors))+1;
            % Increment that bin
            rawimg(pixX, pixY) = rawimg(pixX, pixY) + I;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    if (mod(i, 1000000) == 0)
        disp(i/1000000)
        toc
    end
end
     
%%
figure; imshow(rawimg/max(max(rawimg)));

%%
% [x, xt, y, yt] = traceRayForward(x_rand(i), y_rand(i),...
%     xt_rand(i), yt_rand(i), camera);
% if ~isnan(x)
%     [x, xt, y, yt, zout ] = traceRay_lensletArray( ...
%         x, y, 0, xt, yt, f_lenslets, 0, pixel_pitch);
%     [rawimg] = traceRay_sensor(x, y, 0, xt, yt, f_lenslets,...
%        pixel_pitch, numAngSensors, xrange, yrange,...
%        truth_img(x_ind_rand(i), y_ind_rand(i)), rawimg);
%     
%     I = truth_img(x_ind_rand(i), y_ind_rand(i));
%     %%%%%%% Trace Ray To Sensor and Bin %%%%%%%%%%%%%%%%%%%%%%%%%%
%     Propegate ray to sensor plane
%     xout = tan(xt)*(f_lenslets)+x;
%     yout = tan(yt)*(f_lenslets)+y;
