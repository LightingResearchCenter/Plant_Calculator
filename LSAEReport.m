function [Irr,outTable] = LSAEReport(wave, specFlux, IESdata,targetPPFD, targetUniform,mountHeight, roomLength,roomWidth)
% LSAEREPORT generates a LSAE output table for given IES and Spectrum Files


%% Lumen Method to get close
ConversionFactor = PPF_Conversion_Factor_05Apr2016(wave,specFlux);
[CU, fluxTotal]= calcCU(IESdata,mountHeight, roomLength, roomWidth);
ppfTotal = (fluxTotal*ConversionFactor)/1000;
numLuminaire = ceil((targetPPFD*roomLength*roomWidth)/(ppfTotal*CU));
%% Rectangulrize Luminairs
i = 1;
fixDiff = 3;
while (i<=fixDiff)&&(numLuminaire>1)
    minLuminare = numLuminaire-i;
    i=i+1;
end
fact = arrayfun(@factor,minLuminare:(numLuminaire+fixDiff),'UniformOutput',false);
fullPart = [];
for i = 1:length(fact)
    
        fullPart = [partitions([fact{i},1],2);fullPart];
end
countArr = zeros(length(fullPart),2);
for i=1:length(fullPart)
    countArr(i,1) = prod(fullPart{i}{1});
    countArr(i,2) = prod(fullPart{i}{2});
end
countArr = unique(countArr,'rows');
ind = 1;
for i = 1:length(countArr)
    ratio = max(countArr(i,:))/min(countArr(i,:));
    if (ratio <= 4)
        newCountArr(ind,1) = countArr(i,1);
        newCountArr(ind,2) = countArr(i,2);
        ind = ind+1;
    end
end
[Irr,Avg,Max, Min]=deal(cell(1,length(newCountArr)));
avgDiff = zeros(1,length(newCountArr));
for i = 1:size(newCountArr,1)
        [Irr{i},Avg{i},Max{i},Min{i}] = PPFCalculator(wave,specFlux,IESdata,'LRcount',newCountArr(i,1),'TBcount',newCountArr(i,2),'MountHeight',mountHeight,'Length',roomLength,'Width',roomWidth,'Multiplier',round(ConversionFactor,1));
        avgDiff(i) = (Avg{i}-targetPPFD)/targetPPFD;
        if avgDiff(i) < 0
            avgDiff(i)=1;
        end
end
if size(newCountArr,1)>1
    [~,index] = min(avgDiff);
else 
    index= 1;
end
Irr = Irr{index};
Avg = Avg{index};
Max = Max{index};
Min = Min{index};
LRcount = newCountArr(index,1);
TBcount = newCountArr(index,2);
avgToMin = Avg/Min;
maxToMin = Max/Min;
perDif = ((Avg-targetPPFD)/targetPPFD);
CUavg = (LRcount*TBcount*ppfTotal*CU)/(roomLength*roomWidth);
outTable = table(mountHeight,numLuminaire,LRcount,TBcount,Avg,targetPPFD,CUavg,Max,Min,avgToMin,maxToMin,targetUniform,perDif);
end