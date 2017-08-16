function plotPPF(Data,varargin)
PPFplot =figure('units','inches', 'Position',[0 0 3 .5]);
set(PPFplot,'Renderer','painters');
set(PPFplot,'Resize','off');
PPFaxes = axes(PPFplot);
barh(PPFaxes,Data.PPFmax/Data.PPFmax, 'w')
hold on
barh(PPFaxes,Data.PPF/Data.PPFmax, 'k')
hold off
set(PPFaxes,'YTickLabel',' ');
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
if varargin == 1
    saveas(PPFplot,'PPFDPlotPic.tif')
    RemoveWhiteSpace([], 'file', 'PPFDPlotPic.tif');
    close(PPFplot)
else
    title('PPF Ranking');
end
end