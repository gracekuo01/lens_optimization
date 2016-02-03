function [ img ] = test_simulateSpot_chromatic( sourcex, sourcey, sourcez, lam, pixel_pitch, xrange, yrange )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

N = 100000; % number of rays to trace for each spot

camera = createCamera(sourcez, lam);
[ xout, yout, I ] = simulateSpot( camera, sourcex, sourcey,  N);
[img] = rays2img2D(xout, yout, I, pixel_pitch, xrange, yrange);
    
end

function [camera] = createCamera (sourcez, lam)
% Constants
d0 = 100; 
d1 = 3;
d2 = 100;
r1 = 50;
r2 = -50;
n1 = BK7_sellmeier(lam);    % n glass for given wavelength
ng = BK7_sellmeier (0.55);   % n green
na = 1;                     % n air
sd = 11;
EFL = 50;

% Create camera, optimize (paraxially) for green lam = 0.55 um, d0 = 100 mm
clear camera
camera(1) = struct('R', inf, 'd', d0, 'n', na, 'sd', inf);   % Object plane
camera(2) = struct('R', r1,'d', d1, 'n', ng, 'sd', sd);
camera(3) = struct('R', r2,'d', d2, 'n', na, 'sd', sd);
[camera] = calc_lastr(camera, EFL); % set last radius of curvature, r2
[camera] = calc_lastd(camera);      % set distance to image plane, d2

% put in variables into camera
camera(1) = struct('R', inf, 'd', d0-sourcez, 'n', na, 'sd', inf);
camera(2) = struct('R', r1,'d', d1, 'n', n1, 'sd', sd); % set n to correct index for given color
end
