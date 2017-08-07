function plotColorUni(Spectrum,IESfiles,varargin)
ColorPlot = figure('units','inches', 'Position',[0 0 3.5 4]);
set(ColorPlot,'Renderer','painters');
set(ColorPlot,'Resize','off');
calcSpacing = 1/16;
roomSize = 3;
mountHeight = 2;
if size(IESfiles,1) == 3
    [xIrr,~,~,~] = PPFCalculator(IESfiles(1),'MountHeight',mountHeight,'Length',roomSize,'Width',roomSize,'centers',[roomSize/2,roomSize/2],'calcSpacing',calcSpacing,'Color',0);
    [yIrr,~,~,~] = PPFCalculator(IESfiles(2),'MountHeight',mountHeight,'Length',roomSize,'Width',roomSize,'centers',[roomSize/2,roomSize/2],'calcSpacing',calcSpacing,'Color',0);
    [zIrr,~,~,~] = PPFCalculator(IESfiles(3),'MountHeight',mountHeight,'Length',roomSize,'Width',roomSize,'centers',[roomSize/2,roomSize/2],'calcSpacing',calcSpacing,'Color',0);
    colorPic = [xIrr,yIrr,zIrr];
    colorPic = reshape(colorPic,length(xIrr),length(xIrr),3);
    ColorPlotAxes = axes(ColorPlot);
    colorPic = xyz2rgb(colorPic);
    imshow(colorPic,'InitialMagnification','fit');
else
    [IrrHigh,~,~,~] = PPFCalculator(IESfiles(1),'MountHeight',0.5,'Length',roomSize,'Width',roomSize,'centers',[roomSize/2,roomSize/2],'calcSpacing',calcSpacing,'Color',0);
    [Irr,~,~,~] = PPFCalculator(IESfiles(1),'MountHeight',2,'Length',roomSize,'Width',roomSize,'centers',[roomSize/2,roomSize/2],'calcSpacing',calcSpacing,'Color',0);
    [X,Y,Z] = tristimulus(Spectrum);
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
ax = ColorPlotAxes;
plotLabels = {sprintf('%0.2f',(roomSize/2)*-1);sprintf('%0.2f',(roomSize/2)*(-2/3));sprintf('%0.2f',(roomSize/2)*(-1/3));sprintf('%0.2f',(roomSize/2)*(0));sprintf('%0.2f',(roomSize/2)*(1/3));sprintf('%0.2f',(roomSize/2)*(2/3));sprintf('%0.2f',(roomSize/2)*(1))};
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
if numel(varargin) == 1
    saveas(ColorPlot,varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(ColorPlot);
end
end