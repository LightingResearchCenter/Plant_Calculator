function [ PSS, RCR ] = calcPSSRCR( SPD )
%CALCPSSRCR Calculates PSS and RCR Horticultural metrics
%   calculates PSS and RCR as described by (Sager, 1988)
pssTable = readtable('PSS_RCR.txt','Delimiter', '\t');
wave = SPD(:,1);
specFlux = SPD(:,2);
sigmaRed = interp1(pssTable.lambda,pssTable.sigma_r,wave,'linear',0.0);
sigmaFarRed = interp1(pssTable.lambda,pssTable.sigma_fr,wave,'linear',0.0);
PSSRed = trapz(wave,specFlux.*sigmaRed);
PSSFarRed = trapz(wave,specFlux.*sigmaFarRed);
PSS = PSSRed/(PSSRed + PSSFarRed);
RCR = PSS*(PSSFarRed);
end

