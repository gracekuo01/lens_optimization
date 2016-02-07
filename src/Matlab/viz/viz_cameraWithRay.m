function [ hout ] = viz_cameraWithRay( camera, x0, y0, xt, yt, fwdstr, h )
%[ hout ] = viz_cameraWithRay( camera, x0, y0, xt, yt, fwdstr, h )
%   Display camera with specified rays drawn
%
% viz_cameraWithRay( camera )
%   Display camera with default ray drawn. Default starts at (0,0) and
%   extends to 90% of the semidiamter of the first camera element (traced
%   forward).
%
%   Inputs:
%       camera - array of structures with fields (R, n, d, sd). Each
%           element of array represents a surface
%       x0, y0, xt, yt - initial positions and angle of rays. These can
%           either be scalars or vectors of the same length (for multiple
%           rays)
%       fwdstr - either 'fwd' or 'bwd' to trace ray forward or backwards.
%           * 'fwd' means the intial positions are on the object plane and
%              the intial angles are pointed from the object plane to the
%              sensor plane
%           * 'bwd' means the intial positions are on the sensor plane and
%              the intial angles are pointed from the sensor plane to the
%              object plane
%       h - (optional) handle of axes to plot in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    x0 = 0; y0 = 0; yt = 0;
    xt = atan((0.9 * camera(2).sd)/camera(1).d);
    fwdstr = 'fwd';
end    

if nargin > 6
    h = viz_cameraComplete(camera, h);
else
    h = viz_cameraComplete(camera);
end

if nargout > 0
    hout = h;
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

