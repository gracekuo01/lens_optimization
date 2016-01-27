function [ xout, xtout, yout, ytout ] = traceRayForward_withLenslets(...
    x0, y0, xt, yt, camera, f_lenslets, pixel_pitch )
%[ xout, xtout, yout, ytout ] = traceRayForward_withLenslets(...
%    x0, y0, xt, yt, camera, f_lenslets, pixel_pitch )
%
%   Trace ray from object plane through camera (forward), through lenslets,
%   and to sensor plane.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize outputs to nan
xout = nan; xtout = nan;
yout = nan; ytout = nan;

% Trace ray through camera
[x, xt, y, yt] = traceRayForward(x0, y0, xt, yt, camera);

% Check that ray is still in system
if isnan(x)
    return
end

% Trace ray through lenslet array, located at sensor plane of camera
[x, xtout, y, ytout, zout ] = traceRay_lensletArray( x, y, 0, xt, yt,...
    f_lenslets, 0, pixel_pitch );

% Propegate ray to sensor plane, assumed to be the f_lenslets away
xout = tan(xtout)*(f_lenslets)+x;
yout = tan(ytout)*(f_lenslets)+y;


end

