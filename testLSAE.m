function [Data] = testLSAE(IES,range,Data)
mountHeight = 0.3048*(1:8);
Uniformity = 0.6;
roomLength = 36;
roomWidth = 30;
% switch upper(Data.Source)
%     case 'N/A'
%         lampType = 1;
%     case 'HPS'
%         lampType = 2;
%     case 'LED'
%         lampType = 3;
%     case 'MH'
%         lampType = 4;
%     otherwise
%         lampType = 1;
% end
[IrrOut,outTable,LSAE,IrrArr] = fullLSAE(Data.Spectrum,IES,mountHeight,double(range), Uniformity,roomLength*unitsratio('m','ft'), roomWidth*unitsratio('m','ft'),(0.25),Data.LLF);

IESdata = IESFile(IES(1,:));
testStruct = table2struct(outTable,'ToScalar',true);
[m,loc] = max(testStruct.LSAE);
bestCount = length(testStruct.count{loc});

Data = simpleCalcEconomics(bestCount,Data,IESdata,roomWidth,roomLength);

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

end