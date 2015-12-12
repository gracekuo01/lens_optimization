%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Can input a optical formual of a "camera" as an array of spherical
% sufaces.
% Each surface is a structure with the following properties, modeled off of
% those in Zemax
%   surf.R = radius
%   surf.d = thickness
%   surf.n = index of refraction (after this surface)


% Example
% The first surface is always the object plane
clear camera
camera(1) = struct('R', inf,   'd', 150, 'n', 1);   % Object plane
camera(2) = struct('R', inf,   'd', 10,  'n', 1.5);
camera(3) = struct('R', -38.7, 'd', 150, 'n', 1);

%%
[xout, xtout, yout, ytout, zout]  = traceRay_SphericalSurf3D(0, 0, 1.3, 2, inf, 100, 1, 1.5);


