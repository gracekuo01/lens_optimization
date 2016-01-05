function [ h ] = viz_camera( camera, h )
%viz_camera( camera )
%   Display lenses, return figure handle

if nargin > 1
    axes(h);
else
    h = figure;
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

z = 0;
for i = 1:numel(camera)
    sd = modify_sd (camera(i).R, camera(i).sd, all_sd);
    if isinf(camera(i).R)
        [x, y] =  drawFlatSurf (z, sd);
        plot(x, y);
    else
        [x, y] = drawCurvedSurf (camera(i).R, z, sd);
        plot(x, y);
    end
    z = camera(i).d + z;
end

[x, y] = drawFlatSurf (z, max(all_sd));
plot(x,y);



[ xout, yout, zout ] = viz_traceRayForward( 0, 0, atan(15/300), 0, camera );
plot(zout, xout);

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

