function plotIntensityDist(IESdata,multiplier,varargin)
if nargin == 1
    multiplier = 1000;
end
LRCBlue = [ 30,  63, 134]/255;
IntenPlot = figure('units','inches');
set(IntenPlot,'Renderer','painters');
set(IntenPlot,'Resize','off');
axe = polaraxes(IntenPlot);
axe.FontSize = 8;
PPFTable = IESdata.photoTable.*(multiplier)./1000;
[~,ind2] = max(max(PPFTable,[],1));
[~,ind1] = max(max(PPFTable,[],2));
polarplot(axe,deg2rad(IESdata.HorizAngles),PPFTable(ind1,:),'LineWidth',1.5,'Color', [1 0 0]);
hold on
degfirst = IESdata.VertAngles(ind2);
degsecond = mod(mod(IESdata.VertAngles(ind2)+180,360),180);
ind2nd = find(IESdata.VertAngles==degsecond);
if degfirst  > degsecond
    photoVect = [PPFTable(:,ind2);flipud(PPFTable(2:end,ind2nd))];
    degvect =  mod([IESdata.VertAngles(:);(IESdata.VertAngles(2:end)+180)]-90,360);
    
else
    photoVect = [PPFTable(:,ind2nd);flipud(PPFTable(2:end,ind2))]';
    degvect =  mod([IESdata.VertAngles(:);(IESdata.VertAngles(2:end)+180)]-90,360);
end
polarplot(axe, deg2rad(degvect), photoVect, 'LineWidth', 1.5, 'Color', LRCBlue);
rlim([0,ceil(max(photoVect))]);
axe.ThetaTick = 0:10:360;
axe.FontSize = 9;
axe.ThetaTickLabel = {sprintf('  0\x00B0'),'','','','','','','','',...
    sprintf(' 90\x00B0'),'','','','','','','','',...
    sprintf('180\x00B0'),'','','','','','','','',...
    sprintf('270\x00B0'),'','','','','','','','',''};
if ceil(max(photoVect))<10
    axe.RTick = [0, round(max(photoVect)/4,1), round((max(photoVect)/4)*2,1), round((max(photoVect)/4)*3,1), ceil(max(photoVect))];
    axe.RTickLabel = {'0', num2str(round(max(photoVect)/4,1)),num2str(round((max(photoVect)/4)*2,1)),num2str(round((max(photoVect)/4)*3,1)),num2str(ceil(max(photoVect)))};
else
    axe.RTick = [0, round(max(photoVect)/4), round((max(photoVect)/4)*2), round((max(photoVect)/4)*3), ceil(max(photoVect))];
    axe.RTickLabel = {'0', num2str(round(max(photoVect)/4)),num2str(round((max(photoVect)/4)*2)),num2str(round((max(photoVect)/4)*3)),num2str(ceil(max(photoVect)))};
end
axe.ThetaColorMode = 'manual';
axe.GridColor = 'k';
axe.GridAlpha = .25;
axe.LineWidth =1;
hold off
legend({'\bfHorizontal Cone through max intensity','\bfVertical Plane through max intensity'},'Location','southoutside');
legend('boxoff');
if numel(varargin)==1
    
    pos = get(IntenPlot,'InnerPosition');
    set(IntenPlot,'InnerPosition',[pos(1),pos(2),3.25, 4])
    set(axe,'units', 'normalized','outerPosition',[.01 .01 .99 .99],'fontsize',10)
    drawnow;
    print(IntenPlot,'-dpng', varargin{1},'-r600');
    RemoveWhiteSpace([], 'file', varargin{1});
    close(IntenPlot);
else
    title('Polar Plot');
end
end