function [ ] = test_optimizeSinglet( )

x = [50, -50, 2]; % initial condition

sd = 10;
n = 1.5;
so = 100;
si = 150; % distance from lens to image plane
camera(1) = struct('R', inf,  'd', so,   'n', 1, 'sd', inf);   % Object plane
camera(2) = struct('R', x(1), 'd', x(3), 'n', n, 'sd', sd);
camera(3) = struct('R', x(2), 'd', si,   'n', 1, 'sd', sd);
viz_camera(camera);

rmse = objectiveFunction(x)

x = fminsearch(@objectiveFunction,x);
rmse = objectiveFunction(x)
x
camera(1) = struct('R', inf,  'd', so,   'n', 1, 'sd', inf);   % Object plane
camera(2) = struct('R', x(1), 'd', x(3), 'n', n, 'sd', sd);
camera(3) = struct('R', x(2), 'd', si,   'n', 1, 'sd', sd);
viz_camera(camera);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rmse] = objectiveFunction(x)
        % Variables
        % x(1): R1 radius of curvature of first surface  - init: inf
        % x(2): R2 radius of curvature of second surface - init: -38.7
        % x(3): spacing between first and second surface - init: 10
        % x(4): spacing between end of lens and image plane - init: 150;
        
        % Constants
        %sd = 10;  % semidiamter
        %n = 1.5;  % index of refraction
        %so = 150; % distance from object to lens
        %si = 150; % distance from lens to image plane
        sourcex = 5; % source position x
        sourcey = 5; % source position y
        
        % Set up camera
        camera(1) = struct('R', inf,  'd', so,   'n', 1, 'sd', inf);   % Object plane
        camera(2) = struct('R', x(1), 'd', x(3), 'n', n, 'sd', sd);
        camera(3) = struct('R', x(2), 'd', si,   'n', 1, 'sd', sd);
        
        N = 1000; % number of rays to trace
        seed = 416;
        pupil_radius = sd;
        dist_to_pupil = so;
        Ns = round(1.28*N + 2.5*sqrt(N) + 100);
        rng(seed);
        Xrand = (rand(Ns,1)*2-1)*pupil_radius;
        Yrand = (rand(Ns,1)*2-1)*pupil_radius;
        I = find(sqrt(Xrand.^2+Yrand.^2)<=pupil_radius);
        Xrand = Xrand(I(1:N));
        Yrand = Yrand(I(1:N));
        
        x = sourcex*ones(N,1);
        y = sourcey*ones(N,1);
        
        xt = atan((Xrand-x)/(dist_to_pupil));
        yt = atan((Yrand-y)/(dist_to_pupil));
        
        xout = zeros(N,1); yout = zeros(N,1);
        xtout = zeros(N,1); ytout = zeros(N,1);
        for i = 1:N
            [ xout(i), xtout(i), yout(i), ytout(i) ] = ...
                traceRayForward( x(i), y(i), xt(i), yt(i), camera );
        end
        
        rmse = calc_rmse(xout, yout, -sourcex, -sourcey);
        %figure; plot(xout, yout);

        
    end

end



