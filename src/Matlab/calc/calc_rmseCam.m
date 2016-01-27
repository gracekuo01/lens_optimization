function [ rmse ] = calc_rmseCam( camera, sourcex, sourcey, N, seed )
%[ rmse ] = calc_rmseCam( camera, sourcex, sourcey, N, seed )
%   calculate the rms error spot size of the source point specified
%
% N - number of rays to trace
% seed - optional seed for random generator, otherwise it is random
% everytime
%
% The "true" location of the spot is found by tracing the chief ray through
% the system (therefore, rmse will not take distortion into account)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin >= 5
    rng(seed)
else
    rng('shuffle')
end

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

% real (ideal) location:
%[xideal, xtideal, yideal, ytideal] =  traceRayForward( sourcex, sourcey,...
%    atan(-sourcex/dist_to_pupil), atan(-sourcey/dist_to_pupil), camera); 

rmse = calc_rmse( xout, yout, [], [] );

end

