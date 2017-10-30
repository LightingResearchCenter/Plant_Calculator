function [newXLocation, newYLocation, newIES] = descritizeFixture(xLocations,yLocations,IESdata,mountHeight)
[maxDim,index] = max([IESdata.Length,IESdata.Width]);

if mountHeight < 5*maxDim
    %Split up the fixture
    newMax = mountHeight / 5;
    if newMax<1
        newMax = .4;
    end
    minDim = min([IESdata.Length,IESdata.Width]);
    numSplit = ceil(maxDim/newMax);
    if minDim > 1
        %split up in to rectangle
        fact = arrayfun(@factor,numSplit,'UniformOutput',false);
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
        ratio = zeros(size(countArr,1),1);
        for i = 1:size(countArr,1)
            ratio(i) = max(countArr(i,:))/min(countArr(i,:));
        end
        [~ ,closestIndex] = min(abs(ratio-(maxDim/minDim)));
        if index == 1
            uSplit = countArr(closestIndex,1);
            vSplit = countArr(closestIndex,2);
        else
            uSplit = countArr(closestIndex,2);
            vSplit = countArr(closestIndex,1);
        end
        uPrime = zeros(uSplit,vSplit);
        vPrime = zeros(uSplit,vSplit);
        for u = 1:uSplit
            for v = 1:vSplit
                uPrime(u,v) = (((2*u -1)*IESdata.Length)/(2*uSplit))-(IESdata.Length/2);
                vPrime(u,v) = (((2*v -1)*IESdata.Width)/(2*vSplit))-(IESdata.Width/2);
            end
        end
    else
        %split in to line
        if index == 1
            uPrime = zeros(numSplit,1);
            vPrime = zeros(numSplit,1);
            for u = 1:numSplit
                for v = 1
                    uPrime(u,v) = (((2*u -1)*IESdata.Length)/(2*numSplit))-(IESdata.Length/2);
                    vPrime(u,v) = (((2*v -1)*IESdata.Width)/(2*1))-(IESdata.Width/2);
                end
            end
        else
            uPrime = zeros(1,numSplit);
            vPrime = zeros(1,numSplit);
            for u = 1
                for v = 1:numSplit
                    uPrime(u,v) = (((2*u -1)*IESdata.Length)/(2*1))-(IESdata.Length/2);
                    vPrime(u,v) = (((2*v -1)*IESdata.Width)/(2*numSplit))-(IESdata.Width/2);
                end
            end
        end
    end
    newIES = IESdata;
    newIES.photoTable = newIES.photoTable/numSplit;
    uPrime = uPrime(:);
    vPrime = vPrime(:);
    newXLocation = [];
    newYLocation = [];
    for i = 1:length(xLocations)
        newXLocation = [newXLocation,(uPrime'+xLocations(i))];
        newYLocation = [newYLocation,(vPrime'+yLocations(i))];
    end
else
    newXLocation = xLocations;
    newYLocation = yLocations;
    newIES = IESdata;
end
end