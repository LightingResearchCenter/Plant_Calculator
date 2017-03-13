function [T] = writeSPDExcelFile(inputpath,outputpath,outputname)
%t = writeSPDExcelFile('\\root\projects\IPH_PlantPathology\UV Pre-Inoculation Exp Feb 2017\Day7 Reflection SPDs','output','030817 Minulta SPD')
folder = inputpath;
list = dir(folder);
path = cell(1,length(list));
name = cell(1,length(list));
ext = cell(1,length(list));
for i1 = 1:length(list)
    [path{i1},name{i1},ext{i1}] = fileparts([folder,'\',list(i1).name]);
    if ~strcmpi(ext{i1},'.txt')
        path{i1} ='';
        name{i1} = '';
        ext{i1} ='';
    end
end
path(strcmp('',path)) = [];
name(strcmp('',name)) = [];
ext(strcmp('',ext)) = [];
T = [];
for i2 = 1:length(name)
   opts = detectImportOptions([path{i2},'\',name{i2},ext{i2}]);
   temp = readtable([path{i2},'\',name{i2},ext{i2}],opts);
   T = [T;temp];
end

writetable(T,fullfile(outputpath,[outputname,'.xlsx']));
end
