function [ r, d ] = calc_entrpupil( camera )
%[ r, d ] = calc_entrpupil( camera )
%   Outputs:
%       r - radius of entrance pupil
%       d - distance from object plane to entrance pupil
%
% Calculated by imaging each surface through all prior surfaces. The
% smallest one is the entrance pupil

%%%% TO DO %%%%%%%%
% for now, specify the entrance pupil as the first element because it is
% computationally efficient

r = camera(2).sd*.9;
d = camera(1).d;

end

