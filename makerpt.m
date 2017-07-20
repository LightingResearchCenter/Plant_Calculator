function rpt = makerpt(Data,rptname,rpttemplate)
clc
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
open(rpt);

sect = rpt.CurrentPageLayout;
LRCBlue = [ 30,  63, 134]/255;
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

%% Format Catalog and Cost
str = Data.Catalog;
words_in_str = textscan(str,'%s');
strArr = words_in_str{1};
outputArr = cell(4,1);
index = 1;
for i=1:length(strArr)
    if index<=3
        if (length(outputArr{index})+length(strArr{i})) > 20
            index = index+1;
            outputArr{index} = [strArr{i},' '];
        else
            outputArr{index} = [ outputArr{index}, strArr{i},' '];
        end
    end
end

outputArr{index+1} = ['$',num2str(round(Data.Cost))];
outputArr(cellfun('isempty',outputArr))={' '};

%% Calculate LSAE
minMount = 0.5;
maxMount = 4.0;
stepMount = 0.5;
minPPFD = 100;
maxPPFD = 500;
stepPPFD = 100;
targetUni = 3;
roomLength = 10;
roomWidth = 10;
[~,outTable,LSAE] = fullLSAE(Data.spd,Data.ies,minMount:stepMount:maxMount,minPPFD:stepPPFD:maxPPFD,targetUni,roomLength,roomWidth);
Data.LSAE = LSAE;
Data.outTable = outTable;

index = 1;

%% generate economic section

%% Plot SPD 
SPDplot =figure('units','inches', 'Position',[0 0 3 3.5]);
set(SPDplot,'Renderer','painters');
set(SPDplot,'Resize','off');
SPDaxes = axes(SPDplot);
plot(SPDaxes,Data.Spectrum(:,1),...
    Data.Spectrum(:,2)/max(Data.Spectrum(:,2)),...
    'LineWidth',1);
axis(SPDaxes,[380,830,0,inf]);
ax = gca;
ax.FontSize = 8;
            
xlabel(SPDaxes,'Wavelength (nm)','FontSize',8,'FontWeight','Bold')
ylabel(SPDaxes,'Relative Spectrum (Arbitrary Units)','FontSize',8,'FontWeight','Bold')
SPDaxes.YGrid = 'On';
text(SPDaxes,400,.95,sprintf('(Absolute multiplier=%0.2f W/nm)',max(Data.Spectrum(:,2))),'FontSize',8);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2) + (.1*ti(2));
ax_width = outerpos(3) - ti(1) - ti(3) - (.1*ti(1));
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

saveas(SPDplot,'SPDPlotPic.tif')
RemoveWhiteSpace([], 'file', 'SPDPlotPic.tif');
close(SPDplot)

%% Plot Iso-PPFD contour Plot
ISOPlot =figure('units','inches', 'Position',[0 0 4 3]);
set(ISOPlot,'Renderer','painters');
set(ISOPlot,'Resize','off');
LSAEcol = reshape(Data.LSAE,[],1);
[~,ind] = max(LSAEcol);
if mod(ind,8) == 0
    mount = 4;
else
    mount = mod(ind,8)*0.5;
end
ConversionFactor = PPF_Conversion_Factor_05Apr2016(Data.Spectrum(:,1),Data.Spectrum(:,2));
calcSpacing = 0.125;
[Irr,~,~,~] = PPFCalculator(Data.IESdata,'MountHeight',mount,'Length',4,'Width',4,'LRcount',1,'TBcount',1,'calcSpacing',.125,'Multiplier',round(ConversionFactor,1));
plotLabels = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
plotMax = 4;
plotMin = 0;
plotSplits = size(plotLabels,1)-1;
X = (calcSpacing-(calcSpacing/2):calcSpacing:plotMax-(calcSpacing/2))';
Y = (calcSpacing-(calcSpacing/2):calcSpacing:plotMax-(calcSpacing/2));
ISOaxes = axes(ISOPlot);
            
[C,h] = contour(ISOaxes,X,Y,Irr,[25,50,100:100:500]);

