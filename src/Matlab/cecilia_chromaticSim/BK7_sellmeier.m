function [ n ] = BK7_sellmeier( lam )
% BK7_sellmeier calculate refractive index based on sellmeier model
%   lam - wavelength in um
%   n - index of refraction at that wavelength
% Data from:
% http://refractiveindex.info/download/data/2012/
%   schott_optical_glass_collection_datasheets_dec_2012_us.pdf

B1 = 1.03961212;
B2 = 0.231792344;
B3 = 1.01046945;
C1 = 0.00600069867;
C2 = 0.0200179144;
C3 = 103.560653;

n = sqrt((B1*lam^2/(lam^2-C1)) + (B2*lam^2/(lam^2-C2)) + ...
(B3*lam^2/(lam^2-C3)) + 1);


end

