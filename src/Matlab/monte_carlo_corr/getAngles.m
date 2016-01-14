function [ xtheta_min, ytheta_min, xtheta_step, ytheta_step ] = ...
    getAngles( pixel_pitch, numAngSensors, xrange, yrange,...
    semidiameter, si )
%[ xtheta_min, ytheta_min, xtheta_step, ytheta_step ] = 
%    getAngles( pixel_pitch, numAngSensors, xrange, yrange,
%    semidiameter, si )
%
% Inputs:
%  pixel_pitch - size of spatial pixel (mm)
%   numAngSensors - number of angle sensors in one dimension (per spatial
%           pixel)
%   xrange - vector [xmin xmax] of image plane (mm)
%   yrange - vector [ymin ymax] of image plane (mm)
%   semidiameter - exit pupil semidiameter (mm)
%   si - distance from exit pupil to image plane (mm)
%
% Outputs:
%   xtheta_min - cell array containing the minimum angle in the x direction
%       for each space-angle bin
%   ytheta_min - same as xtheta_min in y direction
%   xtheta_step - array with number of spatial pixel, each element is the
%       angular step size in x for that spatial pixel
%   ytheta_step - same as xtheta_step in y direction
%
% Angles are for a ray emitted from the sensor towards the exit pupil

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine number of spatial pixels
numPixX = floor((xrange(2)-xrange(1))/pixel_pitch);
numPixY = floor((yrange(2)-yrange(1))/pixel_pitch);

% Crop range if non-integer number of pixels
xrange(2) = xrange(1)+numPixX*pixel_pitch; 
yrange(2) = yrange(1)+numPixY*pixel_pitch;

% Initialize outputs
xtheta_min = repmat({zeros(numAngSensors)}, numPixX, numPixY);
ytheta_min = repmat({zeros(numAngSensors)}, numPixX, numPixY);
xtheta_step = zeros(numPixX, numPixY);
ytheta_step = zeros(numPixX, numPixY);

% Iterate through all spatial pixels
for xpix = 1:numPixX
    for ypix = 1:numPixY
        
        % calculate range of angles for that spatial bin
        xmin = (xpix-1)*pixel_pitch+xrange(1); % smallest x in spatial bin
        ymin = (ypix-1)*pixel_pitch+yrange(1); % smallest y in spatial bin
        xtheta_range(1) = atan(-(xmin+pixel_pitch+semidiameter)/si);
        xtheta_range(2) = atan(-(xmin-semidiameter)/si);
        ytheta_range(1) = atan(-(ymin+pixel_pitch+semidiameter)/si);
        ytheta_range(2) = atan(-(ymin-semidiameter)/si);
        
        % calculate angle spacing in each direction
        xstep = (xtheta_range(2)-xtheta_range(1))/numAngSensors;
        ystep = (ytheta_range(2)-ytheta_range(1))/numAngSensors;
        
        % fill in outputs (x - rows, y- columns)
        xtheta_step(xpix,ypix) = xstep;
        ytheta_step(xpix,ypix) = ystep;
        
        xtheta_min{xpix,ypix} = repmat(...
            (xtheta_range(1):xstep:xtheta_range(2)-xstep)',...
            [1 numAngSensors]);
        ytheta_min{xpix,ypix} = repmat(...
            (ytheta_range(1):ystep:ytheta_range(2)-ystep),...
            [numAngSensors 1]);
        
    end
end


end

