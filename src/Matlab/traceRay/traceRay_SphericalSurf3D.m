function [ xout, xtout, yout, ytout, zout ] = traceRay_SphericalSurf3D...
    ( x0, y0, z0, xt, yt, r, z_lens, sd, n1, n2)
% [ xout, xtout, yout, ytout, zout ] = traceRay_SphericalSurf3D 
%   ( x0, y0, z0, xt, yt, r, z_lens, sd, n1, n2)
%
% Traces a ray specified by (x0, y0, z0, xt, yt) throught the 3D spherical
% surface specified by (r, z_lens, sd, n1, n2).
%
% Inputs:
%   x0, y0, z0 - initial x, y, and z positions of ray
%   xt, yt - initial x and y angles of ray
%   r  - lens radius
%   z_lens  - z position of lens center
%   sd - semidiamter of lens
%   n1 - index of refraction of first medium
%   n2 - index of refraction of second medium
%
% Outputs
%   xout, xtout - final x position and final x angle
%   yout, ytout - final y position and final y angle
%   zout - final z position
%
%   Output will be 'nan' if the ray does not hit the specified surface. This
%   could be because
%       (1) the curvature is too high, so the ray and the lens never
%           intersect. 
%       (2) the current surface is behind the
%           previous surface, which is non-physical.
%       (3) the ray is outside the semidiamter of the lens
%   If the output is complex, there was total internal refection.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize all outputs to nan
xout = nan;
xtout = nan;
yout = nan;
ytout = nan;
zout = nan;

if isnan(x0)
    return
end

tx = tan(xt);
ty = tan(yt);

dz = z_lens-z0;

% Case where surface is flat (r = inf)
if isinf(r)
    
    % check surface is in front of ray
    if dz < 0
        return
    end
    
    zout = z_lens;
    xout = tx*dz+x0;
    yout = ty*dz+y0;
    
    % check if ray is within surface extent (semidiameter)
    if (xout^2 + yout^2 > sd^2)
        zout = nan; xout = nan; yout = nan;
        return
    else
        xtout = asin((n1/n2)*sin(xt));
        ytout = asin((n1/n2)*sin(yt));
        return
    end
end

% Calculate sphere center, zc
zc = dz + r;

% Calculate sqrt term of quadratic equation - if this is negative there is no intercept.
sqrtterm = (r^2*tx^2 + r^2*ty^2 + r^2 - tx^2*y0^2 - tx^2*zc^2 + ...
    2*tx*ty*x0*y0 - 2*tx*x0*zc - ty^2*x0^2 - ty^2*zc^2 - 2*ty*y0*zc - ...
    x0^2 - y0^2)^(1/2);

% Case where curvature is too high so there is no intercept (return nan)
if sqrtterm < 0
    return;
end


% Calculate intercept between ray and surface with the rest of the quadratic equation
% There are 2 intercepts between a line and a sphere
z_inter1 = (zc - tx*x0 - ty*y0 + sqrtterm)/(tx^2 + ty^2 + 1);
z_inter2 = -(tx*x0 - zc + ty*y0 + sqrtterm)/(tx^2 + ty^2 + 1);
z_inter = 0;

zray = 0;
% To be the "correct" intercept, it must be the first intercept to the right of the intial ray position
if (z_inter1 < zray && z_inter2 >= zray)
    z_inter = z_inter2;
elseif (z_inter1 >= zray && z_inter2 < zray)
    z_inter = z_inter1;
elseif (z_inter1 >= zray && z_inter2 >= zray)
    if r > 0
        z_inter = min(z_inter1,z_inter2);
    else
        z_inter = max(z_inter1,z_inter2);
    end
else
    return;
end

% remove ray if it is not hitting the real side of the sphere
if (r > 0 && z_inter > zc) || (r < 0  && z_inter < zc)
    return
end

xout = tx*z_inter+x0;
yout = ty*z_inter+y0;
zout = z_inter+z0;


% If outside of apature of element, remove ray from system
if (xout^2 + yout^2 > sd^2)
    zout = nan; xout = nan; yout = nan;
    return
end

% calculate angle out
alpha = atan(-xout/(r-z_inter+dz));
t1 = xt - alpha;
t2 = asin((n1/n2)*sin(t1));
xtout = t2+alpha;

alpha = atan(-yout/(r-z_inter+dz));
t1 = yt - alpha;
t2 = asin((n1/n2)*sin(t1));
ytout = t2+alpha;

if ~(isreal(xout) && isreal(yout) && isreal(xtout) && isreal(ytout))
    xout = nan; yout = nan;
    xtout = nan; ytout = nan;
end

end

