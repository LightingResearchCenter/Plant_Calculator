function plotIntensityDist(IESdata,varargin)
LRCBlue = [ 30,  63, 134]/255;
IntenPlot = figure('units','inches', 'Position',[0 0 3 4]);
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
legend({'Horizontal Cone through max intensity','Vertical Plane through max intensity'},'Position',[0.01 .1 .98 0.01]);
legend('boxoff');
outerpos = axe.OuterPosition;
ti = axe.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
axe.Position = [left bottom ax_width ax_height];
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
align([IntenPlot,axe],'center','top')
if numel(varargin)==1
    saveas(IntenPlot, varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(IntenPlot);
else
    title('Polar Plot');
end
end