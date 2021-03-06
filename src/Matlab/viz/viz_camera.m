function [ hout ] = viz_camera( camera, h )
% viz_camera( camera )
%   Display lenses in new figure
%
% [ hout ] = viz_camera( camera, h )
%   Display lenses in given axes handle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 1
    axes(h);
else
    h = figure;
end

if nargout > 0
    hout = h;
end

% get maximum non-infinite semidiameter
all_sd = zeros(size(camera));
for i = 1:numel(camera)
    if ~isinf(camera(i).sd)
        all_sd(i) = camera(i).sd;
    end
end

cla
hold on

lw = 1;

z = 0;
for i = 2:(numel(camera)-1)
    sd = modify_sd (camera(i).R, camera(i).sd, all_sd);
    if camera(i).n ~= 1
        if isinf(camera(i).R)
            [x1, y1] =  drawFlatSurf (z, sd);
            plot(x1, y1, 'k', 'linewidth', lw);
        else
            [x1, y1] = drawCurvedSurf (camera(i).R, z, sd);
            plot(x1, y1, 'k', 'linewidth', lw);
        end
        if isinf(camera(i+1).R)
            [x2, y2] =  drawFlatSurf (z+camera(i).d, sd);
            plot(x2, y2, 'k', 'linewidth', lw);
        else
            [x2, y2] = drawCurvedSurf (camera(i+1).R, z+camera(i).d, sd);
            plot(x2, y2, 'k', 'linewidth', lw);
        end
        plot([x1(1) x2(1)], [y1(1) y2(1)], 'k', 'linewidth', lw);
        plot([x1(end) x2(end)], [y1(end) y2(end)], 'k', 'linewidth', lw);
        
    end
    z = camera(i).d + z;
end


hold off
axis equal
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [x, y] = drawFlatSurf (z, sd)
        % x, y are horizontal vectors
        num_points = 20;
        x = z*ones(1,num_points);
        y = linspace(-sd, sd, num_points);
        
    end

    function [x, y] = drawCurvedSurf (R, z, sd)
        % R should not be infinite
        % x, y are horizontal vectors
        num_points = 100;
        center = R + z;
        theta_max = asin(sd/R);
        theta = linspace(-theta_max, theta_max, num_points);
        x = -R*cos(theta) + center;
        y = R*sin(theta); 
    end

    function sd = modify_sd (R, sd, all_sd)
        if isinf(R) && isinf(sd)
            sd = max(all_sd);
        elseif isinf(R) && ~isinf(sd)
            return
        elseif sd <= abs(R)
            return
        else
            sd = R;
        end
    end



end

