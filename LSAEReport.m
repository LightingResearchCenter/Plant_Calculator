function [Irr,outTable] = LSAEReport(wave, specFlux, IESdata,lampType,targetPPFD, targetUniform,mountHeight, roomLength,roomWidth,calcSpace)
% LSAEREPORT generates a LSAE output table for given IES and Spectrum Files
%% Lumen Method to get close
LLF= [1,0.9,0.7,0.9];%N/a, HPS, LED, MH
ConversionFactor = PPF_Conversion_Factor_05Apr2016(wave,specFlux);
[CU, fluxTotal]= calcCU(IESdata,mountHeight, roomLength, roomWidth);
ppfTotal = ((fluxTotal/1000)*ConversionFactor);
numLuminaire = ceil(((targetPPFD*roomLength*roomWidth)/(ppfTotal*CU*LLF(lampType))));
%% Rectangularize Luminaires
found = false;
spacing = 1;
[IrrOut,AvgOut,MaxOut, MinOut,MinToAvgOut,placement]=deal(cell(1,1));
while found ==false
    [newCountArr, orrientation] = findArrangement(IESdata,numLuminaire,spacing,unitsratio('ft','m')*roomLength,unitsratio('ft','m')*roomWidth);
    [Irr,Avg,Max, Min,MinToAvg]=deal(cell(length(newCountArr),1));
    avgDiffUni = zeros(length(newCountArr),1);
    newOrien = cell(length(newCountArr),1);
    ind = 1;
    for i = 1:size(newCountArr,1)
        newOrien{i,1} = [newCountArr{i,1},ones(size(newCountArr{i,1},1),1)*orrientation(i)];
    end
    newCenters = cell(0,1);
    for iB = 1:numel(newOrien)
       testLoc = newOrien{iB};
       isnew = true;
       for iA = 1:numel(newCenters)
           tmp  = newCenters{iA};
           if isequaln(tmp, testLoc)
               isnew = false;
           end
       end
       if isnew
           newCenters{end+1,1} = newOrien{iB};
       end
    end
    testOrien = cell(0,1);
    for i = 1:size(newCenters,1)
        testLoc = newCenters{i};
        isnew = true;
        if numel(placement)~=1
            for iA = 1:numel(placement)
                tmp  = placement{iA};
                if isequaln(tmp, testLoc)
                    isnew=false;
                    break;
                end
            end
        end
        if isnew
            [Irr{ind,1},Avg{ind,1},Max{ind,1},Min{ind,1}] = PPFCalculator(IESdata,...
                'Centers',unitsratio('m','ft')*newCenters{i}(:,1:2),...
                'MountHeight',mountHeight,...
                'Length',roomLength,...
                'Width',roomWidth,...
                'Multiplier',round(ConversionFactor,1),...
                'LLF',LLF(lampType),...
                'fixtureOrientation',newCenters{i}(1,3),...
                'calcSpacing',calcSpace);
            testOrien{ind,1} = newCenters{i};
            MinToAvg{ind,1} = Min{ind}/Avg{ind};
            avgDiffUni(ind,1) = MinToAvg{ind} - targetUniform;
            perDif(ind,1) = ((Avg{ind}-targetPPFD)/targetPPFD);
            ind = ind+1;
        end
    end
    if length(placement)==1
        placement = testOrien;
        IrrOut = Irr;
        AvgOut = Avg;
        MaxOut = Max;
        MinOut = Min;
        MinToAvgOut = MinToAvg;
    else
        placement = [placement;testOrien];
        IrrOut = [IrrOut;Irr];
        AvgOut = [AvgOut;Avg];
        MaxOut = [MaxOut;Max];
        MinOut = [MinOut;Min];
        MinToAvgOut = [MinToAvgOut;MinToAvg];
    end
    if (max(avgDiffUni)<=0) && (spacing<1.5)
        spacing = spacing + 0.1;
    else
        found = true;
        placement(cellfun(@isempty,placement)) = [];
        IrrOut(cellfun(@isempty,IrrOut)) = [];
        AvgOut(cellfun(@isempty,AvgOut)) = [];
        MaxOut(cellfun(@isempty,MaxOut)) = [];
        MinOut(cellfun(@isempty,MinOut)) = [];
        MinToAvgOut(cellfun(@isempty,MinToAvgOut)) = [];
        if size(placement,1)>1
            [~,index] = max([MinToAvgOut{:}]);
        else
            index= 1;
        end
    end
end
Irr = IrrOut{index};
Avg = AvgOut{index};
Max = MaxOut{index};
Min = MinOut{index};
MinToAvg = MinToAvgOut{index};
maxToMin = Max/Min;
count = placement(index);
perDif = ((Avg-targetPPFD)/targetPPFD);
CUavg = (length(count)*ppfTotal*CU)/(roomLength*roomWidth);
outTable = table(mountHeight,numLuminaire,count,Avg,targetPPFD,CUavg,Max,Min,MinToAvg,maxToMin,targetUniform,perDif);
end