function [Irr,outTable] = LSAEReport(wave, specFlux, IESdata,lampType,targetPPFD, targetUniform,mountHeight, roomLength,roomWidth,calcSpace)
% LSAEREPORT generates a LSAE output table for given IES and Spectrum Files
%% Lumen Method to get close
LLF= [1,0.9,0.7,0.9];%N/a, HPS, LED, MH
ConversionFactor = PPF_Conversion_Factor_05Apr2016(wave,specFlux);
[CU, fluxTotal]= calcCU(IESdata,mountHeight, roomLength, roomWidth);
ppfTotal = ((fluxTotal/1000)*ConversionFactor);
numLuminaire = ceil(((targetPPFD*roomLength*roomWidth)/(ppfTotal*CU*LLF(lampType))));
%% place and calulate Luminares
found = false;
spacing = 1;
[IrrOut,AvgOut,MaxOut, MinOut,MinToAvgOut,placement]=deal(cell(1,1));
while found ==false
    if targetPPFD >=400
        [newCountArr, orrientation,maxCount] = findArrangement(IESdata,numLuminaire,spacing,unitsratio('ft','m')*roomLength,unitsratio('ft','m')*roomWidth,true);
    else
        [newCountArr, orrientation,maxCount] = findArrangement(IESdata,numLuminaire,spacing,unitsratio('ft','m')*roomLength,unitsratio('ft','m')*roomWidth,false);
    end
    newOrien = cell(length(newCountArr),1);
    ind = 1;
    for i = 1:size(newCountArr,1)
        newOrien{i,1} = [newCountArr{i,1},ones(size(newCountArr{i,1},1),1)*orrientation(i)];
    end
    A_cs = cellfun(@(x)(mat2str(x)),newOrien,'uniformoutput',false);
    [~,idxOfUnique,~] = unique(A_cs);
    newCenters = newOrien(idxOfUnique);
    testOrien = cell(0,1);
    
    [Irr]=deal(cell(length(newCenters),1));
    [avgDiffUni,Avg,Max,Min,MinToAvg,perDif]= deal(zeros(length(newCenters),1));
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
            [Irr{ind,1},Avg(ind,1),Max(ind,1),Min(ind,1)] = PPFCalculator(IESdata,...
                'Centers',unitsratio('m','ft')*newCenters{i}(:,1:2),...
                'MountHeight',mountHeight,...
                'Length',roomLength,...
                'Width',roomWidth,...
                'Multiplier',round(ConversionFactor,1),...
                'LLF',LLF(lampType),...
                'fixtureOrientation',newCenters{i}(1,3),...
                'calcSpacing',calcSpace);
            testOrien{ind,1} = newCenters{i};
            MinToAvg(ind,1) = Min(ind,1)/Avg(ind,1);
            avgDiffUni(ind,1) = MinToAvg(ind,1) - targetUniform;
            perDif(ind,1) = ((Avg(ind,1)-targetPPFD)/targetPPFD);
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
    if abs(spacing-1.6)>0.01
        spacing = spacing + 0.1;
    end
    testUni = MinToAvgOut;
    testUni(AvgOut-targetPPFD<0) =-1;
    if (max(testUni)>targetUniform)
        found = true;
        placement(cellfun(@isempty,placement)) = [];
        IrrOut(cellfun(@isempty,IrrOut)) = [];
        AvgOut(cellfun(@isempty,AvgOut)) = [];
        MaxOut(cellfun(@isempty,MaxOut)) = [];
        MinOut(cellfun(@isempty,MinOut)) = [];
        MinToAvgOut(cellfun(@isempty,MinToAvgOut)) = [];
        if size(placement,1)>1
            [~,index] = max(testUni);
        else
            index= 1;
        end
    elseif abs(spacing-1.6)<0.01
        if isempty(placement)
            disp(true)
        end
        found = true;
        placement(cellfun(@isempty,placement)) = [];
        IrrOut(cellfun(@isempty,IrrOut)) = [];
        AvgOut(arrayfun(@(x)x==0,AvgOut)) = [];
        MaxOut(arrayfun(@(x)x==0,MaxOut)) = [];
        MinOut(arrayfun(@(x)x==0,MinOut)) = [];
        MinToAvgOut(arrayfun(@(x)x==0,MinToAvgOut)) = [];
        if isempty(placement)
            disp(true)
        end
        if size(placement,1)>1 && ~isempty(placement)
            testUni = MinToAvgOut;
            testUni(AvgOut-targetPPFD<0) =-1;
            [~,index] = max(testUni);
            if testUni(index)==-1
                [~,index] = max(MinToAvgOut);
            end
        else
            index= 1;
        end
    end
end
%% Save off best output
Irr = IrrOut{index};
Avg = AvgOut(index);
Max = MaxOut(index);
Min = MinOut(index);
MinToAvg = MinToAvgOut(index);
maxToMin = Max/Min;
count = placement(index);
perDif = ((Avg-targetPPFD)/targetPPFD);
CUavg = (length(count)*ppfTotal*CU)/(roomLength*roomWidth);
outTable = table(mountHeight,numLuminaire,count,Avg,targetPPFD,CUavg,Max,Min,MinToAvg,maxToMin,targetUniform,perDif,maxCount);
end