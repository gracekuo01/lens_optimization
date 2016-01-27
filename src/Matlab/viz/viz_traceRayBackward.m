function [ xout, yout, zout ] = viz_traceRayBackward( x0, y0, xt, yt, camera )
%[ xout, yout, zout ] = viz_traceRayBackward( x0, y0, xt, yt, camera )
%
% Helper function for visualizing camera with rays.
%
% Traces specified ray  from the image plane (n+1) surface to the object 
% plane (first surface) and returns the coordinates of the intersect with 
% each surface for plotting.
%
% Ray at object plane is parametrized by x0, y0, xt, yt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xout = zeros(numel(camera)+1, 1); yout = xout; zout = xout;
z_lens = 0; % start surfaces at z = 0
z0 = 0;

% Trace through all surfaces
% R -> -R
for i = numel(camera):-1:2
    r = -camera(i).R;
    z_lens = z_lens + camera(i).d; % increment position of current surface of interest
    sd = camera(i).sd;
    n1 = camera(i).n;
    n2 = camera(i-1).n;
    [ x0, xt, y0, yt, z0 ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, r, z_lens, sd, n1, n2);
    xout(i) = x0;
    yout(i) = y0;
    zout(i) = z0;
end

% Propegate to image plane
z_lens = z_lens + camera(1).d;
n1 = camera(1).n;
[ x0, xt, y0, yt, z0 ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, inf, z_lens, inf, n1, n1);
xout(1) = x0;
yout(1) = y0;
zout(1) = z0;
zout = -(zout - (z0*ones(size(zout))/2))+ (z0*ones(size(zout))/2);
end

