function [maxCount, maxArrangement] = findMaxArrangment(IESData,roomLength,roomWidth)
%% Define Variables
fixLength = IESData.LengthFt; %feet
fixWidth = IESData.WidthFt; %feet
maxDim = max([fixLength,fixWidth]);
minDim = min([fixLength,fixWidth]);
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
%% Determine Arrangement
if isLinear
    % Arrangement will only use Long Mount and can double and triple up
    maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
    leftOverSpace = (longMountLength - (maxPerRun * maxDim))/maxPerRun;
    maxPerSide = 3;
    maxCount = (maxPerRun*(longMountCount*maxPerSide));
    index = 1;
    fixtureCenters = zeros(maxCount,2);
    fixStart = (leftOverSpace/2)+(maxDim/2);
    fixtureCenters(index,:) = [longMount(1),fixStart];
    index = index+1;
    fixtureCenters(index,:) = [longMount(2),fixStart];
    index = index+1;
    fixtureCenters(index,:) = [longMount(3),fixStart];
    index = index+1;
    for i = 2:maxPerRun
        lastFix = fixtureCenters(index-1,2);
        fixStart = lastFix+(maxDim+leftOverSpace);
        fixtureCenters(index,:) = [longMount(1),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(2),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(3),fixStart];
        index = index+1;
    end
    maxArrangement = fixtureCenters;
else
    if fixLength == fixWidth
        % Arangement won't change if fixture is rotated
        maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
        leftOverSpaceX = (longMountLength - (maxPerRun * maxDim))/maxPerRun;
        maxPerSide = floor(((longMountInc-minDim)/2)/minDim);
        leftOverSpaceY = ((longMountInc-minDim)/2 - (maxPerSide * minDim))/maxPerSide;
        maxCount = (maxPerRun*(longMountCount*maxPerSide));
        index = 1;
        fixtureCenters = zeros(maxCount,2);
        fixStart = (leftOverSpaceX/2)+(maxDim/2);
        fixtureCenters(index,:) = [longMount(1),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(2),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(3),fixStart];
        index = index+1;
        for i2 = 1:maxPerSide
            fixtureCenters(index,:) = [longMount(1)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(1)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
        end
        for i = 2:maxPerRun
            lastFix = fixtureCenters(index-1,2);
            fixStart = lastFix+(maxDim+leftOverSpaceX);
            for i2 = 1:maxPerSide
                fixtureCenters(index,:) = [longMount(1),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(1)-(minDim*i2+leftOverSpaceY*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)-(minDim+leftOverSpaceY)*i2,fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)-(minDim+leftOverSpaceY)*i2,fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(1)+(minDim+leftOverSpaceY)*i2,fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)+(minDim+leftOverSpaceY)*i2,fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)+(minDim+leftOverSpaceY)*i2,fixStart];
                index = index+1;
            end
        end
        plotArrangement(fixtureCenters,maxDim,minDim,roomLength,roomWidth);
        maxArrangement = fixtureCenters;
    else
        % Arrangement will change if fixture is rotated
        % (1) based off of length being parrallel to system
        % (2) based off of width being parrallel to system
        % LSAE will compaire both and determing the best match based off of
        % uniformity.
        maxDim = fixLength;
        minDim = fixWidth;
        maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
        leftOverSpaceX = (longMountLength - (maxPerRun * maxDim))/maxPerRun;
        maxPerSide = floor(((longMountInc-minDim)/2)/minDim);
        leftOverSpaceY = ((longMountInc-minDim)/2 - (maxPerSide * minDim))/(maxPerSide);
        maxCount(1) = (maxPerRun*(longMountCount*maxPerSide));
        index = 1;
        fixtureCenters = zeros(maxCount,2);
        fixStart = (leftOverSpaceX/2)+(maxDim/2);
        fixtureCenters(index,:) = [longMount(1),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(2),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(3),fixStart];
        index = index+1;
        for i2 = 1:maxPerSide
            fixtureCenters(index,:) = [longMount(1)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(1)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
        end
         for i = 2:maxPerRun
            lastFix = fixtureCenters(index-1,2);
            fixStart = lastFix+(maxDim+leftOverSpaceX);
            fixtureCenters(index,:) = [longMount(1),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3),fixStart];
            index = index+1;
            for i2 = 1:maxPerSide
                fixtureCenters(index,:) = [longMount(1)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(1)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
            end
        end
        plotArrangement(fixtureCenters,maxDim,minDim,roomLength,roomWidth);
        maxArrangement{1} = fixtureCenters;
        maxDim = fixWidth;
        minDim = fixLength;
        maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
        leftOverSpaceX = (longMountLength - (maxPerRun * maxDim))/maxPerRun;
        maxPerSide = floor(((longMountInc-minDim)/2)/minDim);
        leftOverSpaceY = ((longMountInc-minDim)/2 - (maxPerSide * minDim))/(maxPerSide);
        maxCount(2) = (maxPerRun*(longMountCount*maxPerSide));
        index = 1;
        fixtureCenters = zeros(maxCount(2),2);
        fixStart = (leftOverSpaceX/2)+(maxDim/2);
        fixtureCenters(index,:) = [longMount(1),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(2),fixStart];
        index = index+1;
        fixtureCenters(index,:) = [longMount(3),fixStart];
        index = index+1;
        for i2 = 1:maxPerSide
            fixtureCenters(index,:) = [longMount(1)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)-((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(1)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3)+((minDim+leftOverSpaceY)*i2),fixStart];
            index = index+1;
        end
        for i = 2:maxPerRun
            lastFix = fixtureCenters(index-1,2);
            fixStart = lastFix+(maxDim+leftOverSpaceX);
            fixtureCenters(index,:) = [longMount(1),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(2),fixStart];
            index = index+1;
            fixtureCenters(index,:) = [longMount(3),fixStart];
            index = index+1;
            for i2 = 1:maxPerSide
                fixtureCenters(index,:) = [longMount(1)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)-((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(1)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(2)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
                fixtureCenters(index,:) = [longMount(3)+((minDim+leftOverSpaceY)*i2),fixStart];
                index = index+1;
            end
        end
        plotArrangement(fixtureCenters,maxDim,minDim,roomLength,roomWidth);
        maxArrangement{2} = fixtureCenters;
    end
end
end