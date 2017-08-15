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
while ~strcmp(rpt.CurrentHoleId,'#end#')
    switch rpt.CurrentHoleId
        case 'Manufac'
            append(rpt,'need');
        case 'Product'
            append(rpt,'need');
        case 'Brand1'
            append(rpt,'need');
        case 'Voltage'
            append(rpt,'need');
        case 'PPF'
            %append(rpt,'need');
        case 'YPF'
            append(rpt,'need');
        case 'PSS'
            append(rpt,'need');
        case 'FixtureImg'
            append(rpt,'need');
        case 'Brand2'
            append(rpt,'need');
        case 'Power'
            append(rpt,'need');
        case 'PPFperW'
            append(rpt,'need');
        case 'YPFperW'
            append(rpt,'need');
        case 'RCR'
            append(rpt,'need');
        case 'Brand3'
            append(rpt,'need');
        case 'PF'
            append(rpt,'need');
        case 'PPFper'
            append(rpt,'need');
        case 'Brand4'
            append(rpt,'need');
        case 'THD'
            append(rpt,'need');
        case 'PPFRank'
            append(rpt,'need');
        case 'PPFDRank'
            append(rpt,'need');
        case 'Lamp2'
            append(rpt,'need');
        case 'MountHeight'
            append(rpt,'need');
        case 'ISOPPFDpic'
            append(rpt,'need');
        case 'IntenDistImg'
            append(rpt,'need');
        case 'SPDpic'
            append(rpt,'need');
        case 'SPDpic2'
            append(rpt,'need');
        case 'SPDTheataPlot'
            append(rpt,'need');
        case 'Costpic1'
            append(rpt,'need');
        case '#start#'
            sect = rpt.CurrentPageLayout;
            for i = 1:numel(sect.PageFooters)
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'GenTime'
                            date = datestr(now,'yyyy mmmm dd');
                            append(pageFooter,date);
                        otherwise
                            disp(pageFooter.CurrentHoleId);
                    end
                    moveToNextHole(pageFooter);
                end
            end
            
        case '#sect2#'
            sect = rpt.CurrentPageLayout;
            for i = 1:numel(sect.PageFooters)
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'GenTime'
                            date = datestr(now,'yyyy mmmm dd');
                            append(pageFooter,date);
                        otherwise
                            disp(pageFooter.CurrentHoleId);
                    end
                    moveToNextHole(pageFooter);
                end
            end
            
        case 'Eco01'
            EcoIndex = 1;
            append(rpt,EcoIndex);
            EcoIndex =EcoIndex +1;
            while EcoIndex<32
                moveToNextHole(rpt);
                append(rpt,EcoIndex);
                EcoIndex =EcoIndex +1;
            end
        case 'LSAE101'
            lsaeIndex = 1;
            append(rpt,lsaeIndex);
            moveToNextHole(rpt);
            append(rpt,lsaeIndex);
            lsaeIndex =lsaeIndex +1;
            while lsaeIndex<49
                moveToNextHole(rpt);
                append(rpt,lsaeIndex);
                moveToNextHole(rpt);
                append(rpt,lsaeIndex);
                lsaeIndex =lsaeIndex +1;
                
            end
        case 'ratio11'
            ratioIndex = 1;
            append(rpt,ratioIndex);
            ratioIndex =ratioIndex +1;
            while ratioIndex<37
                moveToNextHole(rpt);
                append(rpt,ratioIndex);
                ratioIndex =ratioIndex +1;
                
            end
        otherwise
            disp(rpt.CurrentHoleId);
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




