function [ camera, d ] = calc_lastd( camera )
%[ camera, d ] = calc_lastr( camera, EFL )
%   Calculate the distance from the last spherical element to the image
%   plane
%   Returns a new camera with the correct last distance

ABCD = calc_abcd(camera);
n1 = camera(1).n;
n2 = camera(end).n;
PF = (n1 - ABCD(2,2)*n2)/(n2*ABCD(2,1)); % front principle plane
PB = (1 - ABCD(1,1))/(ABCD(2,1));        % back principle plane
EFL = calc_efl(camera);
so = -PF;
si = (1/EFL-1/so)^(-1);

d = camera(end).d+PB+si;
camera(end).d = d;
if d < 0
    warning('Negative distance - Image is not real');
end

end

