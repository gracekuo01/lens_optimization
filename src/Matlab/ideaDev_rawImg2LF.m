%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Raw Image to Light Field
%
% Testing different ideas
% (Can load the smile 01-14 data for testing)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample first, then cut up
oldSamplePeriod = pixel_pitch/numAngSensors;
newSamplePeriod = pixel_pitch*((pixel_pitch/(2*12))+1)/numAngSensors;
x = xrange(1):oldSamplePeriod:(xrange(2)-oldSamplePeriod);
y = yrange(1):oldSamplePeriod:(yrange(2)-oldSamplePeriod);
xq = x*(newSamplePeriod/oldSamplePeriod);
yq = y*(newSamplePeriod/oldSamplePeriod);
[X, Y]= meshgrid(x,y);
[Xq, Yq]= meshgrid(xq, yq);

resampled = interp2(X,Y, rawimg, Xq, Yq);

numPixX = (xrange(2)-xrange(1))/pixel_pitch;
numPixY = (yrange(2)-yrange(1))/pixel_pitch;
LF = zeros(numAngSensors, numAngSensors, numPixX, numPixY);
for ii = 1:size(rawimg, 1)
    for jj = 1:size(rawimg, 2)
        i = mod(ii-1, numAngSensors) + 1;
        j = mod(jj-1, numAngSensors) + 1;
        k = floor((ii-1)/numAngSensors) + 1;
        l = floor((jj-1)/numAngSensors) + 1;
        LF(i,j,k,l) = resampled(ii,jj);
    end
end
%%
nativeFocalPlane = squeeze(sum(sum(LF,1),2));
figure; imshow(nativeFocalPlane/max(max(nativeFocalPlane)));
%%
% Try running monte carlo correction
sd = camera(end).sd;
si = camera(end).d;
n = 3;

clear camera2
camera2(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera2(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd);
camera2(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera2, r2] = calc_lastr(camera2, EFL); % set last radius of curvature, r4
[camera2, d2] = calc_lastd(camera2);      % set distance to image plane, d4
ABCD_parax = calc_abcd(camera2);
ABCD_parax(1,2) = 0; % enforce imaging condition


[ corrected_rawimg] = monteCarloCorrection_bruteForce(...
    rawimg, camera, xrange, yrange, pixel_pitch, numAngSensors, f_lenslets, ABCD_parax, n);
figure; imshow(corrected_rawimg/max(max(corrected_rawimg)));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resample first, then cut up
oldSamplePeriod = pixel_pitch/numAngSensors;
newSamplePeriod = pixel_pitch*((pixel_pitch/(2*12))+1)/numAngSensors;
x = xrange(1):oldSamplePeriod:(xrange(2)-oldSamplePeriod);
y = yrange(1):oldSamplePeriod:(yrange(2)-oldSamplePeriod);
xq = x*(newSamplePeriod/oldSamplePeriod);
yq = y*(newSamplePeriod/oldSamplePeriod);
[X, Y]= meshgrid(x,y);
[Xq, Yq]= meshgrid(xq, yq);

resampled_corr = interp2(X,Y, corrected_rawimg, Xq, Yq);

numPixX = (xrange(2)-xrange(1))/pixel_pitch;
numPixY = (yrange(2)-yrange(1))/pixel_pitch;
LF_corr = zeros(numAngSensors, numAngSensors, numPixX, numPixY);
for ii = 1:size(rawimg, 1)
    for jj = 1:size(rawimg, 2)
        i = mod(ii-1, numAngSensors) + 1;
        j = mod(jj-1, numAngSensors) + 1;
        k = floor((ii-1)/numAngSensors) + 1;
        l = floor((jj-1)/numAngSensors) + 1;
        LF_corr(i,j,k,l) = resampled_corr(ii,jj);
    end
end

nativeFocalPlane_corr = squeeze(sum(sum(LF_corr,1),2));
figure; imshow(nativeFocalPlane_corr/max(max(nativeFocalPlane_corr)));


%%
% subaperature images
subap_img = zeros(size(LF,3)*size(LF,1), size(LF,4)*size(LF,2));
for ii = 1:size(LF,1)
    for jj = 1:size(LF, 2)
        for kk = 1:size(LF,3)
            for ll = 1:size(LF,4)
                subap_indx = (ii-1)*numPixX+kk;
                subap_indy = (jj-1)*numPixY+ll;
                subap_img(subap_indx, subap_indy) = LF(ii, jj, kk, ll);
            end
        end
    end
end
figure; imshow(subap_img/(max(max(subap_img))));
        
