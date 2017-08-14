function plotPPDFperW(Data)
PPFplot =figure('units','inches', 'Position',[0 0 3 .5]);
set(PPFplot,'Renderer','painters');
set(PPFplot,'Resize','off');
PPFaxes = axes(PPFplot);
barh(PPFaxes,Data.PPFperWmax, 'w','BaseValue',Data.PPFperWmin)
hold on
barh(PPFaxes,Data.PPFperW, 'k')
hold off
set(PPFaxes,'XLim',[Data.PPFperWmin,Data.PPFperWmax]);
set(PPFaxes,'XTickLabel',[Data.PPFperWmin,Data.PPFperWmax]);
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
saveas(PPFplot,'PPFDPlotPic.tif')
RemoveWhiteSpace([], 'file', 'PPFDPlotPic.tif');
close(PPFplot)
end