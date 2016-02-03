function [ img, xrange, yrange ] = rays2img2D( xout, yout, I, pixel_pitch, xrange, yrange )
%UNTITLED4 Summary of this function goes here

if ~exist('xrange', 'var')
    xmax = (floor(max(xout)/pixel_pitch)+1)*pixel_pitch;
    xmin = (floor(min(xout)/pixel_pitch))*pixel_pitch;
    ymax = (floor(max(yout)/pixel_pitch)+1)*pixel_pitch;
    ymin = (floor(min(yout)/pixel_pitch))*pixel_pitch;
    xrange = [xmin xmax]; yrange = [ymin ymax];
end

xout_real = xout(~isnan(xout) & ~isnan(yout));
yout_real = yout(~isnan(xout) & ~isnan(yout));
I = I(~isnan(xout) & ~isnan(yout));

% Determine number of spatial pixels
numPixX = floor((xrange(2)-xrange(1))/pixel_pitch);
numPixY = floor((yrange(2)-yrange(1))/pixel_pitch);

% Crop range if non-integer number of pixels
xrange(2) = xrange(1)+numPixX*pixel_pitch; 
yrange(2) = yrange(1)+numPixY*pixel_pitch;

% Initialize cell array
img = zeros(numPixX, numPixY);

% Iterate through all rays
for i = 1:numel(xout_real)
    
    % ray data
    x = xout_real(i); y = yout_real(i);
    
    % calculate spatial bin for given ray
    xpix = floor((x-xrange(1))/(pixel_pitch))+1; % location in array
    ypix = floor((y-yrange(1))/(pixel_pitch))+1;
    
    % increment space-angle bin if ray is in field of view
    if (xpix > 0 && xpix <= numPixX && ypix > 0 && ypix <= numPixY)
        img(xpix, ypix) = img(xpix, ypix) + I(i);
    end

end



end

