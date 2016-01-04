function [ EFL ] = calc_efl( camera )
%[ elf ] = calc_efl( camera )
%   Calculate first order effective focal length (EFL)

ABCD = calc_abcd(camera);
EFL = -1/(ABCD(2,1));

end

