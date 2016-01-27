function [ xout, xtout, yout, ytout ] = traceRayBackward_withLenslets(...
    x0, y0, xt, yt, camera, f_lenslets, pixel_pitch )
%[ xout, xtout, yout, ytout ] = traceRayBackward_withLenslets(...
%    x0, y0, xt, yt, camera, f_lenslets, pixel_pitch )
%
%   Trace ray from image plane through through lenslets then trhough camera
%   (backwards) to object plane.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Trace to and through lenslet array (assumed to be f_lenslet away from
% sensor plane)
[x, xt, y, yt, zout ] = traceRay_lensletArray(x0, y0, 0, xt, yt,...
    f_lenslets, f_lenslets, pixel_pitch);

% Trace through camera backwards
[xout, xtout, yout, ytout] = traceRayBackward(x, y, xt, yt, camera);

end

