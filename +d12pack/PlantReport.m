classdef PlantReport < d12pack.report
    %PLANTREPORT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        background
        FixtureData
        FixtureInfo
    end
    
    properties (Access = protected)
        LRCBlue   = [ 30,  63, 134]/255;
        LightBlue = [180, 211, 227]/255;
    end
    
    methods
        
        function obj = PlantReport(varargin)
            obj@d12pack.report;
            obj.Type = 'Plant Metrics Report';
            obj.PageNumBox.Visible = 'off';
            obj.background = [1,1,1];
            if nargin == 0
                obj.FixtureData = struct(   'Lamp','Incandecent',...
                    'Voltage',120,...
                    'PPF',380.7,...
                    'YPF',337.8,...
                    'PPFofTotal',.9,...
                    'RSS',0.868,...
                    'RCR',32537.8,...
                    'ImagePath','incandescent.png',...
                    'Product','LED109053',...
                    'Catalog','Unknown',...
                    'Spectrum',load('\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\Trial2\SPD\LED109053109053SPD.txt'),...
                    'IESdata',IESFile('\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies'));
                obj.FixtureData.Wattage =   obj.FixtureData.IESdata.InputWatts;
            elseif nargin == 1
                obj.FixtureData = varargin{1};
            else
                error('Too many inputs');
            end
            obj.initFixtureInfo();
            obj.initIntensityDist();
            obj.initSPDPlot();
            obj.initISOPPFPlot();
            obj.initLASEPlot();
            
        end % End of class constructor
    end
    
    methods (Access = protected)
        function initFixtureInfo(obj)
            %Plots the header portion of the document
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/5;
            h = floor(obj.Body.Position(4)/6);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.Title = uipanel(obj.Body);
            obj.FixtureInfo.Title.BackgroundColor   = obj.background;
            obj.FixtureInfo.Title.BorderType        = 'none';
            obj.FixtureInfo.Title.Units             = 'pixels';
            obj.FixtureInfo.Title.Position          = [x,y,w,h];
            
            FontSize = 16;
            hTitle = uicontrol(obj.FixtureInfo.Title,'style','text');
            hTitle.HorizontalAlignment  = 'Left';
            hTitle.BackgroundColor      = 'White';
            hTitle.Units                = 'pixels';
            hTitle.Position             = [0,(h/4)*3,w,h/5];
            hTitle.FontName             = 'Arial';
            hTitle.FontUnits            = 'pixels';
            hTitle.FontSize             = FontSize;
            hTitle.FontWeight           = 'bold';
            hTitle.String               = {'Data Sheet'};
            
            FontSize = 14;
            hProduct = uicontrol(obj.FixtureInfo.Title,'style','text');
            hProduct.HorizontalAlignment    = 'Left';
            hProduct.BackgroundColor        = 'White';
            hProduct.Units                  = 'pixels';
            hProduct.Position               = [0,0,w,(h/4)*3];
            hProduct.FontName               = 'Arial';
            hProduct.FontUnits              = 'pixels';
            hProduct.FontSize               = FontSize;
            hProduct.String                 = { obj.FixtureData.Product;...
                obj.FixtureData.Lamp;...
                obj.FixtureData.Catalog};
            
            x = w+20;
            w = floor(obj.Body.Position(3)/5);
            h = floor(obj.Body.Position(4)/6);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.LeftCenter = uipanel(obj.Body);
            obj.FixtureInfo.LeftCenter.BackgroundColor	= obj.background;
            obj.FixtureInfo.LeftCenter.BorderType       = 'none';
            obj.FixtureInfo.LeftCenter.Units            = 'pixels';
            obj.FixtureInfo.LeftCenter.Position         = [x, y, w, h];
            
            hProduct2 = uicontrol(obj.FixtureInfo.LeftCenter,'style','text');
            hProduct2.HorizontalAlignment    = 'Left';
            hProduct2.BackgroundColor        = 'White';
            hProduct2.Units                  = 'pixels';
            hProduct2.Position               = [0,0, w,(h/5)*4];
            hProduct2.FontName               = 'Arial';
            hProduct2.FontUnits              = 'pixels';
            hProduct2.FontSize               = FontSize;
            hProduct2.String                 = {['Power = ',num2str(obj.FixtureData.Wattage,'%5.2f'),' ','W'];...
                ['Voltage = ',num2str(obj.FixtureData.Voltage,'%5.2f'),' ','V'];...
                ['PF = ',num2str(obj.FixtureData.Wattage/obj.FixtureData.Voltage,'%5.2f')]};
            
            x = w*2+20;
            w = floor(obj.Body.Position(3)/5);
            h = floor(obj.Body.Position(4)/6);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.Center = uipanel(obj.Body);
            obj.FixtureInfo.Center.BackgroundColor	= obj.background;
            obj.FixtureInfo.Center.BorderType       = 'none';
            obj.FixtureInfo.Center.Units            = 'pixels';
            obj.FixtureInfo.Center.Position         = [x, y, w, h];
            
            hMetric = uicontrol(obj.FixtureInfo.Center,'style','text');
            hMetric.HorizontalAlignment    = 'Left';
            hMetric.BackgroundColor        = 'White';
            hMetric.Units                  = 'pixels';
            hMetric.Position               = [0, 0, w,(h/5)*4];
            hMetric.FontName               = 'Arial';
            hMetric.FontUnits              = 'pixels';
            hMetric.FontSize               = FontSize;
            hMetric.String                 = {  ['PPF=',num2str(obj.FixtureData.PPF,'%5.2f'),' ',char(956),'Mol/sec'];...
                ['PPF/W=',num2str(obj.FixtureData.PPF/obj.FixtureData.Wattage,'%5.2f'),' ',char(956),'Mol/J'];...
                ['YPF=',num2str(obj.FixtureData.YPF,'%5.2f'),' ',char(956),'Mol/sec'];...
                ['YPF/W=',num2str(obj.FixtureData.YPF/obj.FixtureData.Wattage,'%5.2f'),' ',char(956),'Mol/J']};
            x = w*3+20;
            w = floor(obj.Body.Position(3)/5);
            h = floor(obj.Body.Position(4)/6);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.RightCenter = uipanel(obj.Body);
            obj.FixtureInfo.RightCenter.BackgroundColor	= obj.background;
            obj.FixtureInfo.RightCenter.BorderType       = 'none';
            obj.FixtureInfo.RightCenter.Units            = 'pixels';
            obj.FixtureInfo.RightCenter.Position         = [x, y, w, h];
            
            hMetric2 = uicontrol(obj.FixtureInfo.RightCenter,'style','text');
            hMetric2.HorizontalAlignment    = 'Left';
            hMetric2.BackgroundColor        = 'White';
            hMetric2.Units                  = 'pixels';
            hMetric2.Position               = [0, 0, w,(h/5)*4];
            hMetric2.FontName               = 'Arial';
            hMetric2.FontUnits              = 'pixels';
            hMetric2.FontSize               = FontSize;
            hMetric2.String                 = {
                ['PPF%=',num2str(obj.FixtureData.PPFofTotal*100,'%5.2f'),'%'];...
                ['RSS=',num2str(obj.FixtureData.RSS,'%5.2f')];...
                ['RCR=',num2str(obj.FixtureData.RCR,'%5.2f')]};
            x = w*4;
            w = floor(obj.Body.Position(3)/5);
            h = floor(obj.Body.Position(4)/6);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.Right = uipanel(obj.Body);
            obj.FixtureInfo.Right.BackgroundColor  = 'white';
            obj.FixtureInfo.Right.BorderType       = 'none';
            obj.FixtureInfo.Right.Units            = 'pixels';
            obj.FixtureInfo.Right.Position         = [x, y, w, h];
            
            obj.FixtureInfo.imgAxes = axes(obj.FixtureInfo.Right);
            imshow(imread(obj.FixtureData.ImagePath));
        end
        function initIntensityDist(obj)
            %plots in the top left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4)/6))/2;
            y = h;
            
            obj.FixtureInfo.Title = uipanel(obj.Body);
            obj.FixtureInfo.Title.BackgroundColor   = obj.background;
            obj.FixtureInfo.Title.BorderType        = 'none';
            obj.FixtureInfo.Title.Units             = 'pixels';
            obj.FixtureInfo.Title.Position          = [x,y,w,h];
        end
        function initSPDPlot(obj)
            %plots in the top right quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = obj.Body.Position(3)/2;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4)/6))/2;
            y = h;
            
            obj.FixtureInfo.SPD = uipanel(obj.Body);
            obj.FixtureInfo.SPD.BackgroundColor   = obj.background;
            obj.FixtureInfo.SPD.BorderType        = 'none';
            obj.FixtureInfo.SPD.Units             = 'pixels';
            obj.FixtureInfo.SPD.Position          = [x,y,w,h];
            
            obj.FixtureInfo.SPDaxes = axes(obj.FixtureInfo.SPD);
            axis(obj.FixtureInfo.SPDaxes,[380,830,0,inf]);
            plot(obj.FixtureInfo.SPDaxes,obj.FixtureData.Spectrum(:,1),...
                obj.FixtureData.Spectrum(:,2)/max(obj.FixtureData.Spectrum(:,2)),...
                'LineWidth',1);
            axis(obj.FixtureInfo.SPDaxes,[380,830,0,inf]);
            
            
        end
        function initISOPPFPlot(obj)
            %plots in the bottom left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4)/6))/2;
            y = 0;
            
            obj.FixtureInfo.ISOPlot = uipanel(obj.Body);
            obj.FixtureInfo.ISOPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.ISOPlot.BorderType        = 'none';
            obj.FixtureInfo.ISOPlot.Units             = 'pixels';
            obj.FixtureInfo.ISOPlot.Position          = [x,y,w,h];
            ConversionFactor = PPF_Conversion_Factor_05Apr2016(obj.FixtureData.Spectrum(:,1),obj.FixtureData.Spectrum(:,2));
            [Irr,Avg,Max,Min] = PPFCalculator(obj.FixtureData.Spectrum(:,1),obj.FixtureData.Spectrum(:,2),obj.FixtureData.IESdata,'LRcount',1,'TBcount',1,'Multiplier',round(ConversionFactor,1));
            X = 0.25:.5:4.75;
            Y = 0.25:.5:4.75;
            obj.FixtureInfo.SPDaxes = axes(obj.FixtureInfo.ISOPlot);
            [C,h] = contour(obj.FixtureInfo.SPDaxes,X,Y,Irr);
            clabel(C,h,'FontSize',8);
        end
        function initLASEPlot(obj)
            %plots in the bottom right quarter of the body
            x = obj.Body.Position(3)/2;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4)/6))/2;
            y = 0;
            
            obj.FixtureInfo.Title = uipanel(obj.Body);
            obj.FixtureInfo.Title.BackgroundColor   = obj.background;
            obj.FixtureInfo.Title.BorderType        = 'none';
            obj.FixtureInfo.Title.Units             = 'pixels';
            obj.FixtureInfo.Title.Position          = [x,y,w,h];
            
        end
    end
    
    methods (Static, Access = protected)
        
    end
    
end