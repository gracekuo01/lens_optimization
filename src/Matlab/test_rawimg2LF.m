%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test File - Test Raw Image to Light Field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('../../data/imageThroughSinglet_smile_01-14.mat');

LF = rawImg2LF(rawimg, camera, xrange, yrange, pixel_pitch,...
    numAngSensors, f_lenslets);

figure;
imagesc(squeeze(LF(:,:, 450, 450)));