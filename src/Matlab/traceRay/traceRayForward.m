function [ xout, xtout, yout, ytout ] = traceRayForward( x0, y0, xt, yt, camera )
%[ xout, xtout, yout, ytout ] = traceRayForward( x0, y0, xt, yt, camera )
%   Trace rays from the object plane (first surface) to the image plane
%   (n+1) surface
%   Ray at object plane is parametrized by x0, y0, xt, yt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% intialize outputs to nan
xout = nan; xtout = nan;
yout = nan; ytout = nan;

z_lens = 0; % start surfaces at z = 0
z0 = 0;

% Trace through all surfaces
for i = 2:numel(camera)
    r = camera(i).R;
    z_lens = z_lens + camera(i-1).d; % increment position of current surface of interest
    sd = camera(i).sd;
    n1 = camera(i-1).n;
    n2 = camera(i).n;
    [ x0, xt, y0, yt, z0 ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, r, z_lens, sd, n1, n2);
    if isnan(x0)
        return
    end
end

% Propegate to image plane
z_lens = z_lens + camera(end).d;
n1 = camera(end).n;
[ xout, xtout, yout, ytout, zout ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, inf, z_lens, inf, n1, n1);


end

