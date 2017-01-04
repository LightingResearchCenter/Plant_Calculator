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
                                            'Wattage',60,...
                                            'Voltage',120,...
                                            'PPF',12,...
                                            'YPF',16,...
                                            'PPFofTotal',.9,...
                                            'RSS',22,...
                                            'RCR',23,...
                                            'ImagePath','incandescent.png',...
                                            'Product','GE A-Lamp',...
                                            'Catalog','#GC1-40C-MV-CW-2M-GY',...
                                            'Spectrum',load('\\ROOT\projects\IPH_PlantPathology\Testing\Nichia\Cool LED average.txt'));
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
            obj.FixtureInfo.Title.Position          = [x,y,w+30,h];
            
            FontSize = 16;
            hTitle = uicontrol(obj.FixtureInfo.Title,'style','text');
            hTitle.HorizontalAlignment  = 'Left';
            hTitle.BackgroundColor      = 'White';
            hTitle.Units                = 'pixels';
            hTitle.Position             = [0,(h/4)*3,w,h/4];
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
            obj.FixtureInfo.LeftCenter.Position         = [x, y, w+30, h];
            
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
            obj.FixtureInfo.Center.Position         = [x, y, w+30, h];
            
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
            obj.FixtureInfo.RightCenter.Position         = [x, y, w+30, h];
            
            hMetric2 = uicontrol(obj.FixtureInfo.RightCenter,'style','text');
            hMetric2.HorizontalAlignment    = 'Left';
            hMetric2.BackgroundColor        = 'White';
            hMetric2.Units                  = 'pixels';
            hMetric2.Position               = [0, 0, w,(h/5)*4];
            hMetric2.FontName               = 'Arial';
            hMetric2.FontUnits              = 'pixels';
            hMetric2.FontSize               = FontSize;
            hMetric2.String                 = {  ['PPF%=',num2str(obj.FixtureData.PPFofTotal*100,'%5.2f'),'%'];...
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
            plot(obj.FixtureInfo.SPDaxes,obj.FixtureData.Spectrum(:,1),...
                obj.FixtureData.Spectrum(:,2)/max(obj.FixtureData.Spectrum(:,2)),...
                'LineWidth',2);
            
            
        end
        function initISOPPFPlot(obj)
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4)/6))/2;
            y = 0;
            
            obj.FixtureInfo.Title = uipanel(obj.Body);
            obj.FixtureInfo.Title.BackgroundColor   = obj.background;
            obj.FixtureInfo.Title.BorderType        = 'none';
            obj.FixtureInfo.Title.Units             = 'pixels';
            obj.FixtureInfo.Title.Position          = [x,y,w,h];
            
            
        end
        function initLASEPlot(obj)
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