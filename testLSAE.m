function [Data] = testLSAE(IES,range,Data)
mountHeight = 0.3048*(1:8);
Uniformity = 0.6;
roomLength = 36;
roomWidth = 30;

[IrrOut,outTable,LSAE,IrrArr] = fullLSAE(Data.Spectrum,IES,mountHeight,double(range), Uniformity,roomLength*unitsratio('m','ft'), roomWidth*unitsratio('m','ft'),(0.25),Data.LLF);

IESdata = IESFile(IES(1,:));
testStruct = table2struct(outTable,'ToScalar',true);
[m,loc] = max(testStruct.LSAE);
bestCount = length(testStruct.count{loc});

Data = simpleCalcEconomics(bestCount,Data,IESdata,roomWidth,roomLength);
Data.LSAETable = testStruct;
[~,Data.mount] = max(outTable.LSAE(outTable.targetPPFD(:)==300));
PlotWidth = 4; %ft
centers = [PlotWidth/2,PlotWidth/2,0];
plotISOppfd(Data.Spectrum,IESdata,PlotWidth,Data.mount,centers,Data.LLF,Data.ISOPlot);
Data.PPFconvert= PPF_Conversion_Factor_05Apr2016(Data.Spectrum(:,1),Data.Spectrum(:,2));
plotIntensityDist(IESdata,Data.PPFconvert,Data.IntensityDistplot);
%% Calc Simple Metrics
h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant
PSSRCRtable = readtable('PSS_RCR.txt','Delimiter', '\t');
wave = Data.Spectrum(:,1);
specFlux = Data.Spectrum(:,2);

q1 = find(wave>=400,1,'first');
q2 = find(wave<=700,1,'last');
Data.PPF_All = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s

q1 = find(wave>=400,1,'first');
q2 = find(wave<=500,1,'last');
Data.PPF_400 = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s

q1 = find(wave>=500,1,'first');
q2 = find(wave<=600,1,'last');
Data.PPF_500 = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s

q1 = find(wave>=600,1,'first');
q2 = find(wave<=700,1,'last');
Data.PPF_600 = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s

q1 = find(wave>=300,1,'first');
q2 = find(wave<=800,1,'last');
sigmaRed = interp1(PSSRCRtable.lambda,PSSRCRtable.sigma_r,wave,'linear',0.0);
sigmaFarRed = interp1(PSSRCRtable.lambda,PSSRCRtable.sigma_fr,wave,'linear',0.0);
PSSRed = trapz(wave(q1:q2),specFlux(q1:q2).*sigmaRed(q1:q2).*...
    (wave(q1:q2)*1e-9)/(h*c*Avo));
PSSFarRed = trapz(wave(q1:q2),specFlux(q1:q2).*sigmaFarRed(q1:q2).*...
    (wave(q1:q2)*1e-9)/(h*c*Avo));
Data.PSS = PSSRed/(PSSRed + PSSFarRed);
end