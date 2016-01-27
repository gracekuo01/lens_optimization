%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test File - Simulate Spot using model of lenslet array, then try
% correction algorithm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Constants
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

%% Create Camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4
camera(3) = struct('R', r2,'d', d2-7, 'n', na, 'sd', sd);

ImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
ImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
rawimg = zeros(ImgSize);

%% Trace Rays through Camera

N = 10000000;
pupil_radius = camera(end).sd;
dist_to_pupil = camera(end).d;

% source on axis
sourcex = 0;
sourcey = 0;
x_rand = sourcex;
y_rand = sourcey;

% random distrubution over pupil
Ns = round(1.28*N + 2.5*sqrt(N) + 100);
x_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
y_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
I = find(sqrt(x_pupil_rand.^2+y_pupil_rand.^2)<=pupil_radius);
x_pupil_rand = x_pupil_rand(I(1:N));
y_pupil_rand = y_pupil_rand(I(1:N));

xt_rand = atan((x_pupil_rand - x_rand)/dist_to_pupil);
yt_rand = atan((y_pupil_rand - y_rand)/dist_to_pupil);

for i = 1:N
    if mod(i,1000000) == 0
        disp(i/1000000)
    end
    [x, xt, y, yt] = traceRayForward(x_rand, y_rand,...
        xt_rand(i), yt_rand(i), camera);
    if ~isnan(x)
        [x, xt, y, yt, zout ] = traceRay_lensletArray( ...
            x, y, 0, xt, yt, f_lenslets, 0, pixel_pitch);
        I = 1;
        %%%%%%%% Trace Ray To Sensor and Bin %%%%%%%%%%%%%%%%%%%%%%%%%%
        % Propegate ray to sensor plane
        xout = tan(xt)*(f_lenslets)+x;
        yout = tan(yt)*(f_lenslets)+y;
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
    
end

%%
figure; imshow(rawimg/max(max(rawimg)));
