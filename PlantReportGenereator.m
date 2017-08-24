function filledTable =PlantReportGenereator(loc,path)
tbl = readtable(fullfile(loc,path));
tbl.Properties.VariableNames{1} = 'LRCID';
tbl.Properties.VariableNames{4} = 'Catalog';
tbl.Properties.VariableNames{5} = 'Product';
tbl.Properties.VariableNames{8} = 'Wattage';
tbl.Properties.VariableNames{13} = 'IES';
if ~exist(fullfile(pwd,'images'),'dir')
    mkdir(fullfile(pwd,'images'));
end
load('ppfdata.mat')

if ~exist(fullfile(loc,'Plant Reports'),'dir')
        mkdir(fullfile(loc,'Plant Reports'));
end
for i = 1:height(tbl)
    Data = table2struct(tbl(i,:));
    Data.spectrum = load(Data.SPD);
    Data.wave = Data.spectrum(:,1);
    Data.specFlux = Data.spectrum(:,2);
    Data.IESdata = IESFile(Data.IES);
    Data = calcAllMetrics(Data);
    Data = formatCatalogCost(Data);

    index = (Data.spectrum(:,1)<700)&(Data.spectrum(:,1)>400);
    Data.PPFofTotal = (sum(Data.spectrum(index,2))/sum(Data.spectrum(:,2)))*100;
    Data.PPFRank = fullfile('images',[sprintf('%d',Data.LRCID),'PPFPlotPic.png']);
    Data.PPFperWRank = fullfile('images',[sprintf('%d',Data.LRCID),'PPFperWPlotPic.png']);
    plotRank(Data.PPF,PPFmax,PPFmin,'{\it\phi_{p}} Range of Tested Horticultural Luminaires',Data.PPFRank);
    plotRank(Data.PPFperW,PPFperWmax,PPFperWmin,'{\itK_{p}} Range of Tested Horticultural Luminaires',Data.PPFperWRank);    
    Data.PlantReportFile = fullfile(loc,'Plant Reports',[sprintf('%d',Data.LRCID),'.pdf']);
    makerpt(Data, Data.PlantReportFile);
    filledTable(i) = Data;
end
%     tempTable(i) = Data;
% end
% tempTable = struct2table(tempTable);
% 
% % PPFmax = max(tempTable.PPF);
% % PPFmin = min(tempTable.PPF);
% % PPFperWmax = max(tempTable.PPFperW);
% % PPFperWmin = min(tempTable.PPFperW);
% 
% 
% for i = 1:height(tempTable)
%     Data =table2struct(tempTable(i,:));
%     index = (Data.spectrum(:,1)<700)&(Data.spectrum(:,1)>400);
%     Data.PPFofTotal = (sum(Data.spectrum(index,2))/sum(Data.spectrum(:,2)))*100;
%     Data.PPFRank = fullfile('images',[sprintf('%d',Data.LRCID),'PPFPlotPic.png']);
%     Data.PPFperWRank = fullfile('images',[sprintf('%d',Data.LRCID),'PPFperWPlotPic.png']);
%     plotRank(Data.PPF,PPFmax,PPFmin,'{\it\phi_{p}} Range of Tested Horticultural Luminaires',Data.PPFRank);
%     plotRank(Data.PPFperW,PPFperWmax,PPFperWmin,'{\itK_{p}} Range of Tested Horticultural Luminaires',Data.PPFperWRank);    
%     Data.PlantReportFile = fullfile(loc,'Plant Reports',[sprintf('%d',Data.LRCID),'.pdf']);
%     makerpt(Data, Data.PlantReportFile);
%     Data.PlantReportFile = fullfile(loc,'Plant Reports',[sprintf('%d',Data.LRCID),'.pdf']);
%     makerpt(Data, Data.PlantReportFile);
%     filledTable(i) = Data;
% end
filledTable = struct2table(filledTable);
save('datatable.mat','filledTable');
end

function Data = calcAllMetrics(Data)
h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant
PSSRCRtable = readtable('PSS_RCR.txt','Delimiter', '\t');

multiplier = max(Data.specFlux);
if multiplier == 1
    qstring = 'This SPD is already relative. Is there a known multiplier?';
    title = 'Multiplier?';
    str1 = 'Yes';
    str2 = 'No';
    default = str1;
    button = questdlg(qstring,title,str1,str2,default);
    switch button
        case str1
            prompt = {'Spectrum Multiplier:'};
            dlg_title = 'Multiplier';
            num_lines = 1;
            defaultans = {'.1687'};
            multip = inputdlg(prompt,dlg_title,num_lines,defaultans);
            multiplier = str2double(multip{1});
        case str2
            multiplier = max(Data.specFlux);
        otherwise
            error('There was an error entering the multiplier.');
    end
end
Data.multiplier = multiplier;
Data.specFluxRelative = Data.specFlux/Data.multiplier;

q1 = find(Data.wave>=400,1,'first');
q2 = find(Data.wave<=700,1,'last');

