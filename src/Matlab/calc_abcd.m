function [ ABCD ] = calc_abcd( camera )
%[ abcd ] = calc_abcd( camera )
%   Calculate ABCD matrix INCLUDING initial and final propegation distances

ABCD = eye(2);
for i = 2:numel(camera)
    d = camera(i-1).d;
    R = camera(i).R;
    n1 = camera(i-1).n;
    n2 = camera(i).n;
    ABCD = [1 0; (n1-n2)/(R*n2) (n1/n2)]*[1 d; 0 1]*ABCD;  
end

d = camera(end).d;
ABCD = [1 d; 0 1]*ABCD;


end

