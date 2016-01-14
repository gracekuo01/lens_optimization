function [ xtheta_min, ytheta_min, xtheta_step, ytheta_step, xpos_min, ypos_min ] = ...
    getAngPosStep( i, j, k, l, pixel_pitch, numAngSensors, xrange, yrange,...
    semidiameter, si )
%UNTITLED15 Summary of this function goes here
%   xpix index = k
%   ypix index = l
%   i = xangle
%   j = yangle index

% calculate range of angles for that spatial bin
xmin = (k-1)*pixel_pitch+xrange(1); % smallest x in spatial bin
ymin = (l-1)*pixel_pitch+yrange(1); % smallest y in spatial bin
xtheta_range(1) = atan(-(xmin+pixel_pitch+semidiameter)/si);
xtheta_range(2) = atan(-(xmin-semidiameter)/si);
ytheta_range(1) = atan(-(ymin+pixel_pitch+semidiameter)/si);
ytheta_range(2) = atan(-(ymin-semidiameter)/si);

xtheta_step = (xtheta_range(2)-xtheta_range(1))/numAngSensors;
ytheta_step = (ytheta_range(2)-ytheta_range(1))/numAngSensors;

xtheta_min = xtheta_range(1)+(i-1)*xtheta_step;
ytheta_min = ytheta_range(1)+(j-1)*ytheta_step;

xpos_min = (k-1)*pixel_pitch+xrange(1); % smallest x in spatial bin
ypos_min = (l-1)*pixel_pitch+yrange(1); % smallest y in spatial bin


end

