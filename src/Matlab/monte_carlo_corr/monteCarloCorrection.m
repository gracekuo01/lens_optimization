function [ corrected_img, xout, yout, xtout, ytout] = monteCarloCorrection( binned_data, pixel_pitch,...
    numAngSensors, xrange, yrange, semidiameter, si, N, camera, ABCD_parax)
%[ corrected_img ] = monteCarloCorrection( binned_data, pixel_pitch,
%    numAngSensors, xrange, yrange, semidiameter, si  )
%
% OBSOLETE: VERY SLOW
%
%   N - number of rays in monte carlo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
[xtheta_min, ytheta_min, xtheta_step, ytheta_step] = ...
    getAngles(pixel_pitch, numAngSensors, xrange, yrange, semidiameter, si);
[xpos_min, ypos_min] = getPosition(pixel_pitch, numAngSensors, xrange, yrange,...
    semidiameter, si);
disp('Get angles and positions:')
toc
tic

binned_matrix = cell2mat(binned_data);
xpos_min = cell2mat(xpos_min);
ypos_min = cell2mat(ypos_min);
xtheta_min = cell2mat(xtheta_min);
ytheta_min = cell2mat(ytheta_min);
xtheta_step = repelem(xtheta_step, numAngSensors, numAngSensors);
ytheta_step = repelem(ytheta_step, numAngSensors, numAngSensors);

disp('Convert cell arrays to arrays:')
toc
tic

I_nonzero  = find(binned_matrix ~= 0);

corrected_img = zeros(size(binned_data));
xout = zeros(1,N*numel(I_nonzero));
xtout = xout; yout = xout; ytout = xout;
count = 1;

for i = 1:numel(I_nonzero)
    xpos_rand = rand(N,1)*pixel_pitch+xpos_min(I_nonzero(i));
    ypos_rand = rand(N,1)*pixel_pitch+ypos_min(I_nonzero(i));
    xtheta_rand = rand(N,1)*xtheta_step(I_nonzero(i))+ xtheta_min(I_nonzero(i));
    ytheta_rand = rand(N,1)*ytheta_step(I_nonzero(i))+ ytheta_min(I_nonzero(i));
    
    
    % Paraxial system traced forwards
    ABCD_fwd_parx = ABCD_parax;

    % Trace each ray through system and back
    for j = 1:N
        [ xo, xto, yo, yto ] = traceRayBackward( xpos_rand(j),...
            ypos_rand(j), xtheta_rand(j), ytheta_rand(j), camera );
        xcorr = ABCD_fwd_parx*[xo; -xto];
        ycorr = ABCD_fwd_parx*[yo; -yto];
        
        % determine spatial position of corrected ray
        xpix = floor((xcorr(1)-xrange(1))/(pixel_pitch))+1; % location in array
        ypix = floor((ycorr(1)-yrange(1))/(pixel_pitch))+1;
        
        xout(count) = xcorr(1); xtout(count) = xcorr(2);
        yout(count) = ycorr(1); ytout(count) = ycorr(2);
        
        % increment that pixel if ray is in field of view
        if (xpix > 0 && xpix <= size(binned_data,1) && ypix > 0 &&...
                ypix <= size(binned_data,2))
            corrected_img(xpix, ypix) = ...
                corrected_img(xpix, ypix) + (1/(N*numel(I_nonzero)));
        end
        
        count = count + 1;
        
    end
end

disp('trace rays out and back (actual correction):')
toc

end

