function [ h ] = viz_cameraWithRay( camera, x0, y0, xt, yt, fwdstr, h )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here

if nargin > 6
    viz_camera(camera, h);
else
    viz_camera(camera);
end

hold on
for i = 1:numel(x0)
    if strcmp(fwdstr, 'fwd')
        [ xout, yout, zout ] = viz_traceRayForward( x0(i), y0(i), xt(i), yt(i), camera );
    elseif strcmp(fwdstr, 'bwd')
        [ xout, yout, zout ] = viz_traceRayBackward( x0(i), y0(i), xt(i), yt(i), camera );
    else
        error('String must be either "fwd" or "bwd"');
    end
    plot(zout, xout);
end

hold off

end

