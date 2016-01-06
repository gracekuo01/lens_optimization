function [ h ] = viz_cameraWithRay( camera, x0, y0, xt, yt, fwdstr, h )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

if nargin > 6
    viz_camera(camera, h);
else
    viz_camera(camera);
end

hold on

if strcmp(fwdstr, 'fwd')
    [ xout, yout, zout ] = viz_traceRayForward( x0, y0, xt, yt, camera );
elseif strcmp(fwdstr, 'bwd')
    [ xout, yout, zout ] = viz_traceRayBackward( x0, y0, xt, yt, camera );
else
    error('String must be either "fwd" or "bwd"');
end
plot(zout, xout);

hold off

end

