%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Idea Development - Difference between lenslet model and going directly
% from camera to 4D light field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constants in camera
d0 = 100; 
d1 = 3;     d2 = 100;
r1 = 50;    r2 = -50;
n1 = 1.5;   na = 1;
sd = 11;
EFL = 50;
pixel_pitch = 0.01;
numAngSensors = 10;
f_lenslets = pixel_pitch*d2/(2*(sd+1));
xrange = [-1 1];
yrange = [-1 1];
sourcex = 0;
sourcey = 0;
N = 10000;
n = 5;
seed = 5968703;

% Create camera
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera, r2] = calc_lastr(camera, EFL); % set last radius of curvature, r4
[camera, d2] = calc_lastd(camera);      % set distance to image plane, d4
ABCD_parax = calc_abcd(camera);
ABCD_parax(1,2) = 0;

%%

sd = camera(end).sd; % semidiamter
si = camera(end).d;  % distance from lens to image plane
[pupil_radius, dist_to_pupil] = calc_entrpupil(camera);

Ns = round(1.28*N + 2.5*sqrt(N) + 100);
Xrand = (rand(Ns,1)*2-1)*pupil_radius;
Yrand = (rand(Ns,1)*2-1)*pupil_radius;
I = find(sqrt(Xrand.^2+Yrand.^2)<=pupil_radius);
Xrand = Xrand(I(1:N));
Yrand = Yrand(I(1:N));

x0 = sourcex*ones(N,1); 
y0 = sourcey*ones(N,1);

xt = atan((Xrand-x0)/(dist_to_pupil));
yt = atan((Yrand-y0)/(dist_to_pupil));

%%

ImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
ImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
rawimg = zeros(round(ImgSize));

%%
I = 1;
xout = zeros(N, 1); yout = xout; xtout = xout; ytout = xout;
for i = 1:N
    [ xout_wl(i), xtout_wl(i), yout_wl(i), ytout_wl(i) ] = ...
        traceRayForward_withLenslets( x0(i), y0(i), xt(i), yt(i), camera,...
        f_lenslets, pixel_pitch );
    if ~(xout_wl(i) > xrange(2) || xout_wl(i) <= xrange(1) || ...
            yout_wl(i) > yrange(2) || yout_wl(i) <= yrange(1) || isnan(xout_wl(i)))
        % Determine pixel location
        pixX = floor((xout_wl(i)-xrange(1))/(pixel_pitch/numAngSensors))+1;
        pixY = floor((yout_wl(i)-yrange(1))/(pixel_pitch/numAngSensors))+1;
        % Increment that bin
        rawimg(pixX, pixY) = rawimg(pixX, pixY) + I;
    end
    
    [ xout(i), xtout(i), yout(i), ytout(i) ] = traceRayForward( x0(i),...
        y0(i), xt(i), yt(i), camera );
end
%%

binned_LF = binData( [xout yout xtout ytout], pixel_pitch, numAngSensors, xrange, yrange, sd, si );
raw_LF = rawImg2LF(rawimg, camera, xrange, yrange, pixel_pitch, numAngSensors, f_lenslets);
%%
raw_LF = rot90(raw_LF,2);

%%
raw_focused = squeeze(sum(sum(raw_LF, 1), 2));
binned_focused = squeeze(sum(sum(binned_LF, 1), 2));
figure; imagesc(raw_focused/max(max(raw_focused))); title('With raw image');
figure; imagesc(binned_focused/max(max(binned_focused))); title(' Binned: directly to LF');

%%

[ corrected_img ] = ...
    monteCarloCorrection_efficient( binned_LF, pixel_pitch,...
    numAngSensors, xrange, yrange, sd, si, n, camera, ABCD_parax);




