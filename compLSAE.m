function [Data] = compLSAE(IES,range,Data)
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
Data.LSAETable = testStruct;
end