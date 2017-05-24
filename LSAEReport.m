function [Irr,outTable] = LSAEReport(wave, specFlux, IESdata,targetPPFD, targetUniform,mountHeight, roomLength,roomWidth)
% LSAEREPORT generates a LSAE output table for given IES and Spectrum Files


%% Lumen Method to get close
ConversionFactor = PPF_Conversion_Factor_05Apr2016(wave,specFlux);
[CU, fluxTotal]= calcCU(IESdata,mountHeight, roomLength, roomWidth);
targetLux = (targetPPFD/ConversionFactor)*1000;
numLuminaire = ceil((targetLux*roomLength*roomWidth)/(fluxTotal*CU));
if (sqrt(numLuminaire)-floor(sqrt(numLuminaire))) == 0
    LRcount = sqrt(numLuminaire);
    TBcount = sqrt(numLuminaire);
elseif (sqrt(numLuminaire)-floor(sqrt(numLuminaire))) >= 0.5
    LRcount = ceil(sqrt(numLuminaire));
    TBcount = ceil(sqrt(numLuminaire));
elseif (sqrt(numLuminaire)-floor(sqrt(numLuminaire))) < 0.5
    LRcount = ceil(sqrt(numLuminaire));
    TBcount = ceil(sqrt(numLuminaire));
else
    error('how did this happen');
end
%% Initial Calculation

[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
avgToMin = Avg/Min;
maxToMin = Max/Min;
perDif = ((Avg-targetPPFD)/targetPPFD);
historyTable = table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif);
%% Find fixtures for Target Average
itteration = 0;
while~((perDif<=.10) && (perDif> 0))
    itteration = itteration +1; %count how many loops it took to find optimum
    if itteration >20
        break
    end
    if (perDif>=.10) % There is too much light
        % determine how to change the count of fixtures
        if (TBcount == 1) && (LRcount == 1)
            % there is no way to get less light by reducing the fixture count
            break;
        end
        if TBcount == LRcount
            if mod(itteration,2)==1
                TBcount = ceil(TBcount*(1-perDif));
            else
                LRcount = ceil(LRcount*(1-perDif));
            end
        elseif TBcount > LRcount
            TBcount = ceil(TBcount*(1-perDif));
        elseif LRcount > TBcount
            LRcount = ceil(LRcount*(1-perDif));
        end
        % check if this count has already been run
        for I = 1:height(historyTable)
            if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                found = true;
                break
            else
                found = false;
            end
        end
        if found == true
            LRcount = historyTable.LRcount(end);
            TBcount = historyTable.TBcount(end);
            break
        else
            
            [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
            avgToMin = Avg/Min;
            maxToMin = Max/Min;
            perDif = ((Avg-targetPPFD)/targetPPFD);
            historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
        end
    elseif (perDif< 0)% there is not enough light
        % determine how to change the count of fixtures
        if TBcount == LRcount
            if mod(itteration,2)==1
                TBcount = ceil(TBcount*(abs(perDif)+1));
            else
                TBcount = ceil(TBcount*(abs(perDif)+1));
            end
        elseif TBcount > LRcount
            LRcount = ceil(LRcount*(abs(perDif)+1));
        elseif LRcount > TBcount
            TBcount = ceil(TBcount*(abs(perDif)+1));
        end
        %check if this count has already been run
        for I = 1:height(historyTable)
            if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                found = true;
                LRcount = historyTable.LRcount(end);
                TBcount = historyTable.TBcount(end);
                break
            else
                found = false;
            end
        end
        if found == true
            break
        else
            
            [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
            avgToMin = Avg/Min;
            maxToMin = Max/Min;
            perDif = ((Avg-targetPPFD)/targetPPFD);
            historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
        end
    end
end
%% try to minimize Avg2min
itteration = 0;
while avgToMin > targetUniform
    if itteration > 20
        break
    end
    itteration = itteration + 1;
    % Determin how to change the count
    if TBcount == LRcount
        LRcount = LRcount+1;
        TBcount = TBcount+1;
        % check if this count has already been run
        for I = 1:height(historyTable)
            if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                found = true;
                avgToMin = historyTable.avgToMin(I);
                break
            else
                found = false;
            end
        end
        if found == true;continue
        else
            
            [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
            avgToMin = Avg/Min;
            maxToMin = Max/Min;
            perDif = ((Avg-targetPPFD)/targetPPFD);
            historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
        end
        % Make sure your still close to targetPPFD
        while (perDif>=.15)
            %determine how to change the count
            if mod(itteration,2) == 1
                LRcount = LRcount-1;
            else
                TBcount = TBcount -1;
            end
            for I = 1:height(historyTable)
                if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                    found = true;
                   avgToMin = historyTable.avgToMin(I);
                    break
                else
                    found = false;
                end
            end
            if found == true;continue
            else
                
                [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
                avgToMin = Avg/Min;
                maxToMin = Max/Min;
                perDif = ((Avg-targetPPFD)/targetPPFD);
                historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
            end
        end
    elseif TBcount > LRcount
        LRcount = LRcount+1;
        for I = 1:height(historyTable)
            if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                found = true;
                avgToMin = historyTable.avgToMin(I);
                break
            else
                found = false;
            end
        end
        if found == true;continue
        else
            
            [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
            avgToMin = Avg/Min;
            maxToMin = Max/Min;
            perDif = ((Avg-targetPPFD)/targetPPFD);
            historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
        end
        while(perDif>=.15)
            TBcount = TBcount-1;
            for I = 1:height(historyTable)
                if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                    found = true;
                    avgToMin = historyTable.avgToMin(I);
                    break
                else
                    found = false;
                end
            end
            if found == true;continue
            else
                
                [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
                avgToMin = Avg/Min;
                maxToMin = Max/Min;
                perDif = ((Avg-targetPPFD)/targetPPFD);
                historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
            end
        end
    elseif LRcount > TBcount
        TBcount = TBcount +1;
        for I = 1:height(historyTable)
            if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                found = true;
                avgToMin = historyTable.avgToMin(I);
                break
            else
                found = false;
            end
        end
        if found == true;continue
        else
            
            [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
            avgToMin = Avg/Min;
            maxToMin = Max/Min;
            perDif = ((Avg-targetPPFD)/targetPPFD);
            historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
        end
        while (perDif>=.15)
            LRcount = LRcount-1;
            for I = 1:height(historyTable)
                if (historyTable.LRcount(I) == LRcount) && (historyTable.TBcount(I) == TBcount)
                    found = true;
                   avgToMin = historyTable.avgToMin(I);
                    break
                else
                    found = false;
                end
            end
            if found == true;continue
            else
                
                [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',LRcount,'TBcount',TBcount,'MountHeight',mountHeight,'Multiplier',round(ConversionFactor,1));
                avgToMin = Avg/Min;
                maxToMin = Max/Min;
                perDif = ((Avg-targetPPFD)/targetPPFD);
                historyTable =[historyTable; table(mountHeight,LRcount,TBcount,Avg,Max,Min,avgToMin,maxToMin,perDif)];
            end
        end
    end
end
outTable = table(mountHeight,numLuminaire,LRcount,TBcount,Avg,targetPPFD,Max,Min,avgToMin,maxToMin,targetUniform,perDif);
end