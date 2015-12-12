function [ xout, xtout, yout, ytout ] = traceRayThroughSurfaces( x0, y0, xt, yt, camera )
%UNTITLED3 Summary of this function goes here
%   Trace rays from the object plane (first surface) to the image plane
%   (n+1) surface
%   Ray at object plane is parametrized by x0, y0, xt, yt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

z0 = 0; % start surfaces at z = 0

% Trace through all surfaces
for i = 1:(numel(camera)-1)
    r = camera(i+1).R;
    z0 = z0 + camera(i).d; % increment position of current surface of interest
    n1 = camera(i).n;
    n2 = camera(i+1).n;
    [ x0, xt, y0, yt, z0 ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, r, z0, n1, n2);
end

% Propegate to image plane
z0 = z0 + camera(end).d;
n1 = camera(end).n;
[ xout, xtout, yout, ytout, zout ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, inf, z0, n1, n1);


end

