function [ rawImg ] = traceRay_sensor( x0, y0, z0, xt, yt, z_sensor,...
    pixel_pitch, numAngSensors, xrange, yrange, rawImg )
%[ rawImg ] = traceRay_sensor( x0, y0, z0, xt, yt, z_sensor,...
%    pixel_pitch, numAngSensors )
%
% Inputs:
%   x0, y0, z0 - initial x, y, and z positions of ray
%   xt, yt - initial x and y angles of ray
%   z_sensor  - z position of sensor
%   pixel_pitch - size in mm of one side of square lenslet
%   numAngSensors - number of real pixels within one lenslet
%   xrange, yrange - 2 element vector describing extent of sensor (mm)
%
%   Size of actual pixel is determined by the pixel_pitch and numAngSensors
%   (real pixel size = pixel_pitch/numAngSensors)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check that rawImg is correct size. Create blank rawImg if not given
expectedImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
expectedImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
if narin <= 10
    rawImg = zeros(expectedImgSize);
end
if size(rawImg, 1) ~= expectImgSize(1) || ...
        size(rawImg, 2) ~= expectedImgSize(2)
    error('Input raw image is not correct size');
end

% Propegate ray to sensor plane
xout = tan(xt)*(z_sensor-z0)+x0;
yout = tan(yt)*(z_sensor-z0)+y0;

% Determine pixel location
pixX = floor((xout-xrange(1))/(pixel_pitch/numAngSensors));
pixY = floor((yout-yrange(1))/(pixel_pitch/numAngSensors));

% Increment that bin
rawImg(pixX, pixY) = rawImg(pixX, pixY) + 1;


end

