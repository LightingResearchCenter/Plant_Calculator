function rpt = makerpt(Data,rptname,rpttemplate)
clc
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
open(rpt);
%% Format Catalog and Cost
[outputArr] = formatCatalogCost(Data);
%% Calculate LSAE
minMount = 1*unitsratio('m','ft');
maxMount = 8*unitsratio('m','ft');
stepMount = 1*unitsratio('m','ft');
targetMounts = minMount:stepMount:maxMount;
minPPFD = 100;
maxPPFD = 500;
stepPPFD = 100;
targetPPFDs = [minPPFD:stepPPFD:maxPPFD,1000];
targetUni = .8;
roomLength = unitsratio('m','ft')*36;%feet
roomWidth = unitsratio('m','ft')*30;%feet
calcSpacing = .25;
[~,Data.outTable,Data.LSAE] = fullLSAE(Data.spd,Data.ies,targetMounts,targetPPFDs,targetUni,roomLength,roomWidth,calcSpacing);
%% generate economic section
% [Data] = CalculateEconomics(Data);
%% Plot SPD
plotSPD(Data.Spectrum,fullfile('images','SPDPlotPic.tif'));
%% Plot Iso-PPFD contour Plot
LSAEcol = reshape(Data.LSAE,[],1);
[~,ind] = max(LSAEcol);
if mod(ind,8) == 0
    mount = 8*unitsratio('m','ft');
else
    mount = mod(ind,8)*unitsratio('m','ft');
end
PlotWidth = 4; %ft
plotISOppfd(Data.Spectrum,Data.IESdata,mount,PlotWidth,fullfile('images','ISOPlotPic.tif'));
%% Color Uniformity Plot
plotColorUni(Data.Spectrum,Data.IESfiles,fullfile('images','ColorPlotPic.tif'));
%% Plot Intensity Distribution
plotIntensityDist(Data.IESfiles,fullfile('images','IntentPlotPic.tif'));
%% PlotPPFD
plotPPDF(Data)
%% PlotPPFDperW
plotPPDFperW(Data)
%% input to PDF
sect = rpt.CurrentPageLayout;
for i = 1:numel(sect.PageFooters)
    pageFooter = sect.PageFooters(i);
    while ~strcmp(pageFooter.CurrentHoleId,'#end#')
        switch pageFooter.CurrentHoleId
            case 'RPIlogo'
                imgObj = Image('images\rpiLogo.png');
                imgObj.Style = {Height('0.4in')};
                append(pageFooter,imgObj);
            case 'GenTime'
                date = datestr(now,'yyyy mmmm dd');
                append(pageFooter,date);
            case 'NRCanLogo'
                imgObj = Image('images\NRCan-logo1024x512.png');
                imgObj.Style = {Height('0.4in')};
                append(pageFooter,imgObj);
            case 'LRCLogo'
                imgObj = Image('images\lrcLogo.png');
                imgObj.Style = {Height('0.4in')};
                append(pageFooter,imgObj);
            case 'LEAlogo'
                imgObj = Image('images\LightingEnergyAlliance_Logo0_27_133.png');
                imgObj.Style = {Height('0.4in')};
                append(pageFooter,imgObj);
        end
        moveToNextHole(pageFooter);
    end
