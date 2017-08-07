function plotISOppfd(Spectrum,IESdata,plotMax,mount,centers,LLF,varargin)
ISOPlot =figure('units','inches');
set(ISOPlot,'Renderer','painters');

ConversionFactor = PPF_Conversion_Factor_05Apr2016(Spectrum(:,1),Spectrum(:,2));
calcSpacing = 0.25;
plotMin = 0;
CalcMax = plotMax*unitsratio('m','ft');
CalcMount = mount*unitsratio('m','ft');
centers(:,1:2) = centers(:,1:2)*unitsratio('m','ft');
[Irr,~,~,~] = PPFCalculator(IESdata,...
                            'MountHeight',          CalcMount,...
                            'Length',               CalcMax(1),...
                            'Width',                CalcMax(end),...
                            'centers',              centers(:,1:2),...
                            'LLF',                  LLF,...
                            'calcSpacing',          calcSpacing,...
                            'Multiplier',           round(ConversionFactor,1),...
                            'fixtureOrientation',   centers(1,3));
plotXLabels = {strip(sprintf('%0.2f',(plotMax(end)/2)*-1),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(-2/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(-1/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(0)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(1/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(2/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(end)/2)*(1)),'right','0')};
plotYLabels = {strip(sprintf('%0.2f',(plotMax(1)/2)*-1),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(-2/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(-1/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(0)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(1/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(2/3)),'right','0');...
               strip(sprintf('%0.2f',(plotMax(1)/2)*(1)),'right','0')};
myfunc = @(x) strip(x,'right','.');
plotXLabels = cellfun(myfunc,plotXLabels,'UniformOutput',0); 
plotYLabels = cellfun(myfunc,plotYLabels,'UniformOutput',0);
plotSplits = size(plotYLabels,1)-1;
calcSpacing =calcSpacing*unitsratio('ft','m');
rowStart = (plotMax(end)-(calcSpacing*floor(plotMax(end)/calcSpacing)))/2;
colStart = (plotMax(1)-(calcSpacing*floor(plotMax(1)/calcSpacing)))/2;
X= (rowStart:calcSpacing:plotMax(end))';
Y = (colStart:calcSpacing:plotMax(1));

ISOaxes = axes(ISOPlot);

[C,h] = contour(ISOaxes,X,Y,Irr,[25,50,100:100:500]);

ISOaxes.XTick =[plotMin,(plotMax(end))/plotSplits:(plotMax(end))/plotSplits:plotMax(end)-((plotMax(end))/plotSplits),plotMax(end)];
ISOaxes.YTickLabel = plotYLabels;
ISOaxes.YTick = [plotMin,(plotMax(1))/plotSplits:(plotMax(1))/plotSplits:plotMax(1)-((plotMax(1))/plotSplits),plotMax(1)];
ISOaxes.XTickLabel = plotXLabels;
ISOaxes.YLim = [plotMin,plotMax(1)];
ISOaxes.XLim = [plotMin,plotMax(end)];
ax = ISOaxes;
ax.FontSize = 8;
clabel(C,h,'FontSize',8);
axis(ISOaxes,'square');
ISOaxes.XGrid = 'on';
ISOaxes.YGrid = 'on';
ylabel(ISOaxes,'Feet','FontSize',8,'FontWeight','Bold')
xlabel(ISOaxes,'Feet','FontSize',8,'FontWeight','Bold')
colormap(ISOaxes,jet);
colorbar(ISOaxes);
caxis([0 500]);
align([ISOPlot,ISOaxes],'center','top');

if numel(varargin)==1
    set(gcf,'Position',[0,0,5,4]);
    fixX = (plotMax(1)/2)-(IESdata.WidthFt*0.5);
    fixY = (plotMax(end)/2)-(IESdata.LengthFt*0.5);
    fixW = IESdata.WidthFt;
    fixH = IESdata.LengthFt;
    rectangle('Position',[fixX,fixY,fixW,fixH],'LineWidth',2);
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
    saveas(ISOPlot,varargin{1});
    RemoveWhiteSpace([], 'file',varargin{1});
    close(ISOPlot);
else
    hold on
    plot(ax,centers(:,1)*unitsratio('ft','m'),centers(:,2)*unitsratio('ft','m'),'*');
    hold off
end
end