%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation for Cecilia
% Chromatic aberration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Colors
lam = [.65, .55, .45]; % um (R, G, B)

sourcex = 0;
sourcey = 0;
sourcez = 4;

pixel_pitch = .002;
xrange = [-.5 .5];
yrange = [-.5 .5];
numPixX = floor((xrange(2)-xrange(1))/pixel_pitch);
numPixY = floor((yrange(2)-yrange(1))/pixel_pitch);

img = zeros(numPixX, numPixY, 3);

for i = 1:3
     img(:,:,i) = test_simulateSpot_chromatic( sourcex, sourcey, sourcez, lam(i),...
         pixel_pitch, xrange, yrange );
end

img = img/(max(max(max(img))));
imshow(img);