ISOaxes.YTick =[plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
ISOaxes.YTickLabel = plotLabels;
ISOaxes.XTick = [plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
ISOaxes.XTickLabel = plotLabels;
ISOaxes.YLim = [plotMin,plotMax];
ISOaxes.XLim = [plotMin,plotMax];
ax = gca;
ax.FontSize = 8;
clabel(C,h,'FontSize',8);
axis(ISOaxes,'square');
ISOaxes.XGrid = 'on';
ISOaxes.YGrid = 'on';
ylabel(ISOaxes,'Meters','FontSize',8,'FontWeight','Bold')
xlabel(ISOaxes,'Meters','FontSize',8,'FontWeight','Bold')
colormap(ISOaxes,jet);
colorbar(ISOaxes);
caxis([0 500]);
fixX = (plotMax/2)-(Data.IESdata.Width*.5);
fixY = (plotMax/2)-(Data.IESdata.Length*0.5);
fixW = Data.IESdata.Width;
fixH = Data.IESdata.Length;
rectangle('Position',[fixX,fixY,fixW,fixH],'LineWidth',2);
align([ISOPlot,ISOaxes],'center','top');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2)+ (.1*ti(2));
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4)- (.2*ti(2));
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
saveas(ISOPlot,'ISOPlotPic.tif');
RemoveWhiteSpace([], 'file', 'ISOPlotPic.tif');
close(ISOPlot);
%% Color Uniformity Plot
ColorPlot = figure('units','inches', 'Position',[0 0 3.5 4]);
set(ColorPlot,'Renderer','painters');
set(ColorPlot,'Resize','off');
calcSpacing = 1/16;
if strcmpi(Data.Lamp,'LED')
    [xIrr,~,~,~] = PPFCalculator(Data.xBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing,'Color',0);
    [yIrr,~,~,~] = PPFCalculator(Data.yBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing,'Color',0);
    [zIrr,~,~,~] = PPFCalculator(Data.zBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing,'Color',0);
    colorPic = [xIrr,yIrr,zIrr];
    colorPic = reshape(colorPic,length(xIrr),length(xIrr),3);
    ColorPlotAxes = axes(ColorPlot);
    colorPic = xyz2rgb(colorPic);
    imshow(colorPic,'InitialMagnification','fit');
else
    [IrrHigh,~,~,~] = PPFCalculator(Data.IESdata,'MountHeight',0.5,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing,'Color',0);
    [Irr,~,~,~] = PPFCalculator(Data.IESdata,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing,'Color',0);
    [X,Y,Z] = tristimulus(Data.Spectrum);
    Irr2 = mat2gray(Irr,[min(min(IrrHigh)),max(max(Irr))] );
    xIrr = X.*ones(size(Irr2));
    yIrr = Y.*ones(size(Irr2));
    zIrr = Z.*ones(size(Irr2));
    colorPic = [xIrr,yIrr,zIrr];
    colorPic = reshape(colorPic,length(xIrr),length(xIrr),3);
    ColorPlotAxes = axes(ColorPlot);
    colorPic = xyz2rgb(colorPic);
    blackimg = zeros(size(colorPic));
    imshow(blackimg,'InitialMagnification','fit');
    hold on
    h = imshow(colorPic,'InitialMagnification','fit');
    set(h, 'AlphaData', Irr2);
    hold off
end

