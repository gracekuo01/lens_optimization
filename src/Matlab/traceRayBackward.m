function [ xout, xtout, yout, ytout ] = traceRayBackward( x0, y0, xt, yt, camera )
%[ xout, xtout, yout, ytout ] = traceRayBackward( x0, y0, xt, yt, camera )
%   Trace rays from the image plane (n+1) surface to the object plane
%   1st surface
%   Ray at image plane is parametrized by x0, y0, xt, yt where the angles
%   are measured from the image plane towards the object plane (already
%   pointing backwards)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% intialize outputs to nan
xout = nan; xtout = nan;
yout = nan; ytout = nan;

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
    if isnan(x0)
        return
    end
end

% Propegate to image plane
z_lens = z_lens + camera(1).d;
n1 = camera(1).n;
[ xout, xtout, yout, ytout, zout ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, inf, z_lens, inf, n1, n1);


end