end
index = 1;
while ~strcmp(rpt.CurrentHoleId,'#end#')
    
    switch rpt.CurrentHoleId
        case '#sect2#'
            sect = rpt.CurrentPageLayout;
            
            for i = 1:numel(sect.PageFooters)
                
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'RPIlogo'
                            imgObj = Image(fullfile('images','rpiLogo.png'));
                            imgObj.Style = {Height('0.4in')};
                            append(pageFooter,imgObj);
                        case 'GenTime'
                            date = datestr(now,'yyyy mmmm dd');
                            append(pageFooter,date);
                        case 'NRCanLogo'
                            imgObj = Image(fullfile('images','NRCan-logo1024x512.png'));
                            imgObj.Style = {Height('0.4in')};
                            append(pageFooter,imgObj);
                        case 'LRCLogo'
                            imgObj = Image(fullfile('images','lrcLogo.png'));
                            imgObj.Style = {Height('0.4in')};
                            append(pageFooter,imgObj);
                        case 'LEAlogo'
                            imgObj = Image(fullfile('images','LightingEnergyAlliance_Logo0_27_133.png'));
                            imgObj.Style = {Height('0.4in')};
                            append(pageFooter,imgObj);
                    end
                    moveToNextHole(pageFooter);
                    
                end
            end
            
        case 'IntenDistImg'
            imgObj = Image(fullfile('images','IntentPlotPic.tif'));
            imgObj.Style = {Height('3.5in')};
            append(rpt,imgObj);
        case 'ColorDistImg'
            imgObj = Image(fullfile('images','ColorPlotPic.tif'));
            imgObj.Style = {Height('3.5in')};
            append(rpt,imgObj);
        case 'LSAE11'
            A_str = sprintf('%0.2f',Data.LSAE(1,1));
            if Data.LSAE(1,1)==max(Data.LSAE(:,1))
                if Data.LSAE(1,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE12'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE13'
            A_str = sprintf('%0.2f',Data.LSAE(1,2));
            if Data.LSAE(1,2)==max(Data.LSAE(:,2))
                if Data.LSAE(1,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE14'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE15'
            A_str = sprintf('%0.2f',Data.LSAE(1,3));
            if Data.LSAE(1,3)==max(Data.LSAE(:,3))
                if Data.LSAE(1,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE16'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE17'
            A_str = sprintf('%0.2f',Data.LSAE(1,4));
            if Data.LSAE(1,4)==max(Data.LSAE(:,4))
                if Data.LSAE(1,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE18'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE19'
            A_str = sprintf('%0.2f',Data.LSAE(1,5));
            if Data.LSAE(1,5)==max(Data.LSAE(:,5))
                if Data.LSAE(1,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE10'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE21'
            A_str = sprintf('%0.2f',Data.LSAE(2,1));
            if Data.LSAE(2,1)==max(Data.LSAE(:,1))
                if Data.LSAE(2,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE22'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE23'
            A_str = sprintf('%0.2f',Data.LSAE(2,2));
            if Data.LSAE(2,2)==max(Data.LSAE(:,2))
                if Data.LSAE(2,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE24'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE25'
            A_str = sprintf('%0.2f',Data.LSAE(2,3));
            if Data.LSAE(2,3)==max(Data.LSAE(:,3))
                if Data.LSAE(2,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE26'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE27'
            A_str = sprintf('%0.2f',Data.LSAE(2,4));
            if Data.LSAE(2,4)==max(Data.LSAE(:,4))
                if Data.LSAE(2,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE28'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE29'
            A_str = sprintf('%0.2f',Data.LSAE(2,5));
            if Data.LSAE(2,5)==max(Data.LSAE(:,5))
                if Data.LSAE(2,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE20'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE31'
            A_str = sprintf('%0.2f',Data.LSAE(3,1));
            if Data.LSAE(3,1)==max(Data.LSAE(:,1))
                if Data.LSAE(3,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE32'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE33'
            A_str = sprintf('%0.2f',Data.LSAE(3,2));
            if Data.LSAE(3,2)==max(Data.LSAE(:,2))
                if Data.LSAE(3,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE34'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE35'
            A_str = sprintf('%0.2f',Data.LSAE(3,3));
            if Data.LSAE(3,3)==max(Data.LSAE(:,3))
                if Data.LSAE(3,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE36'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE37'
            A_str = sprintf('%0.2f',Data.LSAE(3,4));
            if Data.LSAE(3,4)==max(Data.LSAE(:,4))
                if Data.LSAE(3,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE38'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE39'
            A_str = sprintf('%0.2f',Data.LSAE(3,5));
            if Data.LSAE(3,5)==max(Data.LSAE(:,5))
                if Data.LSAE(3,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE30'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE41'
            A_str = sprintf('%0.2f',Data.LSAE(4,1));
            if Data.LSAE(4,1)==max(Data.LSAE(:,1))
                if Data.LSAE(4,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE42'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE43'
            A_str = sprintf('%0.2f',Data.LSAE(4,2));
            if Data.LSAE(4,2)==max(Data.LSAE(:,2))
                if Data.LSAE(4,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE44'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE45'
            A_str = sprintf('%0.2f',Data.LSAE(4,3));
            if Data.LSAE(4,3)==max(Data.LSAE(:,3))
                if Data.LSAE(4,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE46'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE47'
            A_str = sprintf('%0.2f',Data.LSAE(4,4));
            if Data.LSAE(4,4)==max(Data.LSAE(:,4))
                if Data.LSAE(4,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE48'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE49'
            A_str = sprintf('%0.2f',Data.LSAE(4,5));
            if Data.LSAE(4,5)==max(Data.LSAE(:,5))
                if Data.LSAE(4,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE40'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE51'
            A_str = sprintf('%0.2f',Data.LSAE(5,1));
            if Data.LSAE(5,1)==max(Data.LSAE(:,1))
                if Data.LSAE(5,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE52'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE53'
            A_str = sprintf('%0.2f',Data.LSAE(5,2));
            if Data.LSAE(5,2)==max(Data.LSAE(:,2))
                if Data.LSAE(5,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE54'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE55'
            A_str = sprintf('%0.2f',Data.LSAE(5,3));
            if Data.LSAE(5,3)==max(Data.LSAE(:,3))
                if Data.LSAE(5,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE56'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE57'
            A_str = sprintf('%0.2f',Data.LSAE(5,4));
            if Data.LSAE(5,4)==max(Data.LSAE(:,4))
                if Data.LSAE(5,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE58'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE59'
            A_str = sprintf('%0.2f',Data.LSAE(5,5));
            if Data.LSAE(5,5)==max(Data.LSAE(:,5))
                if Data.LSAE(5,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE50'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE61'
            A_str = sprintf('%0.2f',Data.LSAE(6,1));
            if Data.LSAE(6,1)==max(Data.LSAE(:,1))
                if Data.LSAE(6,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE62'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE63'
            A_str = sprintf('%0.2f',Data.LSAE(6,2));
            if Data.LSAE(6,2)==max(Data.LSAE(:,2))
                if Data.LSAE(6,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE64'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE65'
            A_str = sprintf('%0.2f',Data.LSAE(6,3));
            if Data.LSAE(6,3)==max(Data.LSAE(:,3))
                if Data.LSAE(6,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE66'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE67'
            A_str = sprintf('%0.2f',Data.LSAE(6,4));
            if Data.LSAE(6,4)==max(Data.LSAE(:,4))
                if Data.LSAE(6,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE68'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE69'
            A_str = sprintf('%0.2f',Data.LSAE(6,5));
            if Data.LSAE(6,5)==max(Data.LSAE(:,5))
                if Data.LSAE(6,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE60'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE71'
            A_str = sprintf('%0.2f',Data.LSAE(7,1));
            if Data.LSAE(7,1)==max(Data.LSAE(:,1))
                if Data.LSAE(7,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE72'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE73'
            A_str = sprintf('%0.2f',Data.LSAE(7,2));
            if Data.LSAE(7,2)==max(Data.LSAE(:,2))
                if Data.LSAE(7,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE74'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE75'
            A_str = sprintf('%0.2f',Data.LSAE(7,3));
            if Data.LSAE(7,3)==max(Data.LSAE(:,3))
                if Data.LSAE(7,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE76'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE77'
            A_str = sprintf('%0.2f',Data.LSAE(7,4));
            if Data.LSAE(7,4)==max(Data.LSAE(:,4))
                if Data.LSAE(7,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE78'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE79'
            A_str = sprintf('%0.2f',Data.LSAE(7,5));
            if Data.LSAE(7,5)==max(Data.LSAE(:,5))
                if Data.LSAE(7,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE70'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE81'
            A_str = sprintf('%0.2f',Data.LSAE(8,1));
            if Data.LSAE(8,1)==max(Data.LSAE(:,1))
                if Data.LSAE(8,1)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE82'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE83'
            A_str = sprintf('%0.2f',Data.LSAE(8,2));
            if Data.LSAE(8,2)==max(Data.LSAE(:,2))
                if Data.LSAE(8,2)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE84'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE85'
            A_str = sprintf('%0.2f',Data.LSAE(8,3));
            if Data.LSAE(8,3)==max(Data.LSAE(:,3))
                if Data.LSAE(8,3)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE86'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE87'
            A_str = sprintf('%0.2f',Data.LSAE(8,4));
            if Data.LSAE(8,4)==max(Data.LSAE(:,4))
                if Data.LSAE(8,4)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE88'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'LSAE89'
            A_str = sprintf('%0.2f',Data.LSAE(8,5));
            if Data.LSAE(8,5)==max(Data.LSAE(:,5))
                if Data.LSAE(8,5)==max(max(Data.LSAE))
                    append(rpt,A_str,'LSAEMax');
                else
                    append(rpt,A_str,'greyBack');
                end
            else
                append(rpt,A_str);
            end
        case 'LSAE80'
            append(rpt,length(Data.outTable.count{index}));index=index+1;
        case 'ISOPPFDpic'
            imgObj = Image(fullfile('images','ISOPlotPic.tif'));
            imgObj.Style = {Height('2.8in')};
            append(rpt,imgObj);
        case 'MountHeight'
            append(rpt,mount);
        case 'SPDpic'
            imgObj = Image(fullfile('images','SPDPlotPic.tif'));
            imgObj.Style = {Width('3in')};
            append(rpt,imgObj);
        case 'THD'
            [~, A_str] = sd_round(Data.THD,2);
            append(rpt,A_str{:});
        case 'PPFper'
            [~, A_str] = sd_round(Data.PPFofTotal,2);
            append(rpt,A_str{:});
        case 'PF'
            [~, A_str] = sd_round(Data.PowerFactor,3);
            append(rpt,A_str{:});
        case 'RCR'
            [~, A_str] = sd_round(Data.RCR,2);
            append(rpt,A_str{:});
        case 'YPFperW'
            [~, A_str] = sd_round((Data.YPF/Data.Wattage),3);
            append(rpt,A_str{:});
        case 'PPFperW'
            [~, A_str] = sd_round((Data.PPF/Data.Wattage),3);
            append(rpt,A_str{:});
        case 'Power'
            A_str = num2str(round(Data.Wattage));
            append(rpt,A_str);
        case 'FixtureImg'
            imgObj = Image(Data.ImagePath);
            imgObj.Style = {Height('.7in')};
            append(rpt,imgObj);
        case 'PSS'
            [~, A_str] = sd_round(Data.PSS,2);
            append(rpt,A_str{:});
        case 'YPF'
            [~, A_str] = sd_round(Data.YPF,3);
            append(rpt,A_str{:});
        case 'PPF'
            [~, A_str] = sd_round(Data.PPF,3);
            append(rpt,A_str{:});
        case 'Voltage'
            A_str = num2str(round(Data.Voltage));
            append(rpt,A_str);
        case 'Brand1'
            append(rpt,outputArr{1});
        case 'Brand2'
            append(rpt,outputArr{2});
        case 'Brand3'
            append(rpt,outputArr{3});
        case 'Brand4'
            append(rpt,outputArr{4});
        case 'Cost'
            A_str = ['$',num2str(round(Data.Cost))];
            append(rpt,A_str);
        case 'Product'
            append(rpt,Data.Product);
        case 'Manufac'
            append(rpt,Data.Brand);
        case 'energyCost'
            %TODO energyCost
        case 'HPS600Pay'
            %TODO HPS600Pay
        case 'HPS600PayStr'
            %TODO HPS600PayStr
        case 'HPS1000Pay'
            %TODO HPS1000Pay
        case 'HPS1000PayStr'
            %TODO HPS1000PayStr
        case 'HPS600Save'
            %TODO HPS600Save
        case 'Lamp'
            append(rpt,Data.Lamp);
        case 'HPS1000Save'
            %TODO HPS1000Save
        case 'LampCostFtyear'
            %TODO LampCostFtyear
        case 'HPS600CostFtyear'
            %TODO HPS600CostFtyear
        case 'HPS1000CostFtyear'
            %TODO HPS1000CostFtyear
        case 'LampCostMyear'
            %TODO LampCostMyear
        case 'HPS600CostMyear'
            %TODO HPS600CostMyear
        case 'HPS1000CostMyear'
            %TODO HPS1000CostMyear
        case 'LampkWFtyear'
            %TODO LampkWFtyear
        case 'HPS600kWFtyear'
            %TODO HPS600kWFtyear
        case 'HPS1000kWFtyear'
            %TODO HPS1000kWFtyear
        case 'LampkWMyear'
            %TODO LampkWMyear
        case 'HPS600kWMyear'
            %TODO HPS600kWMyear
        case 'HPS1000kWMyear'
            %TODO HPS1000kWMyear
        case 'LampWFt'
            %TODO LampWFt
        case 'HPS600WFt'
            %TODO HPS600WFt
        case 'LampWM'
            %TODO LampWM
        case 'HPS600WM'
            %TODO HPS600WM
        case 'HPS1000WFt'
            %TODO HPS1000WFt
        case 'HPS1000WM'
            %TODO HPS1000WM
        case 'LampCostFt'
            %TODO LampCostFt
        case 'HPS600CostFt'
            %TODO HPS600CostFt
        case 'HPS1000CostFt'
            %TODO HPS1000CostFt
        case 'LampCostM'
            %TODO LampCostM
        case 'HPS600CostM'
            %TODO HPS600CostM
        case 'HPS1000CostM'
            %TODO HPS1000CostM
        case 'Lampinit'
            %TODO Lampinit
        case 'HPS600init'
            %TODO HPS600init
        case 'HPS1000init'
            %TODO HPS1000init
        case 'Lampqty'
            %TODO Lampqty
        case 'HPS600qty'
            %TODO HPS600qty
        case 'HPS1000qty'
            %TODO HPS1000qty
    end
    moveToNextHole(rpt);
end
close(rpt);
rptview(rpt.OutputPath);
end
%% internal functions
function [outputArr] = formatCatalogCost(Data)
str = Data.Catalog;
words_in_str = textscan(str,'%s');
strArr = words_in_str{1};
outputArr = cell(4,1);
wordIndex = 1;
for i=1:length(strArr)
    if wordIndex<=3
        if (length(outputArr{wordIndex})+length(strArr{i})) > 20
            index = wordIndex+1;
            outputArr{wordIndex} = [strArr{i},' '];
        else
            outputArr{wordIndex} = [ outputArr{wordIndex}, strArr{i},' '];
        end
    end
end
outputArr{index+1} = ['$',num2str(round(Data.Cost))];
outputArr(cellfun('isempty',outputArr))={' '};
end




