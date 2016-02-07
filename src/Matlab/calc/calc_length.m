function [ l ] = calc_length( camera )
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

if camera(2).R >= 0
    z1 = camera(1).d;
else
    z1 = calc_lensExtent(camera(1).d, camera(2).R, camera(2).sd);
end



z0_last = 0;
for i = 1:(numel(camera)-1)
    z0_last = z0_last + camera(i).d;
end
if camera(end).R <= 0
    z2 = z0_last;
else
    z2 = calc_lensExtent(z0_last, camera(end).R, camera(end).sd);
end

l = z2-z1;


end

