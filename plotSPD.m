function plotSPD(Spectrum,varargin)
SPDplot =figure('units','inches');
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
if numel(varargin)==1
    pos = get(SPDplot,'InnerPosition');
    set(SPDplot,'InnerPosition',[pos(1),pos(2),5, 2.25])
   set(gca,'units', 'normalized','outerPosition',[.01 .01 .99 .99],'fontsize',8)
    saveas(SPDplot,varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(SPDplot)
end
end