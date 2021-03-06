function [ rmse ] = calc_rmse( xout, yout, x_ideal, y_ideal, weights )
%[ rmse ] = calc_rmse( xout, yout, xin, yin )
%   Calculate rms error between (xout, yout) and the ideal position, 
%   (x_ideal, y_ideal)
%
% Inputs:
%   xout - vector of x positions
%   yout - vector of y positions
%   x_ideal - scalar, ideal x position
%   y_ideal - scalar, ideal y position

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xout_real = xout(~isnan(xout) & ~isnan(yout));
yout_real = yout(~isnan(xout) & ~isnan(yout));

if nargin <= 4
    weights = ones(size(xout_real));
else
    weights = weights(~isnan(xout) & ~isnan(yout));
end

if isempty(x_ideal) || isempty(y_ideal)
    x_ideal = mean(xout_real);
    y_ideal = mean(yout_real);
end

    
rmse = sqrt(mean(weights.*((xout_real - x_ideal*ones(size(xout_real))).^2 +...
    (yout_real - y_ideal*ones(size(xout_real))).^2)));

end

