function [ rawimg ] = simulateScene( camera, pixel_pitch, numAngSensors,...
    f_lenslets, xrange, yrange, source_file, xrange_source, yrange_source, N, rawimg )
%[ rawimg ] = simulateScene( camera, pixel_pitch, numAngSensors,...
%    xrange, yrange, source_file, xrange_source, yrange_source )
%   Simulate a scene through the given camera
%
%   source_file - file name and path of input image to simulate
%   xrange_source, yrange_source - extent of input image file (image is
%       located at the object plane of the camera)
%   N - total number of rays to trace. Rays are chosen randomly across
%       source image and entrance pupil

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load source image, convert to black and white
truth_img = rgb2gray(imread(source_file));
truth_img = double(truth_img)/double(max(max(truth_img)));


N_maxperiter = 25000000; % maximum size of arrays to allow (if N is larger,
% the rays are broken up into chunks of this size)

display_period = round(N/100); % display progress ever 1%

if nargin < 11
    % initalize raw image
    ImgSize(1) = (xrange(2) - xrange(1)) / (pixel_pitch/numAngSensors);
    ImgSize(2) = (yrange(2) - yrange(1)) / (pixel_pitch/numAngSensors);
    rawimg = zeros(ImgSize);
end

pupil_radius = camera(end).sd;
dist_to_pupil = camera(end).d;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_inner = mod(N, N_maxperiter);     % number of rays in last inner loop
n_outer = floor(N/N_maxperiter)+1;  % number of outer loops
N_total = N;

for j = 1:n_outer
    if j == n_outer
        N = n_inner;
    else
        N = N_maxperiter;
    end
    
    
    x_ind_rand = (rand(N,1)*(size(truth_img, 1)-1))+1;
    y_ind_rand = (rand(N,1)*(size(truth_img, 2)-1))+1;
    x_rand = (x_ind_rand - size(truth_img, 1)/2)*(xrange_source(2)/(size(truth_img, 1)/2));
    y_rand = (y_ind_rand - size(truth_img, 2)/2)*(yrange_source(2)/(size(truth_img, 2)/2));
    x_ind_rand = round(x_ind_rand);
    y_ind_rand = round(y_ind_rand);
    
    Ns = round(1.28*N + 2.5*sqrt(N) + 100);
    x_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
    y_pupil_rand = (rand(Ns,1)*2-1)*pupil_radius;
    I = find(sqrt(x_pupil_rand.^2+y_pupil_rand.^2)<=pupil_radius);
    x_pupil_rand = x_pupil_rand(I(1:N));
    y_pupil_rand = y_pupil_rand(I(1:N));
    
    xt_rand = atan((x_pupil_rand - x_rand)/dist_to_pupil);
    yt_rand = atan((y_pupil_rand - y_rand)/dist_to_pupil);
    
    for i = 1:N
        if (mod((i+(j-1)*N_maxperiter), display_period) == 1)
            tic
        end
        I = truth_img(x_ind_rand(i), y_ind_rand(i));
        if (I ~= 0)
            
            % Trace ray forward
            [ xout, xtout, yout, ytout ] = traceRayForward_withLenslets(...
                x_rand(i), y_rand(i), xt_rand(i), yt_rand(i), camera,...
                f_lenslets, pixel_pitch );
            
            % Check ray is in field of view
            if ~(xout > xrange(2) || xout <= xrange(1) || yout > yrange(2) || yout <= yrange(1) || ...
                    isnan(xout) || isinf(xout) || isinf(yout))
                % Determine pixel location
                pixX = floor((xout-xrange(1))/(pixel_pitch/numAngSensors))+1;
                pixY = floor((yout-yrange(1))/(pixel_pitch/numAngSensors))+1;
                % Increment that bin
                rawimg(pixX, pixY) = rawimg(pixX, pixY) + I;
            end
            
        end
        
        if (mod((i+(j-1)*N_maxperiter), display_period) == 0)
            disp(['Percent complete: ' num2str(((i+(j-1)*N_maxperiter)/N_total)*100)])
            toc
        end
    end
end


end

