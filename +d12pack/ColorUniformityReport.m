classdef ColorUniformityReport < d12pack.report
    %PLANTREPORT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        background
        FixtureData
        FixtureInfo
        pic
    end
    
    properties (Access = protected)
        LRCBlue   = [ 30,  63, 134]/255;
        LightBlue = [180, 211, 227]/255;
    end
    
    methods
        
        function obj = ColorUniformityReport(tradIES,xBarIES,yBarIES,zBarIES)
            obj@d12pack.report;
            obj.Type = 'Plant Metrics Report';
            obj.PageNumber = [2,2];
            obj.background = [1,1,1];
            obj.Body.Position(4) = obj.Header.Position(2)+obj.Header.Position(4)-obj.Body.Position(2);   
            obj.FixtureData.IES = tradIES;
            obj.FixtureData.xBarIES = xBarIES;
            obj.FixtureData.yBarIES = yBarIES;
            obj.FixtureData.zBarIES = zBarIES;
            obj.PlotColorUniformity();
            obj.PlotPolarIntensity();
            obj.PlotColorUniformity();
        end
        function PlotColorUniformity(obj)
            %plots in the top left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'Pixel';
            
            
            
            obj.FixtureInfo.ColorPlot = uipanel(obj.Body);
            obj.FixtureInfo.ColorPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.ColorPlot.BorderType        = 'none';
            obj.FixtureInfo.ColorPlot.Units             = 'Normal';
            obj.FixtureInfo.ColorPlot.Position          = [0,2/3,1,1/3];
            calcSpacing = 1/16;
            [xIrr,~,~,~] = PPFCalculator(obj.FixtureData.xBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing);
            [yIrr,~,~,~] = PPFCalculator(obj.FixtureData.yBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing);
            [zIrr,~,~,~] = PPFCalculator(obj.FixtureData.zBarIES,'MountHeight',2,'Length',3,'Width',3,'LRcount',1,'TBcount',1,'calcSpacing',calcSpacing);
            obj.pic = [xIrr,yIrr,zIrr];
            obj.pic = reshape(obj.pic,length(xIrr),length(xIrr),3);
            obj.FixtureInfo.ColorPlotAxes = axes(obj.FixtureInfo.ColorPlot);
            obj.pic = xyz2rgb(obj.pic);
            imshow(obj.pic,'InitialMagnification','fit')
            
            ax = gca;
            plotLabels = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
            plotMax = size(obj.pic,1);
            plotMin =1;
            plotSplits = size(plotLabels,1)-1;
            imshow(obj.pic)
            ax.YTick =[plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
            ax.YTickLabel = flipud(plotLabels);
            plotMax = size(obj.pic,2);
            plotMin =1;
            ax.XTick = [plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
            ax.XTickLabel = plotLabels;
            xlabel('Meters');
            ylabel('Meters');
            title('Spatial Color Distribution on Work Plane (RGB)');
            ax.Visible = 'on';
            
                       
            obj.FixtureInfo.textPlot = uicontrol(obj.Body,'Style','text');
            obj.FixtureInfo.textPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.textPlot.Units             = 'normal';
            obj.FixtureInfo.textPlot.Position          = [0,(2/3)-(1/40),1,1/40];
            obj.FixtureInfo.textPlot.String            = sprintf('                        Note: Mounting Height = 2m, Work plane = 4m x 4m.                        ');
              
        end
        function PlotPolarIntensity(obj)
                        
            obj.FixtureInfo.IntPolarPlot = uipanel(obj.Body);
            obj.FixtureInfo.IntPolarPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.IntPolarPlot.BorderType        = 'none';
            obj.FixtureInfo.IntPolarPlot.Units             = 'normal';
            obj.FixtureInfo.IntPolarPlot.Position          = [0,(1/3)-(1/20),1,(1/3)+(1/40)];
            axe = polaraxes(obj.FixtureInfo.IntPolarPlot);
            [~,ind2] = max(max(obj.FixtureData.IES.photoTable,[],1));
            [~,ind1] = max(max(obj.FixtureData.IES.photoTable,[],2));
            polarplot(axe,deg2rad(obj.FixtureData.IES.HorizAngles),obj.FixtureData.IES.photoTable(ind1,:),'LineWidth',1.5,'Color', obj.LRCBlue );
            hold on;
            degfirst = obj.FixtureData.IES.VertAngles(ind2);
            degsecond = mod(mod(obj.FixtureData.IES.VertAngles(ind2)+90,360),180);
            ind2nd = find(obj.FixtureData.IES.VertAngles==degsecond);
            if degfirst  > degsecond
                
                photoVect = [obj.FixtureData.IES.photoTable(:,ind2);flipud(obj.FixtureData.IES.photoTable(2:end,ind2nd))];
            else
                photoVect = [obj.FixtureData.IES.photoTable(:,ind2nd);flipud(obj.FixtureData.IES.photoTable(2:end,ind2))]';
            end
            polarplot(axe ,deg2rad(-90:180/(obj.FixtureData.IES.NoVertAngles-1):270),photoVect,'LineWidth',1.5, 'Color',[1 0 0]);
            rlim([0,max(photoVect)]);
            axe.ThetaTick = [0:10:360];
            axe.FontSize = 9;
            axe.ThetaTickLabel =  {sprintf('  0\x00B0'),'','','','','','','','',...
                                   sprintf(' 90\x00B0'),'','','','','','','','',...
                                   sprintf('180\x00B0'),'','','','','','','','',...
                                   sprintf('270\x00B0'),'','','','','','','','',''};
            axe.RTick = [0, round(max(photoVect)/4), round((max(photoVect)/4)*2), round((max(photoVect)/4)*3), round(max(photoVect))];
            axe.RTickLabel = {'0', num2str(round(max(photoVect)/4)),num2str(round((max(photoVect)/4)*2)),num2str(round((max(photoVect)/4)*3)),num2str(round(max(photoVect)))};
            legend({'Horizontal Cone through max intensity','Vertical Plane through max intensity'},'Position',[0.02 .01 .98 0.015],'Orientation','horizontal');
            legend('boxoff');
            title('Luminous Intensity Distribution (cd)');
        end
    end
end