Data.PPF = 1e6*trapz(Data.wave(q1:q2),Data.specFlux(q1:q2).*...
    (Data.wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s
Data.PPFperW = Data.PPF/Data.Wattage;

q1 = find(Data.wave>=300,1,'first');
q2 = find(Data.wave<=800,1,'last');
sigmaRed = interp1(PSSRCRtable.lambda,PSSRCRtable.sigma_r,Data.wave,'linear',0.0);
sigmaFarRed = interp1(PSSRCRtable.lambda,PSSRCRtable.sigma_fr,Data.wave,'linear',0.0);
PSSRed = trapz(Data.wave(q1:q2),Data.specFlux(q1:q2).*sigmaRed(q1:q2).*...
    (Data.wave(q1:q2)*1e-9)/(h*c*Avo));
PSSFarRed = trapz(Data.wave(q1:q2),Data.specFlux(q1:q2).*sigmaFarRed(q1:q2).*...
    (Data.wave(q1:q2)*1e-9)/(h*c*Avo));
Data.PSS = PSSRed/(PSSRed + PSSFarRed);
Data.PSSperW = Data.PSS/Data.Wattage;
% Calculate LSAE
minMount = 1*unitsratio('m','ft');
maxMount = 8*unitsratio('m','ft');
stepMount = 1*unitsratio('m','ft');
targetMounts = minMount:stepMount:maxMount;
minPPFD = 100;
maxPPFD = 500;
stepPPFD = 100;
targetPPFDs = [minPPFD:stepPPFD:maxPPFD,1000];
targetUni = .6;
roomLength = 36;
roomWidth = 30;
roomLengthM = unitsratio('m','ft')*roomLength;%feet
roomWidthM = unitsratio('m','ft')*roomWidth;%feet
calcSpacing = .25;
LLF= [1,0.9,0.7,0.9];%N/a, HPS, LED, MH
switch Data.Source
    case 'HPS'
        Data.LampType = 2;
    case 'LED'
        Data.LampType = 3;
    case 'MH'
        Data.LampType = 4;
    otherwise
end
%N/a, HPS, LED, MH
[Data.IrrOut,Data.outTable,Data.LSAE] = fullLSAE(Data.SPD,Data.IES,...
    targetMounts,targetPPFDs,targetUni,roomLengthM,roomWidthM,calcSpacing,Data.LampType);
% generate economic section

Data.LCCA10Plot = fullfile('images',[sprintf('%d',Data.LRCID),'LCCA10.png']);
Data.LCCA20Plot= fullfile('images',[sprintf('%d',Data.LRCID),'LCCA20.png']);
Data.LCCALgnd = fullfile('images',[sprintf('%d',Data.LRCID),'LCCALgnd.png']);
[Data] = calculateEconomics(Data,roomLength,roomWidth, Data.LCCA10Plot, Data.LCCA20Plot, Data.LCCALgnd);
% Plot SPD
Data.SPDPlot = fullfile('images',[sprintf('%d',Data.LRCID),'SPDPlotPic.png']);
if ~isempty(Data.spectrum)
    plotSPD(Data.spectrum, Data.SPDPlot);
end
% Plot Iso-PPFD contour Plot
[~,Data.mount] = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==300));
PlotWidth = 4; %ft
Data.ISOPlot = fullfile('images',[sprintf('%d',Data.LRCID),'ISOPlotPic.png']);
centers = [PlotWidth/2,PlotWidth/2,0];
plotISOppfd(Data.spectrum,Data.IESdata,PlotWidth,Data.mount,centers,LLF(Data.LampType),Data.ISOPlot);
% Color Uniformity Plot
Data.SPDthetaPlot = fullfile('images',[sprintf('%d',Data.LRCID),'SPDTheta.png']);
if ~isempty(Data.angularSPD)
    Data = plotSPDtheta(Data,Data.SPDthetaPlot);
else
    Data.UVaPer = zeros(1,6);
    Data.bluePer = zeros(1,6);
    Data.redPer = zeros(1,6);
    Data.FRPer = zeros(1,6);
    Data.blueRed = zeros(1,6);
    Data.redFR = zeros(1,6);
end
% Plot Intensity Distribution
Data.IntensityDistplot = fullfile('images',[sprintf('%d',Data.LRCID),'IntentPlotPic.png']);
if ~isempty(Data.IESdata)
    plotIntensityDist(Data.IESdata,Data.multiplier,Data.IntensityDistplot);
end
end

function Data = formatCatalogCost(Data)
if Data.LRCID==110106
    disp(110106)
end
str = Data.Catalog;
words_in_str = textscan(str,'%s');
strArr = words_in_str{:};
outputArr = cell(4,1);
wordIndex = 1;
for i=1:numel(strArr)
    words_in_str = textscan(strArr{i},'%s','Delimiter',{'-'});
    str2Arr = words_in_str{:};
    for i2=1:numel(str2Arr)
        if wordIndex<=3
            if (length(outputArr{wordIndex})+length(str2Arr{i2})) > 23
                wordIndex = wordIndex+1;
                if numel(str2Arr)~=i2
                    outputArr{wordIndex} = [str2Arr{i2},'-'];
                else
                    outputArr{wordIndex} = [str2Arr{i2}];
                end
            else
                if numel(str2Arr)~=i2
                    outputArr{wordIndex} = [outputArr{wordIndex}, str2Arr{i2},'-'];
                else
                    outputArr{wordIndex} = [outputArr{wordIndex}, str2Arr{i2}];
                end
            end
        end
    end
    outputArr{wordIndex} = [outputArr{wordIndex}, ' '];
end
outputArr{wordIndex+1} = ['$',num2str(round(Data.Price))];
outputArr(cellfun('isempty',outputArr))={' '};
myfunc2 = @(x) strip(x,'right',' ');
outputArr = cellfun(myfunc2,outputArr,'UniformOutput',0);
outputArr(cellfun('isempty',outputArr))={' '};

Data.CatalogArr = outputArr;

end