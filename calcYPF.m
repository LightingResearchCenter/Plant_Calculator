function [ YPF ] = calcYPF( SPD )
%calcYPF Calculates YPF Horticultural metrics
%   calculates YPF as described by McCree
%   McCree, K. J. 1971. “The Action Spectrum, Absorptance and Quantum Yield of  
%   Photosynthesis in Crop Plants.” Agricultural Meteorology 9 (C): 191–216. 
%   doi:10.1016/0002-1571(71)90022-7.

McCreeFromGraph = load('McCree1972.txt');
h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant
wave = SPD(:,1);
specFlux = SPD(:,2);
McCreePhoton = interp1(McCreeFromGraph(:,1),McCreeFromGraph(:,2),wave,'linear',0.0);
McCreeWatt = McCreePhoton.*((wave*1e-9)/(h*c*Avo));
McCreeWatt = McCreeWatt/max(McCreeWatt);

YPF = 1e6*trapz(wave,McCreePhoton.*specFlux.*(wave*1e-9))/(h*c*Avo); % micromoles/s
end