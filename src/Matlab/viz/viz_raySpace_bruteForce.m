function [ hout ] = viz_raySpace_bruteForce( camera, xrange, pixel_pitch,...
    numAngSensors, f_lenslets, ABCD_parax, N, h )
%[ hout ] = viz_raySpace_bruteForce( camera, xrange, pixel_pitch,...
%    numAngSensors, ABCD_parax, N, h )
%   Draw ray space plots in new figure or given axes handle
%
%   Drawn by tracing N rays from the pixels in flatland through
%   microlenses, through camera and back. Then the boundary of the shape is
%   drawn.
%
%   N - number of rays traced per pixel
%   h - (optional) axes handle to put plot in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin >= 8
    axes(h);
else
    h = figure;
end

if nargout > 0
    hout = h;
end

if N < 3
    error('N must be at least 3');
end

hold on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

real_pix_size = (pixel_pitch/numAngSensors);
lw = 1; % linewidth of plot

% microlens circle properties
d = camera(end).d;
circle_spacing = ((pixel_pitch*f_lenslets)/d)+pixel_pitch;

% Determine number of pixels and pixel locations
x_pos_range(1) = floor( xrange(1)/real_pix_size ) * real_pix_size;
x_pos_range(2) = (ceil( xrange(2)/real_pix_size ) - 1) * real_pix_size;
numPix = round((x_pos_range(2) - x_pos_range(1)) / real_pix_size) + 1;

% Iterate over all pixels
for i = 1:numPix
    % This pixel's location
    x_pos_min = x_pos_range(1) + (i-1)*real_pix_size;
    
    % Determine which microlens pixel is under
    lenslet_num_x = floor(x_pos_min/circle_spacing);
    lenslet_min_x = lenslet_num_x*pixel_pitch;

    % Throw N rays distributed over pixel and microlens
    rand_x = rand(N,1)*(pixel_pitch/numAngSensors) + x_pos_min;
    rand_u = rand(N,1)*pixel_pitch + lenslet_min_x;
    rand_xt = atan((rand_u - rand_x)/f_lenslets);
    
    xout = zeros(N,1);
    uout = zeros(N,1);
    
    % Trace backwards through microlenses then through camera
    for j = 1:N
        % Trace to and through lenslet array and backwards throug camera
        [x, xt, y, yt] = traceRayBackward_withLenslets(rand_x(j), pixel_pitch/2,...
            rand_xt(j), 0, camera, f_lenslets, pixel_pitch);
        
        % Trace Ray forward with paraxial model
        xcorr = ABCD_parax*[x; -xt];
        
        % Think of incoming (corrected) ray as (x,u) coordinates: 
        % calculate u from xt
        xout(j) = xcorr(1);
        uout(j) = d*tan(-xcorr(2))+xcorr(1);
    end
    
    % Remove nan rays
    xout_final = xout(~isnan(xout));
    uout_final = uout(~isnan(xout));
    
    % Get boundary of all (x,u) pairs and add to plot
    if numel(xout_final) >= 3
        hull = boundary(xout_final, uout_final, .2);
        plot(xout_final(hull), uout_final(hull), 'k', 'linewidth', lw);
    end


end
hold off


end

