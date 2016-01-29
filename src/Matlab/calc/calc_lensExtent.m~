function [ zout ] = calc_lensExtent( z0, R, sd )
%[ zout ] = calc_lensExtent( z0, R, sd )
%   z-extent of lens after being chopped at sd plane
%   give z location of the outside edge of the surface

if isinf(R)
    zout = z0;
elseif sd >= abs(R)
    zout = z0+R;
else
    zc = z0+R;
    zout = zc - sign(R)*sqrt(R^2 - sd^2);
end


end

