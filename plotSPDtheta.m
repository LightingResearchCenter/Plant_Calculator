function Data = plotSPDtheta(Data,varargin)
spdTable = readtable(Data.angularSPD,'HeaderLines',1);
spdTable.Properties.VariableNames= [{'wavelength'},{'L90_V0'},{'L90_V15'},{'L90_V30'},{'L90_V45'},{'L90_V60'},{'L90_V75'}];

% UV (200 - 400 nm)
q1 = find(spdTable.wavelength>=200,1,'first');
q2 = find(spdTable.wavelength<=400,1,'last');
i = 1;
clear ratio
ratio(i,1) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V0(q1:q2));
ratio(i,2) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V15(q1:q2));
ratio(i,3) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V30(q1:q2));
ratio(i,4) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V45(q1:q2));
ratio(i,5) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V60(q1:q2));
ratio(i,6) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V75(q1:q2));
% Blue (400 - 500 nm)
q1 = find(spdTable.wavelength>=400,1,'first');
q2 = find(spdTable.wavelength<=500,1,'last');
i = 2;
ratio(i,1) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V0(q1:q2));
ratio(i,2) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V15(q1:q2));
ratio(i,3) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V30(q1:q2));
ratio(i,4) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V45(q1:q2));
ratio(i,5) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V60(q1:q2));
ratio(i,6) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V75(q1:q2));
% Red (600- 700 nm)
q1 = find(spdTable.wavelength>=600,1,'first');
q2 = find(spdTable.wavelength<=700,1,'last');
i = 3;
ratio(i,1) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V0(q1:q2));
ratio(i,2) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V15(q1:q2));
ratio(i,3) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V30(q1:q2));
ratio(i,4) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V45(q1:q2));
ratio(i,5) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V60(q1:q2));
ratio(i,6) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V75(q1:q2));
% Far Red (700 - 800 nm)
q1 = find(spdTable.wavelength>=700,1,'first');
q2 = find(spdTable.wavelength<=800,1,'last');
i = 4;
ratio(i,1) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V0(q1:q2));
ratio(i,2) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V15(q1:q2));
ratio(i,3) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V30(q1:q2));
ratio(i,4) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V45(q1:q2));
ratio(i,5) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V60(q1:q2));
ratio(i,6) = trapz(spdTable.wavelength(q1:q2),spdTable.L90_V75(q1:q2));
% All ()
i = 5;
ratio(i,1) = trapz(spdTable.wavelength,spdTable.L90_V0(:));
ratio(i,2) = trapz(spdTable.wavelength,spdTable.L90_V15(:));
ratio(i,3) = trapz(spdTable.wavelength,spdTable.L90_V30(:));
ratio(i,4) = trapz(spdTable.wavelength,spdTable.L90_V45(:));
ratio(i,5) = trapz(spdTable.wavelength,spdTable.L90_V60(:));
ratio(i,6) = trapz(spdTable.wavelength,spdTable.L90_V75(:));

spdTable.L90_V0 = spdTable.L90_V0/max(spdTable.L90_V0);
spdTable.L90_V15 = spdTable.L90_V15/max(spdTable.L90_V15);
spdTable.L90_V30 = spdTable.L90_V30/max(spdTable.L90_V30);
spdTable.L90_V45 = spdTable.L90_V45/max(spdTable.L90_V45);
spdTable.L90_V60 = spdTable.L90_V60/max(spdTable.L90_V60);
spdTable.L90_V75 = spdTable.L90_V75/max(spdTable.L90_V75);
clear spdInterpTable
spdInterpTable.wavelength = interp1(spdTable.wavelength, spdTable.wavelength ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V75 = interp1(spdTable.wavelength, spdTable.L90_V75 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V60 = interp1(spdTable.wavelength, spdTable.L90_V60 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V45 = interp1(spdTable.wavelength, spdTable.L90_V45 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V30 = interp1(spdTable.wavelength, spdTable.L90_V30 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V15 = interp1(spdTable.wavelength, spdTable.L90_V15 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';
spdInterpTable.L90_V0  = interp1(spdTable.wavelength, spdTable.L90_V0 ,ceil(min(spdTable.wavelength)):floor(max(spdTable.wavelength)),'linear',0)';

spdInterpTable = struct2table(spdInterpTable);
SPDplot = figure('units','inches');
set(SPDplot,'Renderer','painters');
spdAxes = axes(SPDplot);
colors = [213,  62,     79;...
          252,  141,    89;...
          254,  224,    139;...
          230,  245,    152;...
          153,  213,    148;...
          50,   136,    189]/255;
p1 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V0, 'DisplayName',sprintf('0°'), 'Color',colors(1,:),'LineWidth',1);
hold on
p2 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V15,'DisplayName',sprintf('15°'),'Color',colors(2,:),'LineWidth',1);
p3 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V30,'DisplayName',sprintf('30°'),'Color',colors(3,:),'LineWidth',1);
p4 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V45,'DisplayName',sprintf('45°'),'Color',colors(4,:),'LineWidth',1);
p5 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V60,'DisplayName',sprintf('60°'),'Color',colors(5,:),'LineWidth',1);
p6 = plot(spdAxes,spdInterpTable.wavelength,spdInterpTable.L90_V75,'DisplayName',sprintf('75°'),'Color',colors(6,:),'LineWidth',1);
legend('show','Location','best','AutoUpdate','off');
uistack(p6,'bottom');
uistack(p5,'top');
uistack(p4,'top');
uistack(p3,'top');
uistack(p2,'top');
uistack(p1,'top');
hold on;
xlabel('Wavelength ({\itnm})','FontWeight','Bold','FontSize',7);
ylabel('Relative Spectrum ({\itArbitrary Units})','FontWeight','Bold','FontSize',7);
ylim([0,1]);
yticks(0:.2:1)
spdAxes.Visible = 'on';
spdAxes.FontSize = 7;
spdAxes.YGrid = 'On';
if numel(varargin) == 1
    pos = get(SPDplot,'InnerPosition');
    set(SPDplot,'InnerPosition',[pos(1),pos(2),4,2])
    set(gca,'units', 'normalized','outerPosition',[.01 .01 .99 .99],'fontsize',7)
    print(SPDplot,'-dpng', varargin{1},'-r600');
    RemoveWhiteSpace([], 'file', varargin{1});
    close(SPDplot);
end
Data.UVaPer = ratio(1,:)'./ratio(5,:)';
Data.bluePer = ratio(2,:)'./ratio(5,:)';
Data.redPer = ratio(3,:)'./ratio(5,:)';
Data.FRPer = ratio(4,:)'./ratio(5,:)';
Data.blueRed = ratio(2,:)'./ratio(3,:)';
Data.redFR = ratio(4,:)'./ratio(3,:)';
end
