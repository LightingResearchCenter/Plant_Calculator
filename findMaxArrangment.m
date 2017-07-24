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
    maxPerSide = 3;
    maxCount = (maxPerRun*(longMountCount*maxPerSide));
else
    if fixLength == fixWidth
        % Arangement won't change if fixture is rotated
        maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
        maxPerSide = floor(((longMountInc-minDim)/2)/minDim);
        maxCount = (maxPerRun*(longMountCount*3))+((maxPerSide*maxPerRun)*(2*longMountCounts));
    else
        % Arrangement will change if fixture is rotated
        % (1) based off of length being parrallel to system
        % (2) based off of width being parrallel to system
        % LSAE will compaire both and determing the best match based off of
        % uniformity.
        maxPerRun = floor(longMountLength/maxDim); %how many fit on a run
        maxPerSide = floor(((longMountInc-minDim)/2)/minDim);
        maxCount = (maxPerRun*(longMountCount*3))+((maxPerSide*maxPerRun)*(2*longMountCounts));
        
    end
end
end