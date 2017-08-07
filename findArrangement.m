function [allCenters,orientation,isMax] = findArrangement(IESdata,fixCount,spacing,roomLength,roomWidth)
fixLength = IESdata.LengthFt; %feet
fixWidth = IESdata.WidthFt; %feet
maxDim = max([fixLength,fixWidth]);
minDim = min([fixLength,fixWidth]);
trussCount = [1,2,3,5,6];
trussLocs = {15;[5,25];[5,15,25];[5,10,15,20,25];2.5:5:30};
if maxDim > minDim*3
    isLinear = true;
else
    isLinear = false;
end
longMountLength = roomLength; %feet
shortMountLength = roomWidth; %feet
longMountCount = 3; %from Discussions with growers
longMountInc = shortMountLength/longMountCount;
longMount = zeros(1,longMountCount);
for i = 1:longMountCount
    longMount(i) = (longMountInc*i) - (longMountInc*0.5);% to center in space
end
isMax = false;
%% Place Linear Fixtures
if isLinear
    truss = trussLocs{end-1};
    maxPerTB = floor(longMountLength/maxDim); %how many fit on a run
    maxSet = maxPerTB*length(truss);
    if fixCount>maxSet
        fixSet(1) = maxSet;
        fixNeeded = fixCount -maxSet;
    else
        fixSet(1) = fixCount;
        fixNeeded = 0;
    end
    if fixNeeded>maxSet
        fixSet(2) = maxSet;
        fixNeeded = fixNeeded -maxSet;
    else
        fixSet(2) = fixNeeded;
        fixNeeded = 0;
    end
    if fixNeeded>maxSet
        fixSet(3) = maxSet;
        isMax = true;
    else
        fixSet(3) = fixNeeded;
    end
    LRshift = [0,(minDim),-(minDim)]*spacing;
    index = 1;
    fixtureCenters = zeros(sum(fixSet),2);
    for s=1:3
        if fixSet(s) == maxSet
            fixPerTruss = fixSet(s)/length(truss);
            leftOverSpace = (longMountLength - (fixPerTruss * maxDim))/fixPerTruss;
            fixStart = (leftOverSpace/2)+(maxDim/2);
            for i1 = 1:length(truss)
                fixtureCenters(index,:) = [truss(i1)+LRshift(s),fixStart];
                index = index+1;
            end
            for i = 2:fixPerTruss
                lastFix = fixtureCenters(index-1,2);
                fixStart = lastFix+(maxDim+leftOverSpace);
                for i1 = 1:length(truss)
                    fixtureCenters(index,:) = [truss(i1)+LRshift(s),fixStart];
                    index = index+1;
                end
            end
        else
            maxPerTB = floor(longMountLength/maxDim); %how many fit on a run
            truss = trussLocs{3};
            switch fixSet(s)
                case 1
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),longMountLength/(fixCount+1)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 2
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),longMountLength/(fixCount+1)];
                    index = index +1;
                    fixtureCenters(index,:) = [longMount(2),(2*longMountLength)/(fixCount+1)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 3
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),longMountLength/(fixCount+1)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),(3*longMountLength)/(fixCount+1)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),(2*longMountLength)/(fixCount+1)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 4
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),3*(longMountLength/4)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 5
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),longMountLength/(2)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 6
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(2*longMountLength)/(4)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 7
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2)+LRshift(s),longMountLength/(2)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 8
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1)+LRshift(s),(4*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3)+LRshift(s),(4*longMountLength)/(5)];
                    index = index +1;
                    allCenters{1} = fixtureCenters;
                case 0
                    
                otherwise
                    i = 1;
                    fixDiff = 3;
                    while (i<=fixDiff)&&(fixSet(s)-i>1)
                        minLuminare = fixSet(s)-i;
                        i=i+1;
                    end
                    fact = arrayfun(@factor,minLuminare:(fixSet(s)+fixDiff),'UniformOutput',false);
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
                    LRArr = [countArr(:,1);countArr(:,2)];
                    TBArr = [countArr(:,2);countArr(:,1)];
                    LRArr(TBArr>maxPerTB) = [];
                    TBArr(TBArr>maxPerTB) = [];
                    ind = 1;
                    for i = 1:length(LRArr)
                        if ~any(LRArr(i) == trussCount(1:end-1))
                            toDelete(ind) = i;
                            ind = ind+1;
                        end
                    end
                    LRArr(toDelete) = [];
                    TBArr(toDelete) = [];
                    allCenters = cell(length(LRArr),1);
                    startIndex = index;
                    for i = 1:length(LRArr)
                        index = startIndex;
                        tempCenters = fixtureCenters;
                        switch LRArr(i)
                            case 1
                                truss = trussLocs{1};
                            case 2
                                truss = trussLocs{2};
                            case 3
                                truss = trussLocs{3};
                            case 5
                                truss = trussLocs{4};
                            otherwise
                                error('?');
                        end
                        fixPerTruss = TBArr(i);
                        leftOverSpace = (longMountLength - (fixPerTruss * maxDim))/fixPerTruss;
                        fixStart = (leftOverSpace/2)+(maxDim/2);
                        for i1 = 1:length(truss)
                            tempCenters(index,:) = [truss(i1)+LRshift(s),fixStart];
                            index = index+1;
                        end
                        for i2 = 2:fixPerTruss
                            lastFix = tempCenters(index-1,2);
                            fixStart = lastFix+(maxDim+leftOverSpace);
                            for i1 = 1:length(truss)
                                tempCenters(index,:) = [truss(i1)+LRshift(s),fixStart];
                                index = index+1;
                            end
                        end
                        tempCenters(all(tempCenters==0,2),:)=[];
                        allCenters{i} = tempCenters;
                    end
            end
        end
    end
    orientation = (ones(size(allCenters,1),1)*90);
