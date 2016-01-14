%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST FILE - Simulate Scene
% What does an image look like through a given camera?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constants in camera
d0 = 100; 
d1 = 1;     d2 = 100;
r1 = 50;    r2 = -50;
n1 = 1.5;   na = 1;
sd = 10;
EFL = 50;
pixel_pitch = 0.02;
numAngSensors = 15;
f_lenslets = pixel_pitch*d2/(2*sd);
xrange = [-2 2];
yrange = [-2 2];

ImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
ImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
rawimg = zeros(ImgSize);


% Create camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4

% Test Image: 4x4 mm  white square, centered in frame
% Trace 80,000 rays: every 5 um (0.005 mm), trace 100 rays with random
% angles
x_all = 0;
for i = 1%:numel(x_all)
    for j = 1%:numel(x_all)
        xt_rand = rand(10000,1)*.2-.1;
        yt_rand = rand(10000,1)*.2-.1;
        for k = 1:numel(xt_rand)
            [x, xt, y, yt] = traceRayForward(x_all(i), x_all(j),...
                xt_rand(k), yt_rand(k), camera);
            if ~isnan(x)
                [x, xt, y, yt, zout ] = traceRay_lensletArray( ...
                    x, y, 0, xt, yt, f_lenslets, 0, pixel_pitch);
                [rawimg] = traceRay_sensor(x, y, 0, xt, yt, f_lenslets,...
                    pixel_pitch, numAngSensors, xrange, yrange, rawimg);
            end
        end
    end
end
            


