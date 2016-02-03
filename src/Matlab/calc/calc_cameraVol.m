function [ V ] = calc_cameraVol( camera, viz )
%[ V ] = calc_cameraVol( camera )
%   Calculate the volume of all elements for which n is not 1. (Excludes
%   after the last plane and between the object plane and image plane (even
%   if these are not air)).

if ~exist('viz','var')
    viz = 0;
end

z = 0;
V = 0;
if viz
    figure
    h = axes;
else
    h = [];
end

for i = 2:(numel(camera)-1)
    
    if camera(i).n ~= 1
        sd = camera(i).sd;
        V = V + calc_lensVol(z, camera(i).R, z+camera(i).d,...
            camera(i+1).R, sd, viz, h);
    end
    z = z + camera(i).d;
        
end


end