end
%% Place Square Fixtures
if fixLength==fixWidth
    maxDim = fixLength;
    minDim = fixWidth;
    setCenters = cell(2,1);
    setOrientation = cell(2,1);
    trueFixCount = fixCount;
    
    orient = [90,0];
    for j = 1:2
        maxPerTB = floor(longMountLength/maxDim); %how many fit the length of the room
        maxPerLR = floor(shortMountLength/minDim); %how many fit the width of the room
        if trueFixCount > (maxPerTB*maxPerLR)
            fixCount = maxPerTB*maxPerLR;
        end
        fixDiff = 3;
        numLuminaire = fixCount-fixDiff+2:fixCount+fixDiff;
        numLuminaire(numLuminaire<=0) = [];
        numLuminaire(numLuminaire>(maxPerTB*maxPerLR)) = [];
        for k =1:length(numLuminaire)
            fixtureCenters = zeros(numLuminaire(k),2);
            index=1;
            truss = trussLocs{3};
            switch numLuminaire(k)
                case 1
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 2
                    fixtureCenters(index,:) = [truss(2),longMountLength/(3)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(2*longMountLength)/(3)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 3
                    fixtureCenters(index,:) = [truss(2),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(2*longMountLength)/(4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 4
                    fixtureCenters(index,:) = [truss(1),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),3*(longMountLength/4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 5
                    fixtureCenters(index,:) = [truss(1),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 6
                    fixtureCenters(index,:) = [truss(1),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 7
                    fixtureCenters(index,:) = [truss(1),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 8
                    fixtureCenters(index,:) = [truss(1),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(4*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(4*longMountLength)/(5)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                otherwise
                    
                    fact = arrayfun(@factor,numLuminaire(k),'UniformOutput',false);
                    myFunc = @(x) partitions([x,1],2);
                    fullPart = cellfun(myFunc,fact,'UniformOutput',false);
                    fullPart = vertcat(fullPart{:});
                    myFunc1 = @(x) prod(x{1});
                    myFunc2 = @(x) prod(x{2});
                    countArr1 = cellfun(myFunc1,fullPart,'UniformOutput',false);
                    countArr2 = cellfun(myFunc2,fullPart,'UniformOutput',false);
                    countArr = [[countArr1{:}]',[countArr2{:}]'];
                    countArr = unique(countArr,'rows');
                    LRArr = [countArr(:,1);countArr(:,2)];
                    TBArr = [countArr(:,2);countArr(:,1)];
                    LRArr(TBArr>maxPerTB) = [];
                    TBArr(TBArr>maxPerTB) = [];
                    TBArr(LRArr>maxPerLR) = [];
                    LRArr(LRArr>maxPerLR) = [];
                    setCenters{k,j} = cell(length(LRArr),1);
                    for i = 1:length(LRArr)
                        b = ones(LRArr(i),TBArr(i));
                        deltaY = (((1:LRArr(i))*(1/(LRArr(i))*longMountLength))-(0.5*(1/(LRArr(i))*longMountLength)));
                        deltaX = (((1:TBArr(i))*(1/(TBArr(i))*shortMountLength))-(0.5*(1/(TBArr(i))*shortMountLength)));
                        xFixtureLocations = times( b ,deltaX);
                        yFixtureLocations = times( b ,deltaY');
                        xFixtureLocations = reshape(xFixtureLocations',1,numel(xFixtureLocations));
                        yFixtureLocations = reshape(yFixtureLocations',1,numel(yFixtureLocations));
                        tempCenters = [xFixtureLocations',yFixtureLocations'];
                        tempCenters(all(tempCenters==0,2),:)=[];
                        setCenters{k,j}{i} = tempCenters;
                    end
                    setOrientation{k,j} = [(ones(size(setCenters{k,j},1),1)*90);(ones(size(setCenters{k,j},1),1)*0)];
                    setCenters{k,j} = [setCenters{k,j};setCenters{k,j}];
            end
        end
        maxDim = fixWidth;
        minDim = fixLength;
    end
    
    orientation = reshape(setOrientation(:),numel(setOrientation),1);
    allCenters = reshape(setCenters(:),numel(setCenters),1);
    orientation= vertcat(orientation{:});
    allCenters = vertcat(allCenters{:});
end
%% Place Rectangular Fixtuers
if ((fixLength~=fixWidth)&&~isLinear)
    
    maxDim = fixLength;
    minDim = fixWidth;
    setCenters = cell(2,1);
    setOrientation = cell(2,1);
    trueFixCount = fixCount;
    
    orient = [90,0];
    for j = 1:2
        maxPerTB = floor(longMountLength/maxDim); %how many fit the length of the room
        maxPerLR = floor(shortMountLength/minDim); %how many fit the width of the room
        if trueFixCount > (maxPerTB*maxPerLR)
            fixCount = maxPerTB*maxPerLR;
        end
        fixDiff = 3;
        numLuminaire = fixCount-fixDiff+2:fixCount+fixDiff;
        numLuminaire(numLuminaire<=0) = [];
        numLuminaire(numLuminaire>(maxPerTB*maxPerLR)) = [];
        for k =1:length(numLuminaire)
            fixtureCenters = zeros(numLuminaire(k),2);
            index=1;
            truss = trussLocs{3};
            switch numLuminaire(k)
                case 1
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 2
                    fixtureCenters(index,:) = [truss(2),longMountLength/(3)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(2*longMountLength)/(3)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 3
                    fixtureCenters(index,:) = [truss(2),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),(2*longMountLength)/(4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 4
                    fixtureCenters(index,:) = [truss(1),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),3*(longMountLength/4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 5
                    fixtureCenters(index,:) = [truss(1),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/4];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),3*(longMountLength/4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 6
                    fixtureCenters(index,:) = [truss(1),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(4)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 7
                    fixtureCenters(index,:) = [truss(1),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(4)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(2),longMountLength/(2)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                case 8
                    fixtureCenters(index,:) = [truss(1),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(1),(4*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),longMountLength/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(2*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(3*longMountLength)/(5)];
                    index = index +1;
                    fixtureCenters(index,:) = [truss(3),(4*longMountLength)/(5)];
                    index = index +1;
                    setCenters{k,j} = {fixtureCenters};
                    setOrientation{k,j} = orient(j);
                otherwise
                    
                    fact = arrayfun(@factor,numLuminaire(k),'UniformOutput',false);
                    myFunc = @(x) partitions([x,1],2);
                    fullPart = cellfun(myFunc,fact,'UniformOutput',false);
                    fullPart = vertcat(fullPart{:});
                    myFunc1 = @(x) prod(x{1});
                    myFunc2 = @(x) prod(x{2});
                    countArr1 = cellfun(myFunc1,fullPart,'UniformOutput',false);
                    countArr2 = cellfun(myFunc2,fullPart,'UniformOutput',false);
                    countArr = [[countArr1{:}]',[countArr2{:}]'];
                    countArr = unique(countArr,'rows');
                    LRArr = [countArr(:,1);countArr(:,2)];
                    TBArr = [countArr(:,2);countArr(:,1)];
                    LRArr(TBArr>maxPerTB) = [];
                    TBArr(TBArr>maxPerTB) = [];
                    TBArr(LRArr>maxPerLR) = [];
                    LRArr(LRArr>maxPerLR) = [];
                    setCenters{k,j} = cell(length(LRArr),1);
                    for i = 1:length(LRArr)
                        b = ones(LRArr(i),TBArr(i));
                        deltaY = (((1:LRArr(i))*(1/(LRArr(i))*longMountLength))-(0.5*(1/(LRArr(i))*longMountLength)));
                        deltaX = (((1:TBArr(i))*(1/(TBArr(i))*shortMountLength))-(0.5*(1/(TBArr(i))*shortMountLength)));
                        xFixtureLocations = times( b ,deltaX);
                        yFixtureLocations = times( b ,deltaY');
                        xFixtureLocations = reshape(xFixtureLocations',1,numel(xFixtureLocations));
                        yFixtureLocations = reshape(yFixtureLocations',1,numel(yFixtureLocations));
                        tempCenters = [xFixtureLocations',yFixtureLocations'];
                        tempCenters(all(tempCenters==0,2),:)=[];
                        setCenters{k,j}{i} = tempCenters;
                    end
                    setOrientation{k,j} = [(ones(size(setCenters{k,j},1),1)*90);(ones(size(setCenters{k,j},1),1)*0)];
                    setCenters{k,j} = [setCenters{k,j};setCenters{k,j}];
            end
        end
        maxDim = fixWidth;
        minDim = fixLength;
    end
    
    orientation = reshape(setOrientation(:),numel(setOrientation),1);
    allCenters = reshape(setCenters(:),numel(setCenters),1);
    orientation= vertcat(orientation{:});
    allCenters = vertcat(allCenters{:});
end
end