ax = gca;
plotLabels = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
plotMax = size(colorPic,1);
plotMin =1;
plotSplits = size(plotLabels,1)-1;
ax.YTick =[plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
ax.YTickLabel = flipud(plotLabels);
plotMax = size(colorPic,2);
plotMin =1;
ax.XTick = [plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
ax.XTickLabel = plotLabels;
xlabel('Meters','FontWeight','Bold','FontSize',8);
ylabel('Meters','FontWeight','Bold','FontSize',8);
ax.Visible = 'on';
ax.FontSize = 8;
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
saveas(ColorPlot,'ColorPlotPic.tif')
RemoveWhiteSpace([], 'file', 'ColorPlotPic.tif');
close(ColorPlot);
%% Plot Intensity Distribution 
IntenPlot = figure('units','inches', 'Position',[0 0 3 4]);
set(IntenPlot,'Renderer','painters');
set(IntenPlot,'Resize','off');
axe = polaraxes(IntenPlot);
axe.FontSize = 8;
[~,ind2] = max(max(Data.IESdata.photoTable,[],1));
[~,ind1] = max(max(Data.IESdata.photoTable,[],2));
polarplot(axe,deg2rad(Data.IESdata.HorizAngles),Data.IESdata.photoTable(ind1,:),'LineWidth',1.5,'Color', [1 0 0] );
hold on;
degfirst = Data.IESdata.VertAngles(ind2);
degsecond = mod(mod(Data.IESdata.VertAngles(ind2)+180,360),180);
ind2nd = find(Data.IESdata.VertAngles==degsecond);
if degfirst  > degsecond
    
    photoVect = [Data.IESdata.photoTable(:,ind2);flipud(Data.IESdata.photoTable(2:end,ind2nd))];
    degvect =  mod([Data.IESdata.VertAngles(:);(Data.IESdata.VertAngles(2:end)+180)]-90,360);
    
else
    photoVect = [Data.IESdata.photoTable(:,ind2nd);flipud(Data.IESdata.photoTable(2:end,ind2))]';
    degvect =  mod([Data.IESdata.VertAngles(:);(Data.IESdata.VertAngles(2:end)+180)]-90,360);
end
polarplot(axe ,deg2rad(degvect),photoVect,'LineWidth',1.5, 'Color', LRCBlue);
rlim([0,max(photoVect)]);
axe.ThetaTick = 0:10:360;
axe.FontSize = 9;
axe.ThetaTickLabel =  {sprintf('  0\x00B0'),'','','','','','','','',...
    sprintf(' 90\x00B0'),'','','','','','','','',...
    sprintf('180\x00B0'),'','','','','','','','',...
    sprintf('270\x00B0'),'','','','','','','','',''};
axe.RTick = [0, round(max(photoVect)/4), round((max(photoVect)/4)*2), round((max(photoVect)/4)*3), round(max(photoVect))];
axe.RTickLabel = {'0', num2str(round(max(photoVect)/4)),num2str(round((max(photoVect)/4)*2)),num2str(round((max(photoVect)/4)*3)),num2str(round(max(photoVect)))};
axe.ThetaColorMode = 'manual';
axe.GridColor = 'k';
axe.GridAlpha = .25;
axe.LineWidth =1;
hold off;
legend({'Horizontal Cone through max intensity','Vertical Plane through max intensity'},'Position',[0.01 .1 .98 0.01]);
legend('boxoff');
outerpos = axe.OuterPosition;
ti = axe.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
axe.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
align([IntenPlot,axe],'center','top')
saveas(IntenPlot,'IntentPlotPic.tif')
RemoveWhiteSpace([], 'file', 'IntentPlotPic.tif');
close(IntenPlot);
%% input to PDF
while ~strcmp(rpt.CurrentHoleId,'#end#')
    
    switch rpt.CurrentHoleId
        case '#sect2#'
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
            
        case 'IntenDistImg'
            imgObj = Image('IntentPlotPic.tif');
            imgObj.Style = {Height('3.5in')};
            append(rpt,imgObj);
        case 'ColorDistImg'
            imgObj = Image('ColorPlotPic.tif');
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
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
            append(rpt,Data.outTable.numLuminaire(index));index=index+1;
        case 'ISOPPFDpic'
            imgObj = Image('ISOPlotPic.tif');
            imgObj.Style = {Height('2.8in')};
            append(rpt,imgObj);
        case 'MountHeight'
            append(rpt,mount);
        case 'SPDpic'
            imgObj = Image('SPDPlotPic.tif');
            imgObj.Style = {Height('3.5in')};
            append(rpt,imgObj);
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
    end
    moveToNextHole(rpt);
end

close(rpt);
SPDpic = Tiff('SPDPlotPic.tif');
ISOpic = Tiff('ISOPlotPic.tif');
Colorpic = Tiff('ColorPlotPic.tif');
Intentpic = Tiff('IntentPlotPic.tif');
close(SPDpic);
close(ISOpic);
close(Colorpic);
close(Intentpic);
delete(SPDpic);
delete(ISOpic);
delete(Colorpic);
delete(Intentpic);
delete('SPDPlotPic.tif','ISOPlotPic.tif','ColorPlotPic.tif','IntentPlotPic.tif');
rptview(rpt.OutputPath);
end