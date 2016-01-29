function [ xinter, zinter ] = calc_circleInt( zc1, R1, zc2, R2 )
%[ xinter, zinter ] = calc_circleInt( zc1, R1, zc2, R2 )
%   Find the positive intersect of two circles with centers on the z axis
%   Inputs:
%       zc1, R1 - z coordinate of center and radius of circle 1
%       zc2, R2 - z coordinate of center and radius of circle 2
%   Outputs:
%       xinter, zinter - coordinates (x,z) of intercept
%       output nan if they do no intersect
%       also outputs nan if the circles are on top of each other

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if R1 == inf
    if R2 == inf
        xinter = nan; zinter = nan;
        return
    end
    zinter = zc1;
    xinter = sqrt( R2^2  - (zinter-zc2)^2 );
    
elseif R2 == inf
    zinter = zc2;
    xinter = sqrt( R1^2  - (zinter-zc1)^2 );
    
else
    zinter = -(R1^2 - R2^2 - zc1^2 + zc2^2)/(2*zc1 - 2*zc2);
    xinter = sqrt( R1^2  - (zinter-zc1)^2 );
    
end

if imag(xinter) ~= 0
    xinter = nan; zinter = nan;
end

end

