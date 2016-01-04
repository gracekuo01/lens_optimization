function [ rmse ] = calc_rmseCam( camera, sourcex, sourcey, N, seed )
%[ rmse ] = calc_rmseCam( camera, sourcex, sourcey, N, seed )
%   calculate the rms error spot size of the source point specified
%
% N - number of rays to trace
% seed - optional seed for random generator, otherwise it is random
% everytime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TO DO !!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS STILL NEED TO BE WRITTEN %

% Plot spot diagram
N = 1000; % number of rays to trace
pupil_radius = 10;
dist_to_pupil = 150;
Ns = round(1.28*N + 2.5*sqrt(N) + 100);
Xrand = (rand(Ns,1)*2-1)*pupil_radius;
Yrand = (rand(Ns,1)*2-1)*pupil_radius;
I = find(sqrt(Xrand.^2+Yrand.^2)<=pupil_radius);
Xrand = Xrand(I(1:N));
Yrand = Yrand(I(1:N));

x0 = 15*ones(N,1); 
y0 = 15*ones(N,1);

xt = atan((Xrand-x0)/(dist_to_pupil));
yt = atan((Yrand-y0)/(dist_to_pupil));


xout = zeros(N,1); yout = zeros(N,1);
xtout = zeros(N,1); ytout = zeros(N,1);
for i = 1:N
    [ xout(i), xtout(i), yout(i), ytout(i) ] = ...
        traceRayThroughSurfaces( x0(i), y0(i), xt(i), yt(i), camera );
end

plot(xout, yout, 'o');







end

