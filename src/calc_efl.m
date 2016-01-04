function [ EFL ] = calc_efl( camera )
%[ elf ] = calc_efl( camera )
%   Calculate first order effective focal length (EFL)

ABCD = eye(2);
for i = 2:numel(camera)
    d = camera(i-1).d;
    R = camera(i).R;
    n1 = camera(i-1).n;
    n2 = camera(i).n;
    ABCD = [1 0; (n1-n2)/(R*n2) (n1/n2)]*[1 d; 0 1]*ABCD;  
end

%d = camera(end).d;
%ABCD = [1 d; 0 1]*ABCD; % note this is unneccessary because it does not effect EFL
EFL = -1/(ABCD(2,1));

end

