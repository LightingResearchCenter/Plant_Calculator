function plotIntensityDist(IESdata,varargin)
LRCBlue = [ 30,  63, 134]/255;
IntenPlot = figure('units','inches');
set(IntenPlot,'Renderer','painters');
set(IntenPlot,'Resize','off');
axe = polaraxes(IntenPlot);
axe.FontSize = 8;
[~,ind2] = max(max(IESdata.photoTable,[],1));
[~,ind1] = max(max(IESdata.photoTable,[],2));
polarplot(axe,deg2rad(IESdata.HorizAngles),IESdata.photoTable(ind1,:),'LineWidth',1.5,'Color', [1 0 0]);
hold on
degfirst = IESdata.VertAngles(ind2);
degsecond = mod(mod(IESdata.VertAngles(ind2)+180,360),180);
ind2nd = find(IESdata.VertAngles==degsecond);
if degfirst  > degsecond
    
    photoVect = [IESdata.photoTable(:,ind2);flipud(IESdata.photoTable(2:end,ind2nd))];
    degvect =  mod([IESdata.VertAngles(:);(IESdata.VertAngles(2:end)+180)]-90,360);
    
else
    photoVect = [IESdata.photoTable(:,ind2nd);flipud(IESdata.photoTable(2:end,ind2))]';
    degvect =  mod([IESdata.VertAngles(:);(IESdata.VertAngles(2:end)+180)]-90,360);
end
polarplot(axe, deg2rad(degvect), photoVect, 'LineWidth', 1.5, 'Color', LRCBlue);
rlim([0,max(photoVect)]);
axe.ThetaTick = 0:10:360;
axe.FontSize = 9;
axe.ThetaTickLabel = {sprintf('  0\x00B0'),'','','','','','','','',...
    sprintf(' 90\x00B0'),'','','','','','','','',...
    sprintf('180\x00B0'),'','','','','','','','',...
    sprintf('270\x00B0'),'','','','','','','','',''};
axe.RTick = [0, round(max(photoVect)/4), round((max(photoVect)/4)*2), round((max(photoVect)/4)*3), round(max(photoVect))];
axe.RTickLabel = {'0', num2str(round(max(photoVect)/4)),num2str(round((max(photoVect)/4)*2)),num2str(round((max(photoVect)/4)*3)),num2str(round(max(photoVect)))};
axe.ThetaColorMode = 'manual';
axe.GridColor = 'k';
axe.GridAlpha = .25;
axe.LineWidth =1;
hold off
legend({'Horizontal Cone through max intensity','Vertical Plane through max intensity'},'Location','southoutside');
legend('boxoff');
if numel(varargin)==1
    
    pos = get(IntenPlot,'InnerPosition');
    set(IntenPlot,'InnerPosition',[pos(1),pos(2),3.25, 4])
    set(axe,'units', 'normalized','outerPosition',[.01 .01 .99 .99],'fontsize',8)
    drawnow;
    saveas(IntenPlot, varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(IntenPlot);
else
    title('Polar Plot');
end
end