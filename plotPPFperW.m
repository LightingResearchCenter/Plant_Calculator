function plotPPFperW(Data,PPFperWmax,PPFperWmin,varargin)
PPFplot =figure('units','inches');
PPFaxes = axes(PPFplot);
barh(PPFaxes,PPFperWmax, 'w')
hold on
barh(PPFaxes,Data.PPFperW, 'k')
hold off
set(PPFaxes,'XLim',[PPFperWmin PPFperWmax])
set(PPFaxes,'YTickLabel',' ');
xticks([PPFperWmin ,((PPFperWmax - PPFperWmin)*.25)+PPFperWmin,((PPFperWmax - PPFperWmin)*.5)+PPFperWmin,...
    ((PPFperWmax - PPFperWmin)*.75)+PPFperWmin,PPFperWmin]);
set(PPFaxes,'XTickLabel',{'0%','25%','50%','75%','100%'});
if Data.PPF >((PPFmax - PPFmin)*.75)+PPFmin
    text(Data.PPF,1,sprintf('%0.1f ',Data.PPF),'Color','w', 'HorizontalAlignment','Right');
else
    text(Data.PPF,1,sprintf(' %0.1f',Data.PPF));
end
if numel(varargin) == 1
    set(PPFplot,'Position',[0 0 3 .5]);
    outerpos = PPFaxes.OuterPosition;
    ti = PPFaxes.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2) + (.1*ti(2));
    ax_width = outerpos(3) - ti(1) - ti(3) - (.1*ti(1));
    ax_height = outerpos(4) - ti(2) - ti(4);
    PPFaxes.Position = [left bottom ax_width ax_height];
    PPFplot.PaperPositionMode = 'auto';
    fig_pos = PPFplot.PaperPosition;
    PPFplot.PaperSize = [fig_pos(3) fig_pos(4)];
    set(PPFplot,'Renderer','painters');
    set(PPFplot,'Resize','off');
    saveas(PPFplot,varargin{1});
    RemoveWhiteSpace([], 'file',varargin{1});
    close(PPFplot)
else
    title('PPF Ranking');
end
end
