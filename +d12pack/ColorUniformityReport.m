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
        
        function obj = ColorUniformityReport(xBarIES,yBarIES,zBarIES)
            obj@d12pack.report;
            obj.Type = 'Color Uniformity Report';
            obj.PageNumBox.Visible = 'off';
            obj.background = [1,1,1];
            obj.HeaderHeight = 75;
            obj.FixtureData.xBarIES = xBarIES;
            obj.FixtureData.yBarIES = yBarIES;
            obj.FixtureData.zBarIES = zBarIES;
            obj.PlotColorUniformity();
        end
         function PlotColorUniformity(obj)
            %plots in the top left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'Pixel';
            
            x = 0;
            w = (obj.Body.Position(3))-2;
            h = (obj.Body.Position(4));
            y = 0;
            
            obj.FixtureInfo.ColorPlot = uipanel(obj.Body);
            obj.FixtureInfo.ColorPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.ColorPlot.BorderType        = 'none';
            obj.FixtureInfo.ColorPlot.Units             = 'pixels';
            obj.FixtureInfo.ColorPlot.Position          = [x,y,w,h];
            [xIrr,~,~,~] = PPFCalculator(obj.FixtureData.xBarIES,'MountHeight',3,'Length',10,'Width',10,'LRcount',1,'TBcount',1,'calcSpacing',1/16);
            [yIrr,~,~,~] = PPFCalculator(obj.FixtureData.yBarIES,'MountHeight',3,'Length',10,'Width',10,'LRcount',1,'TBcount',1,'calcSpacing',1/16);
            [zIrr,~,~,~] = PPFCalculator(obj.FixtureData.zBarIES,'MountHeight',3,'Length',10,'Width',10,'LRcount',1,'TBcount',1,'calcSpacing',1/16);
            obj.pic = [xIrr,yIrr,zIrr];
            obj.pic = reshape(obj.pic,length(xIrr),length(xIrr),3);
            obj.FixtureInfo.ColorPlotAxes = axes(obj.FixtureInfo.ColorPlot);
            obj.pic = xyz2rgb(obj.pic);
            imshow(obj.pic,'InitialMagnification','fit')
         end
    end
end