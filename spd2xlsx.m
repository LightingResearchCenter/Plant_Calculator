%% RESET
fclose('all');
close all
clear
clc

%% Find files
day8 = '\\root\projects\IPH_PlantPathology\UV Pre-Inoculation Exp Feb 2017\Day 9 Reflection SPDs';
ls = dir(fullfile(day8,'*.txt'));
filePaths = fullfile(day8,{ls(:).name}');

%% Read files to tables
% Define format specs
formatSpecHeader = [repmat('%s ',1,415),'%s'];
formatSpecBody   = [repmat('%s ',1,415),'%s'];
% Iterate backwards through files
nFile = numel(filePaths);
for iFile = nFile:-1:1
    thisPath = filePaths{iFile};
    fid = fopen(thisPath);
    thisHeader = textscan(fid, formatSpecHeader, 1, 'Delimiter', '\t');
    thisBody   = textscan(fid, formatSpecBody,   1, 'Delimiter', '\t');
    fclose(fid);
    % Iterate backwards through variables
    nVar = numel(thisBody);
    for iVar = nVar:-1:1
        % Extract nested cell information
        C{iFile+1,iVar} = thisBody{1,iVar}{1};
    end
end
% Iterate backwards through variable names
nVar = numel(thisHeader);
for iVar = nVar:-1:1
    % Extract nested cell information
    C{iFile,iVar} = thisHeader{1,iVar}{1};
end

%% Write output to Excel
savePath = 'test.xlsx';
xlswrite(savePath,C')
winopen(savePath)