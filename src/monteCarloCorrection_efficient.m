function [ corrected_img, xout, yout, xtout, ytout, weights] = monteCarloCorrection_efficient( binned_data, pixel_pitch,...
    numAngSensors, xrange, yrange, semidiameter, si, N, camera, ABCD_parax)
%[ corrected_img ] = monteCarloCorrection( binned_data, pixel_pitch,
%    numAngSensors, xrange, yrange, semidiameter, si  )
%   N - number of rays in monte carlo

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I_nonzero  = find(binned_data ~= 0);
[lfi, lfj, lfk, lfl] = ind2sub(size(binned_data), I_nonzero);

corrected_img = zeros(size(binned_data,3), size(binned_data,4));
xout = zeros(1,N*numel(I_nonzero));
xtout = xout; yout = xout; ytout = xout; weights = xout;
count = 1;

for i = 1:numel(I_nonzero)
    
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
                corrected_img(xpix, ypix) + (1/(N*binned_data(I_nonzero(i))));
        end
        
        count = count + 1;
        
    end
end




end

