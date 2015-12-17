function [ xpos, ypos ] = getPosition( pixel_pitch,...
    numAngSensors, xrange, yrange, semidiameter, si  )
%[ xpos, ypos ] = getAngles( pixel_pitch, numAngSensors, xrange, yrange,
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
%   xpos - cell array containing the minimum position in the x direction
%       for each space-angle bin
%   yoos - same as xpos in y direction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine number of spatial pixels
numPixX = round((xrange(2)-xrange(1))/pixel_pitch);
numPixY = round((yrange(2)-yrange(1))/pixel_pitch);

% Crop range if non-integer number of pixels
xrange(2) = xrange(1)+numPixX*pixel_pitch; 
yrange(2) = yrange(1)+numPixY*pixel_pitch;

% Initialize outputs
xpos = repmat({zeros(numAngSensors)}, numPixX, numPixY);
ypos = repmat({zeros(numAngSensors)}, numPixX, numPixY);

% Iterate through all spatial pixels
for xpix = 1:numPixX
    for ypix = 1:numPixY
        
        % calculate range of angles for that spatial bin
        xmin = (xpix-1)*pixel_pitch+xrange(1); % smallest x in spatial bin
        ymin = (ypix-1)*pixel_pitch+yrange(1); % smallest y in spatial bin
        
        xpos{xpix,ypix} = xmin*ones(numAngSensors);
        ypos{xpix,ypix} = ymin*ones(numAngSensors);
        
    end
end


end

