function [ camera, R ] = calc_lastr( camera, EFL )
%[ camera, r ] = calc_lastr( camera, EFL )
%   Calculate the radius of the last spherical element to get the given EFL
%   Returns a new camera with the correct last radius

ABCD = eye(2);
for i = 2:(numel(camera)-1)
    d = camera(i-1).d;
    R = camera(i).R;
    n1 = camera(i-1).n;
    n2 = camera(i).n;
    ABCD = [1 0; (n1-n2)/(R*n2) (n1/n2)]*[1 d; 0 1]*ABCD;  
end

d = camera(end-1).d;
n1 = camera(end-1).n;
n2 = camera(end).n;
ABCD = [1 d; 0 1]*ABCD; % ABCD matrix of all elements up to 
                        % (and NOT including) the last curved surface

R = ( 1/(ABCD(1,1)*(n2-n1))* (ABCD(2,1)*n1 + n2/EFL) )^(-1);
camera(end).R = R;

end

