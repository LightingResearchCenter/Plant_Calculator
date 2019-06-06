function [varargout]=plotISOppfd(Spectrum,IESdata,plotMax,mount,centers,LLF,varargin)
ISOPlot =figure('units','inches');
set(ISOPlot,'Renderer','painters');

ConversionFactor = PPF_Conversion_Factor_05Apr2016(Spectrum(:,1),Spectrum(:,2));
calcSpacing = 0.125;
CalcMax = plotMax*unitsratio('m','ft')+2*calcSpacing;
CalcMount = mount*unitsratio('m','ft');
centers(:,1:2) = centers(:,1:2)*unitsratio('m','ft')+calcSpacing;
[Irr,~,~,~] = PPFCalculator(IESdata,...
    'MountHeight',          CalcMount,...
    'Length',               CalcMax(1),...
    'Width',                CalcMax(end),...
    'centers',              centers(:,1:2),...
    'LLF',                  LLF,...
    'calcSpacing',          calcSpacing,...
    'Multiplier',           round(ConversionFactor,1),...
    'fixtureOrientation',   centers(1,3));
Irr(isnan(Irr)) = 0;
plotXLabels = {sprintf('%0.0f (%0.1f)',(plotMax(end)/2)*(-1),(plotMax(end)/2)*(-1)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(end)/2)*(-1/2),(plotMax(end)/2)*(-1/2)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(end)/2)*(0),(plotMax(end)/2)*(0)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(end)/2)*(1/2),(plotMax(end)/2)*(1/2)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(end)/2)*(1),(plotMax(end)/2)*(1)*unitsratio('m','ft'))};
plotYLabels = {sprintf('%0.0f (%0.1f)',(plotMax(1)/2)*(-1),(plotMax(1)/2)*(-1)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(1)/2)*(-1/2),(plotMax(1)/2)*(-1/2)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(1)/2)*(0),(plotMax(1)/2)*(0)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(1)/2)*(1/2),(plotMax(1)/2)*(1/2)*unitsratio('m','ft'));...
    sprintf('%0.0f (%0.1f)',(plotMax(1)/2)*(1),(plotMax(1)/2)*(1)*unitsratio('m','ft'))};

myfunc1 = @(x) strip(x,'right','0');
myfunc2 = @(x) strip(x,'right','.');
plotXLabels = cellfun(myfunc1,plotXLabels,'UniformOutput',0);
plotYLabels = cellfun(myfunc1,plotYLabels,'UniformOutput',0);
plotXLabels = cellfun(myfunc2,plotXLabels,'UniformOutput',0);
plotYLabels = cellfun(myfunc2,plotYLabels,'UniformOutput',0);

plotSplits = size(plotYLabels,1)-1;
rowStart = (CalcMax(end)-(calcSpacing*floor(CalcMax(end)/calcSpacing)))/2;
colStart = (CalcMax(1)-(calcSpacing*floor(CalcMax(1)/calcSpacing)))/2;
X= (rowStart:calcSpacing:CalcMax(end))';
Y = (colStart:calcSpacing:CalcMax(1));
ISOaxes = axes(ISOPlot);

[C,h] = contourf(ISOaxes,X,Y,Irr,[25,50,100:100:500]);

ISOaxes.XTick =[X(1),(X(end))/plotSplits:(X(end))/plotSplits:X(end)-((X(end))/plotSplits),X(end)];
ISOaxes.YTickLabel = plotYLabels;
ISOaxes.YTick = [Y(1),(Y(end))/plotSplits:(Y(end))/plotSplits:Y(end)-((Y(end))/plotSplits),Y(end)];
ISOaxes.XTickLabel = plotXLabels;
ISOaxes.YLim = [Y(1),Y(end)];
ISOaxes.XLim = [X(1),X(end)];
ISOaxes.TickDir = 'both';
ax = ISOaxes;
ax.FontSize = 8;
clabel(C,h,'FontSize',8);
axis(ISOaxes,'square');
ISOaxes.XGrid = 'on';
ISOaxes.YGrid = 'on';
ylabel(ISOaxes,'{\itFeet} ({\itMeters})','FontSize',8,'FontWeight','Bold')
xlabel(ISOaxes,'{\itFeet} ({\itMeters})','FontSize',8,'FontWeight','Bold')
colormap(ISOaxes,jet);
c = colorbar(ISOaxes);
c.Label.String = '\fontsize{9}{\bf\mumol m^{-2}  s^{-1}}';
caxis([0 500]);
align([ISOPlot,ISOaxes],'center','top');

if numel(varargin)==1
    pos = get(ISOPlot,'InnerPosition');
    set(ISOPlot,'InnerPosition',[pos(1),pos(2),5,3]);
    set(gca,'units', 'normalized','outerPosition',[.02 .02 .99 .99],'fontsize',8)
    print(ISOPlot,'-dpng', varargin{1},'-r600');
    RemoveWhiteSpace([], 'file',varargin{1});
    close(ISOPlot);
else
    hold on
    plot(ax,centers(:,1)*unitsratio('ft','m'),centers(:,2)*unitsratio('ft','m'),'*');
    hold off
end
if nargout == 1
    varargout{1} = Irr;
end
end