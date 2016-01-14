function [ data_binned ] = binData( data, pixel_pitch,...
    numAngSensors, xrange, yrange, semidiameter, si )
%binData( data, pixel_pitch,numAngSensors, xrange, yrange, 
%   semidiameter, si )
%
% Inputs:
%   data -  matrix Nx4 where N is number of rays
%           columns are x, y, theta x, theta y (mm, radians)
%   pixel_pitch - size of spatial pixel (mm)
%   numAngSensors - number of angle sensors in one dimension (per spatial
%           pixel)
%   xrange - vector [xmin xmax] of image plane (mm)
%   yrange - vector [ymin ymax] of image plane (mm)
%   semidiameter - exit pupil semidiameter (mm)
%   si - distance from exit pupil to image plane (mm)
%
% Output:
%   data_binned - cell array of matricies size numAngSensors^2
%           each cell represents a spatial pixel and the interior matrix
%           contains the intesity at each angle bin within that spatial
%           pixel
%
% If the pixel_pitch does not evenly divide the field of view, the field of
% view will be cropped.
% Angles are for a ray emitted from the sensor towards the exit pupil

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine number of spatial pixels
numPixX = floor((xrange(2)-xrange(1))/pixel_pitch);
numPixY = floor((yrange(2)-yrange(1))/pixel_pitch);

% Crop range if non-integer number of pixels
xrange(2) = xrange(1)+numPixX*pixel_pitch; 
yrange(2) = yrange(1)+numPixY*pixel_pitch;

% Initialize cell array
data_binned = zeros(numAngSensors, numAngSensors, numPixX, numPixY);

% Iterate through all rays
for i = 1:size(data,1)
    
    % ray data
    x = data(i,1); y = data(i,2);
    xtheta = -data(i,3);
    ytheta = -data(i,4);
    
    % calculate spatial bin for given ray
    xpix = floor((x-xrange(1))/(pixel_pitch))+1; % location in array
    ypix = floor((y-yrange(1))/(pixel_pitch))+1;
    
    % calculate range of angles for that spatial bin
    xmin = (xpix-1)*pixel_pitch+xrange(1); % smallest x in spatial bin
    ymin = (ypix-1)*pixel_pitch+yrange(1); % smallest y in spatial bin
    xtheta_range(1) = atan(-(xmin+pixel_pitch+semidiameter)/si);
    xtheta_range(2) = atan(-(xmin-semidiameter)/si);
    ytheta_range(1) = atan(-(ymin+pixel_pitch+semidiameter)/si);
    ytheta_range(2) = atan(-(ymin-semidiameter)/si);
    
    % calculate angle spacing in each direction
    xtheta_step = (xtheta_range(2)-xtheta_range(1))/numAngSensors;
    ytheta_step = (ytheta_range(2)-ytheta_range(1))/numAngSensors;
    
    % determine which bin ray is in (location in array)
    xtheta_bin = floor((xtheta-xtheta_range(1))/(xtheta_step))+1;
    ytheta_bin = floor((ytheta-ytheta_range(1))/(ytheta_step))+1;
    
    % increment space-angle bin if ray is in field of view
    if (xpix > 0 && xpix <= numPixX && ypix > 0 && ypix <= numPixY && ...
            xtheta_bin > 0 && xtheta_bin <= numAngSensors && ...
            ytheta_bin > 0 && ytheta_bin <= numAngSensors)
        data_binned(xtheta_bin, ytheta_bin, xpix, ypix) = ...
            data_binned(xtheta_bin, ytheta_bin, xpix, ypix) + (1/size(data,1));
    end

end


end

