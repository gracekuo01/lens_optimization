%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Can input a optical formual of a "camera" as an array of spherical
% sufaces.
% Each surface is a structure with the following properties, modeled off of
% those in Zemax
%   surf.R = radius (mm)
%   surf.d = thickness (mm)
%   surf.n = index of refraction (after this surface)
%   surf.sd = semidiameter (mm)


% Example
% The first surface is always the object plane
clear camera
camera(1) = struct('R', inf,   'd', 150, 'n', 1,   'sd', inf);   % Object plane
camera(2) = struct('R', inf,   'd', 10,  'n', 1.5, 'sd', 20);
camera(3) = struct('R', -38.7, 'd', 5, 'n', 1,   'sd', 20);
camera(4) = struct('R', 50,   'd', 5,  'n', 1.5, 'sd', 20);
camera(5) = struct('R', inf, 'd', 150, 'n', 1,   'sd', 20);

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

%%
xout = zeros(N,1); yout = zeros(N,1);
xtout = zeros(N,1); ytout = zeros(N,1);
for i = 1:N
    [ xout(i), xtout(i), yout(i), ytout(i) ] = ...
        traceRayThroughSurfaces( x0(i), y0(i), xt(i), yt(i), camera );
end

plot(xout, yout, 'o');

%%
h = figure(2);
h = viz_camera(camera, h);

