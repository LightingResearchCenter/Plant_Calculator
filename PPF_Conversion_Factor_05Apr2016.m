function ConversionFactor = PPF_Conversion_Factor_05Apr2016(filePath)
spd = load(filePath);
wave = spd(:,1);
specFlux = spd(:,2);

h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant

q1 = find(wave>=400,1,'first');
q2 = find(wave<=700,1,'last');
    
PPF_mole = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9))/(h*c*Avo); % micromoles/s

kiloLumens = Lxy23Sep05([wave,specFlux])/1000;

ConversionFactor = PPF_mole/kiloLumens;
end
