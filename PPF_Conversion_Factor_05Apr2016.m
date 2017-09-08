function ConversionFactor = PPF_Conversion_Factor_05Apr2016(wave,specFlux)
% returns micromoles per kiloLumen
h = 6.626e-34; % Joule seconds, Planck's constant
c = 2.998e8; % meter/second
Avo = 6.022e23; % Avogardo constant

q1 = find(wave>=400,1,'first');
q2 = find(wave<=700,1,'last');
    
PPF_umole = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9))/(h*c*Avo); % micromoles/s

kiloLumens = Lxy23Sep05([wave,specFlux])/1000;

ConversionFactor = PPF_umole/kiloLumens;
end
