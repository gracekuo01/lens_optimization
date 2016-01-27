function [ m ] = calc_mag( camera )
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here

ABCD = calc_abcd(camera);
n1 = camera(1).n;
n2 = camera(end).n;
PF = (n1 - ABCD(2,2)*n2)/(n2*ABCD(2,1)); % front principle plane
PB = (1 - ABCD(1,1))/(ABCD(2,1));        % back principle plane
EFL = calc_efl(camera);
so = -PF;
si = (1/EFL-1/so)^(-1);
m = -si/so;


end

