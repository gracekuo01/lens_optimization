function [ corrected_img, xout, yout, xtout, ytout, weights] = ...
    monteCarloCorrection_efficient( binned_data, pixel_pitch,...
    numAngSensors, xrange, yrange, semidiameter, si, N, camera, ABCD_parax)
%[ corrected_img, xout, yout, xtout, ytout, weights] = ...
%    monteCarloCorrection_efficient( binned_data, pixel_pitch,...
%    numAngSensors, xrange, yrange, semidiameter, si, N, camera, ABCD_parax)
%
% NOTE: This is quite possibly wrong, especially when paired with the data
% from the lenslet array model.
%
%   Iterate over all nonzero pixels in binned_data (the light field).
%       1. Determine angular and spatial range of that pixel
%       2. Send out N random rays within that range of space and angle
%       3. Trace through camera
%       4. Trace back through paraxial camera (ABCD_parax)
%       5. Record position, angle, intensity, and which spatial bin the ray
%          lands in
%
%   Inputs:
%       binned_data - 4D light field matrix where the first two dimensions
%           are angular and the second two are spatial
%       pixel_pitch - size of one side of each square microlens (mm)
%       numAngSensors - number of angle sensors per lenslet
%       xrange, yrange - two element vector with the minimum and maximum
%           range in each direction (mm)
%       semidiameter - of exit pupil (or for ease, of the last element of
%           the camera) (mm)
%       si - distance from exit pupil to image sensor (or from last element
%           of camera to image sensor) (mm)
%       N - number of rays in monte carlo
%       camera - array of structures with fields (R, n, d, sd). Each
%           element of array represents a surface
%       ABCD_parax - ABCD matrix for ideal camera
%
%   Outputs:
%       corrected_img - 2D image (not 4D LF) after correction
%       xout, yout - x and y position of each ray traced (after correction)
%       xtout, ytout - x and y angle of each ray traced (after correction)
%       weights - intensity of each ray traced

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_period = 100000; % set how often something is displayed in console

I_nonzero  = find(binned_data ~= 0);
[lfi, lfj, lfk, lfl] = ind2sub(size(binned_data), I_nonzero);

corrected_img = zeros(size(binned_data,3), size(binned_data,4));
xout = zeros(1,N*numel(I_nonzero));
xtout = xout; yout = xout; ytout = xout; weights = xout;
count = 1;
numel(I_nonzero)
for i = 1:numel(I_nonzero)
    if mod(i,display_period)==1
        disp(['Percent complete: ' num2str((i/numel(I_nonzero))*100)]);
        tic
    end
    
    % Get appropriate angle, position, and step
    [ xtheta_min, ytheta_min, xtheta_step, ytheta_step, xpos_min, ypos_min ] = ...
        getAngPosStep( lfi(i), lfj(i), lfk(i), lfl(i), pixel_pitch, numAngSensors, xrange, yrange,...
        semidiameter, si );
    
    xpos_rand = rand(N,1)*pixel_pitch+xpos_min;
    ypos_rand = rand(N,1)*pixel_pitch+ypos_min;
    xtheta_rand = rand(N,1)*xtheta_step+ xtheta_min;
    ytheta_rand = rand(N,1)*ytheta_step+ ytheta_min;
    
    
    % Trace each ray through system and back
    for j = 1:N
        [ xo, xto, yo, yto ] = traceRayBackward( xpos_rand(j),...
            ypos_rand(j), xtheta_rand(j), ytheta_rand(j), camera );
        xcorr = ABCD_parax*[xo; -xto];
        ycorr = ABCD_parax*[yo; -yto];
        
        % determine spatial position of corrected ray
        xpix = floor((xcorr(1)-xrange(1))/(pixel_pitch))+1; % location in array
        ypix = floor((ycorr(1)-yrange(1))/(pixel_pitch))+1;
        
        xout(count) = xcorr(1); xtout(count) = xcorr(2);
        yout(count) = ycorr(1); ytout(count) = ycorr(2);
        weights(count) = binned_data(I_nonzero(i))/N;
        
        % increment that pixel if ray is in field of view
        if (xpix > 0 && xpix <= size(binned_data,3) && ypix > 0 &&...
                ypix <= size(binned_data,4))
            corrected_img(xpix, ypix) = ...
                corrected_img(xpix, ypix) + (binned_data(I_nonzero(i))/N);
        end
        
        count = count + 1;

    end
    
    if mod(i,display_period)==0
        toc
    end
    
end




end

