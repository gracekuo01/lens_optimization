function [ rmse ] = calc_rmseCorr( camera, sourcex, sourcey, N,...
    seed, pixel_pitch, numAngSensors, n)
%UNTITLED10 Summary of this function goes here
%   N - number of rays to send for original
%   n - number of monte carlo iterations

addpath('monte_carlo_corr');

if isempty(seed)
    rng('shuffle')
else
    rng(seed)
end

sd = camera(end).sd; % semidiamter
si = camera(end).d;  % distance from lens to image plane
[pupil_radius, dist_to_pupil] = calc_entrpupil(camera);

% Generate random uniform array of points covering entrance pupil
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



xout = zeros(N,1); yout = zeros(N,1);
xtout = zeros(N,1); ytout = zeros(N,1);
for i = 1:N
    [ xout(i), xtout(i), yout(i), ytout(i) ] = ...
        traceRayForward( x0(i), y0(i), xt(i), yt(i), camera );
end
xmax = (floor(max(xout)/pixel_pitch)+1)*pixel_pitch;
xmin = (floor(min(xout)/pixel_pitch))*pixel_pitch;
ymax = (floor(max(yout)/pixel_pitch)+1)*pixel_pitch;
ymin = (floor(min(yout)/pixel_pitch))*pixel_pitch;
xrange = [xmin xmax]; yrange = [ymin ymax];

xout_real = xout(~isnan(xout) & ~isnan(yout));
yout_real = yout(~isnan(xout) & ~isnan(yout));
xtout_real = xtout(~isnan(xout) & ~isnan(yout));
ytout_real = ytout(~isnan(xout) & ~isnan(yout));

binned_data = binData([xout_real yout_real xtout_real ytout_real], pixel_pitch,...
    numAngSensors, xrange, yrange, sd, si);

ABCD_parax = calc_abcd(camera);
ABCD_parax(1,2) = 0; % enforce imaging condition



%image = cellfun(@sum,cellfun(@sum, binned_data, 'UniformOutput', 0));
%figure; plot(xout, yout, 'o'); colorbar;

[ corrected_img, xout, yout, xtout, ytout, weights] = monteCarloCorrection_efficient( binned_data, pixel_pitch,...
    numAngSensors, xrange, yrange, sd, si, n, camera, ABCD_parax);
%figure; plot(xout, yout, 'o'); colorbar;
rmse = calc_rmse(xout, yout, [], [], weights);


end

