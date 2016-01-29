function [ V ] = calc_lensVol( z01, R1, z02, R2, sd, viz )
%[ V ] = calc_lensVol( z01, R1, z02, R2 )
%   Calculate the volume of the lens defined by the two spherical surfaces
%   with z-intercept at z0 and radius of curvature R
%   Assumes both surfaces have the same semidiameter sd. sd cannot be
%   larger than the radius of either surface (otherwise it will be change
%   automatically)
%
%   viz - set to 1 for vizualization (0  is default)

if ~exist('viz')
    viz = 0;
end

if sd > min(abs([R1 R2]))
    sd = min(abs([R1 R2]));
end

if viz
figure; hold on;
end

% find if spheres overlap by seeing if their projection along the y-axis
% (circles) overlap


% CASE 1: both have positive curvature (meniscus lens)
if R1 > 0 && R2 > 0
    V = meniscusPos( z01, R1, z02, R2, sd );
elseif R1 < 0 && R2 < 0
    V = meniscusNeg(z01, R1, z02, R2, sd );
elseif R1 > 0 && R2 < 0
    V = convex(z01, R1, z02, R2, sd);
elseif R1 < 0 && R2 > 0
    V = concave(z01, R1, z02, R2, sd);
else
    error('R should never be 0!!');
end

% CASE 2: both have negative curvature (meniscus lens)
% CASE 3: convex lens (first is positive, second is negative)
% CASE 4: concave lens (first is negative, second is positive)
% ALSO need to deal with inf cases

if viz
axis equal
hold off
grid on
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function V = meniscusPos(  z01, R1, z02, R2, sd )
        % find volume of a menicus lens where both curvatures are positive
        if R1 < 0 || R2 < 0
            error('Both curvatures must be positive')
        end
        zc1 = getSphereCenter(z01, R1);
        zc2 = getSphereCenter(z02, R2);
        [xinter, zinter] = calc_circleInt(zc1, R1, zc2, R2);
        if xinter < sd  && zinter <= (z01+R1)
            V = sphereCapVol(xinter, R1) - sphereCapVol(xinter, R2);
            if viz
                drawSphereCap(xinter, R1, z01, 'add')
                drawSphereCap(xinter, R2, z02, 'sub')
            end
        else
            zout1 = calc_lensExtent(z01, R1, sd);
            zout2 = calc_lensExtent(z02, R2, sd);
            V = sphereCapVol(sd, R1) + cylinderVol(sd, zout2-zout1)...
                - sphereCapVol(sd, R2);
            if viz
                drawSphereCap(sd, R1, z01, 'add')
                drawCylinder(sd, zout2-zout1, zout1, 'add')
                drawSphereCap(sd, R2, z02, 'sub')
            end
        end
    end

    function V = meniscusNeg(  z01, R1, z02, R2, sd  )
        R1N = -R2; R2N = -R1;
        z01N = -z02; z02N = -z01;
        V = meniscusPos( z01N, R1N, z02N, R2N, sd );
    end

    function V = convex( z01, R1, z02, R2, sd )
        if R1 < 0 || R2 > 0
            error('want R1 > 0 and R2 < 0')
        end
        zc1 = getSphereCenter(z01, R1);
        zc2 = getSphereCenter(z02, R2);
        [xinter, zinter] = calc_circleInt(zc1, R1, zc2, R2);
        if xinter < sd  && zinter <= (z01+R1)
            V = sphereCapVol(xinter, R1) + sphereCapVol(xinter, R2);
            if viz
                drawSphereCap(xinter, R1, z01, 'add')
                drawSphereCap(xinter, R2, z02, 'add')
            end
        else
            zout1 = calc_lensExtent(z01, R1, sd);
            zout2 = calc_lensExtent(z02, R2, sd);
            V = sphereCapVol(sd, R1) + cylinderVol(sd, zout2-zout1)...
                + sphereCapVol(sd, R2);
            if viz
                drawSphereCap(sd, R1, z01, 'add')
                drawCylinder(sd, zout2-zout1, zout1, 'add')
                drawSphereCap(sd, R2, z02, 'add')
            end
        end
        
    end

    function V = concave( z01, R1, z02, R2, sd )
        if R1 > 0 || R2 < 0
            error('want R1 < 0 and R2 > 0')
        end
        zout1 = calc_lensExtent(z01, R1, sd);
        zout2 = calc_lensExtent(z02, R2, sd);
        V = cylinderVol(sd, zout2-zout1) - sphereCapVol(sd, R1) - ...
            sphereCapVol(sd, R2);
        if viz
            drawCylinder(sd, zout2-zout1, zout1, 'add');
            drawSphereCap(sd, R1, z01, 'sub');
            drawSphereCap(sd, R2, z02, 'sub');
        end
    end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function V = sphereCapVol(a, r)
% a - largest diameter of cap
% r - total sphere radius
% based on wikipedia sphere cap variable names
r = abs(r);
if a > r
    V = nan;
    warning('a > |r|');
    return
end
if isinf(r)
    h = 0;
else
    h = r - ((a + r)*(r - a))^(1/2);
end
V = ( pi*h/6 ) * ( 3*a^2 + h^2 );
end

function V = cylinderVol(a, h)
% a - cylinder radius
% h - cylinder height
V = pi*a^2*h;
end

function zc = getSphereCenter(z0, R)
if isinf(R)
    zc = z0;
else
    zc = z0+R; 
end
end

function [] = drawSphereCap(sd, R, z0, add)
num_points = 100;
center = R + z0;
theta_max = asin(sd/R);
theta = linspace(-theta_max, theta_max, num_points);
x = -R*cos(theta) + center;
y = R*sin(theta);
if strcmp (add, 'add')
    c = 'b'; lw = 2;
else
    c = 'r'; lw = 0.5;
end
plot([x x(1)], [y y(1)], c, 'linewidth', lw)
end

function [] = drawCylinder(sd, h, z0, add)
if strcmp (add, 'add')
    c = 'b'; lw = 2;
else
    c = 'r'; lw = 0.5;
end
plot([z0 z0+h z0+h z0 z0], [sd sd -sd -sd sd], c, 'linewidth', lw);
end