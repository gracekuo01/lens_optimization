function [ h ] = viz_spotdiag( camera, sourcex, sourcey, N, seed, h )
%[ h ] = viz_spotdiag( camera, sourcex, sourcey, N, seed, h )
%   Plots the spot diagram for the specified source point in axes h
%
%   viz_spotdiag( camera, sourcex, sourcey, N, [], h ) specified axis with
%   random seed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check inputs

if nargin > 4 && ~isempty(seed)
    rng(seed)
else
    rng('shuffle')
end

if nargin > 5
    axes(h);
else
    h = figure;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate spot diagram

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

plot(xout, yout, 'o');
grid on
axis equal


end

