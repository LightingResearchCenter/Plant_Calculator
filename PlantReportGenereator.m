function tbl =PlantReportGenereator()
[path,loc]=uigetfile();
tbl = readtable(fullfile(loc,path));
end