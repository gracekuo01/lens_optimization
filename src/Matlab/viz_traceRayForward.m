function [ xout, yout, zout ] = viz_traceRayForward( x0, y0, xt, yt, camera )
%UNTITLED3 Summary of this function goes here
%   Trace rays from the object plane (first surface) to the image plane
%   (n+1) surface
%   Ray at object plane is parametrized by x0, y0, xt, yt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xout = zeros(numel(camera)+1, 1); yout = xout; zout = xout;
z_lens = 0; % start surfaces at z = 0
z0 = 0;

xout(1) = x0; yout(1) = y0; zout(1) = z0;
% Trace through all surfaces
for i = 2:numel(camera)
    r = camera(i).R;
    z_lens = z_lens + camera(i-1).d; % increment position of current surface of interest
    sd = camera(i).sd;
    n1 = camera(i-1).n;
    n2 = camera(i).n;
    [ x0, xt, y0, yt, z0 ] = traceRay_SphericalSurf3D...
        ( x0, y0, z0, xt, yt, r, z_lens, sd, n1, n2);
    xout(i) = x0;
    yout(i) = y0;
    zout(i) = z0;
end

% Propegate to image plane
z_lens = z_lens + camera(end).d;
n1 = camera(end).n;
[ x0, xtout, y0, ytout, z0 ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, inf, z_lens, inf, n1, n1);
xout(end) = x0;
yout(end) = y0;
zout(end) = z0;

end

