function [ correctedRawImg, xout, yout, weights ] = monteCarloCorrection_bruteForce( rawimg,...
    camera, xrange, yrange, pixel_pitch, numAngSensors, f_lenslets, ABCD_parax, N)
%[ correctedRawImg, xout, yout ] = monteCarloCorrection_bruteForce( rawimg,...
%   camera, xrange, yrange, pixel_pitch, numAngSensors, f_lenslets, ABCD_parax, N)
%
%   Iterate over all nonzero pixels in raw image
%       1. Determine which microlens array the given pixel is under
%       2. Send out N random rays distributed over the microlens and pixel
%       3. Trace through microlenses and then through camera
%       4. Trace back through paraxial system (ABCD_parax)
%       5. Trace though microlenses to get new (corrected) ray light field
%
% TO DO: Modify so that when N = 1 the ray is not random. Want it to be the
% center ray of ray bundle
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display_period = 100000; % set how often something is displayed in console

I_nonzero = find(rawimg ~= 0);
[k, l] = ind2sub(size(rawimg), I_nonzero);
correctedRawImg = zeros(size(rawimg));

if nargout == 4
    xout = zeros(numel(I_nonzero)*N); yout = xout;
    weights = xout;
end

count = 1;

for i = 1:numel(I_nonzero)
     if mod(i,display_period)==1
        disp(['Percent complete: ' num2str((i/numel(I_nonzero))*100)]);
        tic
    end
    % Determine real pixel location (minimum edge)
    x_pos_min = (k(i)-1)*(pixel_pitch/numAngSensors) + xrange(1);
    y_pos_min = (l(i)-1)*(pixel_pitch/numAngSensors) + yrange(1);
    
    % Determine location of corresponding microlens
    d = camera(end).d;
    circle_spacing = ((pixel_pitch*f_lenslets)/d)+pixel_pitch;
    lenslet_num_x = floor(x_pos_min/circle_spacing);
    lenslet_num_y = floor(y_pos_min/circle_spacing);
    lenslet_min_x = lenslet_num_x*pixel_pitch;
    lenslet_min_y = lenslet_num_y*pixel_pitch;
    
    % Throw N rays randomly distributed over pixel and microlens
    % If N == 1, only throw center ray (maybe) (TO DO)
    rand_x = rand(N,1)*(pixel_pitch/numAngSensors) + x_pos_min;
    rand_y = rand(N,1)*(pixel_pitch/numAngSensors) + y_pos_min;
    rand_u = rand(N,1)*pixel_pitch + lenslet_min_x;
    rand_v = rand(N,1)*pixel_pitch + lenslet_min_y;
    rand_xt = atan((rand_u - rand_x)/f_lenslets);
    rand_yt = atan((rand_v - rand_y)/f_lenslets);
    
    % Trace those rays out and back(including through microlenses, which
    % were ideal
    for j = 1:N
        % Trace to and through lenslet array and backwards throug camera
        [x, xt, y, yt] = traceRayBackward_withLenslets(rand_x(j), rand_y(j),...
            rand_xt(j), rand_yt(j), camera, f_lenslets, pixel_pitch);
        
        % Trace Ray forward with paraxial model
        xcorr = ABCD_parax*[x; -xt];
        ycorr = ABCD_parax*[y; -yt];
        
        % Trace through lenslet model
        [x, xt, y, yt, zout ] = traceRay_lensletArray(xcorr(1), ycorr(1),...
            0, xcorr(2), ycorr(2), f_lenslets, 0, pixel_pitch);
        
        % Trace to sensor
        xout_s = tan(xt)*(f_lenslets)+x;
        yout_s= tan(yt)*(f_lenslets)+y;
        
        % Place in appropriate pixel
        % Check ray is in field of view
        if ~(xout_s > xrange(2) || xout_s <= xrange(1) || yout_s > yrange(2) || yout_s <= yrange(1) || ...
                isnan(xout_s) || isinf(xout_s) || isinf(yout_s))
            % Determine pixel location
            pixX = floor((xout_s-xrange(1))/(pixel_pitch/numAngSensors))+1;
            pixY = floor((yout_s-yrange(1))/(pixel_pitch/numAngSensors))+1;
            % Increment that bin
            correctedRawImg(pixX, pixY) = correctedRawImg(pixX, pixY) + rawimg(I_nonzero(i))/N;
            if nargout == 4
                xout(count) = xout_s; yout(count) = yout_s;
                weights(count) = rawimg(I_nonzero(i))/N;
                count = count + 1;
            end
        end
    end
        
    if mod(i,display_period)==0
        toc
    end
    
end


end

