function plotRank(num,numMax,numMin,varargin)
rankPlot =figure('units','inches');
rankAxes = axes(rankPlot);
barh(rankAxes,numMax, 'w')
hold on
barh(rankAxes,num, 'k')
hold off
set(rankAxes,'XLim',[numMin numMax])
set(rankAxes,'YTickLabel',' ');
xticks([numMin ,((numMax - numMin)*.25)+numMin,((numMax - numMin)*.5)+numMin,...
    ((numMax - numMin)*.75)+numMin,numMax]);
set(rankAxes,'XTickLabel',{'0%','25%','50%','75%','100%'});
if num>((numMax - numMin)*.75)+numMin
    text(num,1,sprintf('%0.1f ',num),'Color','w', 'HorizontalAlignment','Right');
else
    text(num,1,sprintf(' %0.1f',num));
end
if numel(varargin) == 1
    pos = get(rankPlot,'InnerPosition');
    set(rankPlot,'InnerPosition',[pos(1),pos(2),3.25, .4]);
    set(gca,'units', 'normalized','outerPosition',[0 0 1 1],'fontsize',8)
    set(rankPlot,'Renderer','painters');
    set(rankPlot,'Resize','off');
    saveas(rankPlot,varargin{1});
    RemoveWhiteSpace([], 'file',varargin{1});
    close(rankPlot)
else
    title('Ranking');
end
end