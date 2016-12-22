classdef PlantReport < d12pack.report
    %PLANTREPORT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
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
            obj.initFixtureInfo();
            
        end % End of class constructor
    end
    
    methods (Access = protected)
        function initFixtureInfo(obj)
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/4;
            h = floor(obj.Body.Position(4)/4);
            y = obj.Body.Position(4) - h;
            
            obj.FixtureInfo.Title = uipanel(obj.Body);
            obj.FixtureInfo.Title.BackgroundColor	= 'White';
            obj.FixtureInfo.Title.BorderType = 'none';
            obj.FixtureInfo.Title.Units = 'pixels';
            obj.FixtureInfo.Title.Position = [x,y,w,h];
            
            hTitle = annotation(obj.FixtureInfo.Title,'textbox');
            hTitle.HorizontalAlignment = 'Left';
            hTitle.LineStyle = 'none';
            hTitle.Units = 'pixels';
            hTitle.Position = [0,h-23,w,23];
            hTitle.FontName = 'Arial';
            hTitle.FontUnits = 'pixels';
            hTitle.FontSize = 16;
            hTitle.FontWeight = 'bold';
            hTitle.String = {'Data Sheet'};
            
            hProduct = annotation(obj.FixtureInfo.Title,'textbox');
            hProduct.HorizontalAlignment = 'Left';
            hProduct.LineStyle = 'none';
            hProduct.Units = 'pixels';
            hProduct.Position = [0,h-(20*3),w,46];
            hProduct.FontName = 'Arial';
            hProduct.FontUnits = 'pixels';
            hProduct.FontSize = 14;
            hProduct.String = {'Product Name';...
                'Catolog Number'};
        end
       
    end
    
    methods (Static, Access = protected)
        
        
    end
    
end


