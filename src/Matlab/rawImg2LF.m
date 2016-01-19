function [ LF ] = rawImg2LF( rawimg, camera, xrange, yrange,...
    pixel_pitch, numAngSensors, f_lenslets)
%[ LF ] = rawImg2LF( rawimg, camera, xrange, yrange,...
%    pixel_pitch, numAngSensors, f_lenslets)
%
%   Convert raw sensor image to 4D Light Field. Using the geometry of the
%   image side of the camera, I calculate the theoretical spacing of the
%   centers of the circles in the raw image. Then the raw image is
%   resampled such that each circle has numAngSensors pixels. Finally, the
%   raw image is "cut up" and rearranged in 4D matrix.
%
%   Inputs:
%       rawimg - raw sensor image
%       camera - array of structures with fields (R, n, d, sd). Each
%           element of array represents a surface.
%           * note the only part of this being used is the distance from
%           * the last lens to the image plane
%       xrange, yrange - two element vector with the minimum and maximum
%           range in each direction (mm)
%       pixel_pitch - size of one side of each square microlens (mm)
%       f_lenslets - focal length of the microlenses (mm)
%
%    Outputs:
%       LF - 4D light field (i,j,l,k)
%           First two dimensions are angular (i = x angle, j = y angle)
%           Last two dimensions are spatial (l = x spatial, k = y spatial)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine new sampling period
d = camera(end).d;
oldSamplePeriod = pixel_pitch/numAngSensors;
newSamplePeriod = pixel_pitch*(f_lenslets/d + 1)/numAngSensors;
x = xrange(1):oldSamplePeriod:(xrange(2)-oldSamplePeriod);
y = yrange(1):oldSamplePeriod:(yrange(2)-oldSamplePeriod);
xq = x*(newSamplePeriod/oldSamplePeriod);
yq = y*(newSamplePeriod/oldSamplePeriod);
[X, Y]= meshgrid(x,y);
[Xq, Yq]= meshgrid(xq, yq);

% Resample raw image such that each circle has integer number of pixels
resampled = interp2(X,Y, rawimg, Xq, Yq, 'linear', 0);

% Rearrange into 4D Light Field
numPixX = (xrange(2)-xrange(1))/pixel_pitch;
numPixY = (yrange(2)-yrange(1))/pixel_pitch;
LF = zeros(numAngSensors, numAngSensors, numPixX, numPixY);
for ii = 1:size(rawimg, 1)
    for jj = 1:size(rawimg, 2)
        i = mod(ii-1, numAngSensors) + 1;
        j = mod(jj-1, numAngSensors) + 1;
        k = floor((ii-1)/numAngSensors) + 1;
        l = floor((jj-1)/numAngSensors) + 1;
        LF(i,j,k,l) = resampled(ii,jj);
    end
end

end

