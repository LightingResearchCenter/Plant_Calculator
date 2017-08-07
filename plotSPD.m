function plotSPD(Spectrum,varargin)
SPDplot =figure('units','inches', 'Position',[0 0 3 2.5]);
set(SPDplot,'Renderer','painters');
set(SPDplot,'Resize','off');
SPDaxes = axes(SPDplot);
plot(SPDaxes,Spectrum(:,1),...
    Spectrum(:,2)/max(Spectrum(:,2)),...
    'LineWidth',1);
axis(SPDaxes,[380,830,0,inf]);
ax = gca;
ax.FontSize = 8;

xlabel(SPDaxes,'Wavelength (nm)','FontSize',8,'FontWeight','Bold')
ylabel(SPDaxes,'Relative Spectrum (Arbitrary Units)','FontSize',8,'FontWeight','Bold')
SPDaxes.YGrid = 'On';
text(SPDaxes,400,.95,sprintf('(Absolute multiplier=%0.2f W/nm)',max(Spectrum(:,2))),'FontSize',8);
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
if numel(varargin)==1
    saveas(SPDplot,varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(SPDplot)
end
end