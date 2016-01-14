function [ xout, xtout, yout, ytout, zout ] = traceRay_lensletArray( ...
    x0, y0, z0, xt, yt, f_lenslets, z_lenslets, pixel_pitch)
%[ xout, xtout, yout, ytout, zout ] = traceRay_lensletArray( ...
%   x0, y0, z0, xt, yt, f_lenslets, z_lenslets, pixel_pitch)
%
% Traces a ray specified by (x0, y0, z0, xt, yt) throught the lenset array
% specified by (f_lenslets, z_lenslets, pixel_pitch, numAngSensors)
%
% Inputs:
%   x0, y0, z0 - initial x, y, and z positions of ray
%   xt, yt - initial x and y angles of ray
%   f_lenslets  - focal length of lenslet array (ideal)
%   z_lenslets  - z position of lenslet array
%   pixel_pitch - size in mm of one side of square lenslet
%
% Outputs
%   xout, xtout - final x position and final x angle
%   yout, ytout - final y position and final y angle
%   zout - final z position
%
%   Output will be nan if the ray starts to the right of the lenslet array
%   (this means previous surface overlaps with lenslet array).
%
% This code assumes the lenslet array continues infinitely with the corner
% of the first lenslet located at (0,0).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If ray begins to right of lenslet array, return nan
if (z0 > z_lenslets)
    xout = nan; xtout = nan;
    yout = nan; ytout = nan;
    zout = nan;
    return
end

% Propegate ray to lenslet array
zout = z_lenslets;
xout = tan(xt)*(z_lenslets-z0)+x0;
yout = tan(yt)*(z_lenslets-z0)+y0;

% Determine where on lenslet ray hits
x_lenslet = mod(xout, pixel_pitch) - pixel_pitch/2;
y_lenslet = mod(yout, pixel_pitch) - pixel_pitch/2;

% Use ideal lens to determine how ray propegates through lenslet array
xtout = [-1/f_lenslets 1]*[x_lenslet; xt];
ytout = [-1/f_lenslets 1]*[y_lenslet; yt];


end

