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
            obj.HeaderHeight = 75;
            if nargin == 0
                obj.FixtureData = struct(   'Lamp','LED',...
                    'Voltage',120,...
                    'PPF',380.7,...
                    'YPF',337.8,...
                    'PPFofTotal',.9,...
                    'PSS',0.868,...
                    'RCR',325537.8,...
                    'ImagePath','E:\Users\plummt\Documents\MATLAB\Plant_Calculator\incandescent.png',...
                    'Product','LED109056',...
                    'Catalog','Unknown',...
                    'Cost',100.00,...
                    'THD',12,...
                    'spd','\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\Trial2\SPD\LED109053109053SPD.txt',...
                    'Spectrum',load('\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\Trial2\SPD\LED109053109053SPD.txt'),...
                    'ies','\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies',...
                    'IESdata',IESFile('\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies'));
                obj.FixtureData.Wattage =   obj.FixtureData.IESdata.InputWatts;
            elseif nargin == 1
                obj.FixtureData = varargin{1};
            else
                error('Too many inputs');
            end
            obj.initFixtureInfo();
            obj.initLASEPlot();
            obj.initEconomic();
            obj.initSPDPlot();
            obj.initISOPPFPlot();
            
        end % End of class constructor
    end
    
    methods (Access = protected)
        function initFixtureInfo(obj)
            %Plots the header portion of the document
            oldUnits = obj.Header.Units;
            obj.Header.Units = 'pixels';
            
            x = 0;
            w = 4*floor(obj.Header.Position(3)/5)+10;
            h = floor(obj.Header.Position(4));
            y = obj.Header.Position(4) - h;
            
            obj.FixtureInfo.Title = uipanel(obj.Header);
            obj.FixtureInfo.Title.BackgroundColor   = obj.background;
            obj.FixtureInfo.Title.BorderType        = 'none';
            obj.FixtureInfo.Title.Units             = 'pixels';
            obj.FixtureInfo.Title.Position          = [x,y,w,h];
            headerTableFile = fopen('headerTable.txt');
            headercell = textscan(headerTableFile,'%s');
            html = char(headercell{:});
            htmltext = reshape(html',1,[]);
            data = {obj.FixtureData.Product;...
                obj.FixtureData.Voltage;obj.FixtureData.PPF;obj.FixtureData.YPF;obj.FixtureData.PSS;...
                obj.FixtureData.Lamp;obj.FixtureData.Wattage;(obj.FixtureData.PPF/obj.FixtureData.Wattage);...
                (obj.FixtureData.YPF/obj.FixtureData.Wattage);obj.FixtureData.RCR;obj.FixtureData.Catalog;...
                (obj.FixtureData.Wattage/obj.FixtureData.Voltage);obj.FixtureData.PPFofTotal;...
                obj.FixtureData.Cost;obj.FixtureData.THD};
            [str,~] = sprintf(htmltext,data{:});
            je = javax.swing.JEditorPane('text/html', str);
            jp = javax.swing.JScrollPane(je);
            [hcomponent, hcontainer] = javacomponent(jp, [],obj.FixtureInfo.Title);
            set(hcontainer, 'units', 'normalized', 'position', [-.005,0,1.01,1.01],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 13));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
            
            x = w-5;
            w = floor(obj.Header.Position(3)/5)+10;
            h = floor(obj.Header.Position(4));
            y = obj.Header.Position(4)-h;
            
            obj.FixtureInfo.Right = uipanel(obj.Header);
            obj.FixtureInfo.Right.BackgroundColor  = 'white';
            obj.FixtureInfo.Right.BorderType       = 'none';
            obj.FixtureInfo.Right.Units            = 'pixels';
            obj.FixtureInfo.Right.Position         = [x, y, w, h];
            
            obj.FixtureInfo.imgAxes = axes(obj.FixtureInfo.Right);
            
            imshow(imread(obj.FixtureData.ImagePath));
            obj.FixtureInfo.imgAxes.Position = [0 0 1 1];
        end
        function initEconomic(obj)
            %plots in the top left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = (obj.Body.Position(3)/2)-2;
            h = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2);
            y = h;
            
            obj.FixtureInfo.Economic = uipanel(obj.Body);
            obj.FixtureInfo.Economic.BackgroundColor   = obj.background;
            obj.FixtureInfo.Economic.BorderType        = 'none';
            obj.FixtureInfo.Economic.Units             = 'pixels';
            obj.FixtureInfo.Economic.Position          = [x,y,w,h];
            LSAEcol = obj.FixtureData.LSAE(:,3);
            fixcount = obj.FixtureData.outTable.LRcount.*obj.FixtureData.outTable.TBcount;
            [~,ind]= max(LSAEcol);
            ind = ((ind-1)*5)+3;  
            load('PlantCalculatorHPSfixtures.mat');
            HPS1000qty = HPS1000Table.LRcount(59)*HPS1000Table.TBcount(59); %2m @300ppfd target
            HPS600qty = HPS600Table.LRcount(59)*HPS600Table.TBcount(59); %2m @300ppfd target
            HPS1000Cost = 525;
            HPS600Cost = 460;
            HPS1000watt = HPS600IES.InputWatts;
            HPS600watt=HPS600IES.InputWatts;
            energyCost=0.1048;
            fixtureCost =  obj.FixtureData.Cost;
            HPS1000WpM = (HPS1000watt*HPS1000qty)/10;
            HPS600WpM = (HPS600watt*HPS600qty)/10;
            FixtureWpM = (obj.FixtureData.Wattage*fixcount(ind))/10;
            HPS1000kWpY = (HPS1000WpM*365*12)/1000;
            HPS600kWpY = (HPS600WpM*365*12)/1000;
            FixturekWpY = (FixtureWpM*365*12)/1000;
            HPS1000EnCost = HPS1000kWpY*energyCost;
            HPS600EnCost = HPS600kWpY*energyCost;
            FixtureEnCost = FixturekWpY*energyCost;
            EconomicTableFile = fopen('economicTable.txt');
            HPS1000Save = HPS1000EnCost-FixtureEnCost;
            HPS600Save = HPS600EnCost-FixtureEnCost;
            HPS1000Paynum = (fixtureCost*fixcount(ind))/HPS1000Save;
            HPS600Paynum = (fixtureCost*fixcount(ind))/HPS600Save;
            if HPS1000Save < 0
                HPS1000pari = 'pari';
                HPS1000Pay = 'No Payback';
                incentive1000  = 0;
                newHPS1000Paynum = HPS1000Paynum;
                while (newHPS1000Paynum<0)
                    incentive1000 = incentive1000+1;
                    incentiveCost = (fixtureCost-incentive1000)*fixcount(ind);
                    newHPS1000Paynum = incentiveCost/HPS1000Save;
                    incentive1000str = sprintf('An incentive of at least $%0.0f per luminaire is required to have equal engergy cost as the 1000 W HPS system.',incentive1000);
                end
            else
                HPS1000pari = 'yw4l';
                HPS1000Pay =sprintf('%0.0f',HPS1000Paynum);
                incentive1000  = 0;
                newHPS1000Paynum = HPS1000Paynum;
                if newHPS1000Paynum>3
                    while (newHPS1000Paynum>3)
                        incentive1000 = incentive1000+1;
                        incentiveCost = (fixtureCost-incentive1000)*fixcount(ind);
                        newHPS1000Paynum = incentiveCost/HPS1000Save;
                        incentive1000str = sprintf('An incentive of $%0.0f per luminare would reduce the payback period to less than 3 years compaired to 1000 W HPS system.',incentive1000);
                    end
                else
                    incentive1000str = 'No additional incentive is needed when compaired to the 1000 W HPS system.';
                end
            end
            if HPS600Save < 0
                HPS600pari = 'pari';
                HPS600Pay = 'No Payback';
                incentive600 = 0;
                newHPS600Paynum = HPS600Paynum;
                while (newHPS600Paynum<0)
                    incentive600 = incentive600+1;
                    incentiveCost = (fixtureCost-incentive600)*fixcount(ind);
                    newHPS600Paynum = incentiveCost/HPS600Save;
                    incentive600str = sprintf('An incentive of $%0.0f per luminare would reduce the payback period to less than 3 years compaired to 600 W HPS system.',incentive600);
                end
            else
                HPS600pari = 'yw4l';
                HPS600Pay = sprintf('%0.0f',HPS600Paynum);
                incentive600 = 0;
                newHPS600Paynum = HPS600Paynum;
                if newHPS600Paynum>3
                while (newHPS600Paynum>3)
                    incentive600 = incentive600+1;
                    incentiveCost = (fixtureCost-incentive600)*fixcount(ind);
                    newHPS600Paynum = incentiveCost/HPS600Save;
                    incentive600str = sprintf('An incentive of $%0.0f would reduce the payback period to less than 3 years compaired to the 600 W HPS.',incentive600);
                end
                else
                    incentive600str = 'No additional incentive is needed when compaired to the 600 W HPS system.';
                end
            end
            EcoCell = textscan(EconomicTableFile,'%s');
            html = char(EcoCell{:});
            htmltext = reshape(html',1,[]);
            data = {obj.FixtureData.Lamp,HPS1000qty,HPS600qty,fixcount(ind),...
                HPS1000qty*HPS1000Cost,HPS600qty*HPS600Cost,...
                obj.FixtureData.Cost*fixcount(ind),...
                HPS1000WpM,HPS600WpM,FixtureWpM,...
                HPS1000kWpY,HPS600kWpY,FixturekWpY,...
                HPS1000EnCost,HPS600EnCost,FixtureEnCost,...
                obj.FixtureData.Lamp,HPS1000pari,HPS1000Save,...
                obj.FixtureData.Lamp,HPS600pari,HPS600Save,...
                ceil(HPS1000Pay),ceil(HPS600Pay),...
                energyCost, incentive1000str, incentive600str};
            [str,~] = sprintf(htmltext,data{:});
            je = javax.swing.JEditorPane('text/html', str);
            jp = javax.swing.JScrollPane(je);
            [hcomponent, hcontainer] = javacomponent(jp, [],obj.FixtureInfo.Economic);
            set(hcontainer, 'units', 'normalized', 'position', [-.005,0,1.01,1.01],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 13));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
            
        end
        function initSPDPlot(obj)
            %plots in the top right quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = obj.Body.Position(3)/2;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4))/2);
            y = h;
            
            obj.FixtureInfo.SPD = uipanel(obj.Body);
            obj.FixtureInfo.SPD.BackgroundColor   = obj.background;
            obj.FixtureInfo.SPD.BorderType        = 'none';
            obj.FixtureInfo.SPD.Units             = 'pixels';
            obj.FixtureInfo.SPD.Position          = [x,y,w,h];
            
            obj.FixtureInfo.SPDaxes = axes(obj.FixtureInfo.SPD);
            plot(obj.FixtureInfo.SPDaxes,obj.FixtureData.Spectrum(:,1),...
                obj.FixtureData.Spectrum(:,2)/max(obj.FixtureData.Spectrum(:,2)),...
                'LineWidth',1);
            axis(obj.FixtureInfo.SPDaxes,[380,830,0,inf]);
            title(obj.FixtureInfo.SPDaxes,'Spectral Power Distribution (SPD)');
            
            xlabel(obj.FixtureInfo.SPDaxes,'Wavelength (nm)')
            ylabel(obj.FixtureInfo.SPDaxes,'Relative Spectrum (Arb. Units)')
            obj.FixtureInfo.SPDaxes.YGrid = 'On';
            text(obj.FixtureInfo.SPDaxes,475,.95,sprintf('(Absolute mult.=%0.2f W/nm)',max(obj.FixtureData.Spectrum(:,2))));
        end
        function initISOPPFPlot(obj)
            %plots in the bottom left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = 0;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4))/2);
            y = 0;
            obj.FixtureInfo.ISOPlot = uipanel(obj.Body);
            obj.FixtureInfo.ISOPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.ISOPlot.BorderType        = 'none';
            obj.FixtureInfo.ISOPlot.Units             = 'pixels';
            obj.FixtureInfo.ISOPlot.Position          = [x,y,w,h];
            
            LSAEcol = reshape(obj.FixtureData.LSAE,[],1);
            [~,ind] = max(LSAEcol);
            if mod(ind,8) == 0
                mount = 4;
            else
                mount = mod(ind,8)*0.5;
            end
            ConversionFactor = PPF_Conversion_Factor_05Apr2016(obj.FixtureData.Spectrum(:,1),obj.FixtureData.Spectrum(:,2));
            calcSpacing = 0.125;
            [Irr,Avg,Max,Min] = PPFCalculator(obj.FixtureData.Spectrum(:,1),obj.FixtureData.Spectrum(:,2),obj.FixtureData.IESdata,'MountHeight',mount,'Length',4,'Width',4,'LRcount',1,'TBcount',1,'calcSpacing',.125,'Multiplier',round(ConversionFactor,1));
            
            X = (calcSpacing-(calcSpacing/2):calcSpacing:4-(calcSpacing/2))';
            Y = (calcSpacing-(calcSpacing/2):calcSpacing:4-(calcSpacing/2));
            x = 0;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4))/2);
            y = 0;
            obj.FixtureInfo.ISOaxes = axes(obj.FixtureInfo.ISOPlot);
            
            [C,h] = contour(obj.FixtureInfo.ISOaxes,X,Y,Irr,[25,50,100:100:500]);
            
            obj.FixtureInfo.ISOaxes.YTick =[0,(4)/6:(4)/6:4-((4)/6),4];
            obj.FixtureInfo.ISOaxes.YTickLabel = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
            obj.FixtureInfo.ISOaxes.XTick = [0,(4)/6:(4)/6:4-((4)/6),4];
            obj.FixtureInfo.ISOaxes.XTickLabel = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
            obj.FixtureInfo.ISOaxes.YLim = [0,4];
            obj.FixtureInfo.ISOaxes.XLim = [0,4];
            title(obj.FixtureInfo.ISOaxes,sprintf('Iso-PPFD Countours (MH= %0.1fm)',mount));
            clabel(C,h,'FontSize',8);
            axis(obj.FixtureInfo.ISOaxes,'square');
            obj.FixtureInfo.ISOaxes.XGrid = 'on';
            obj.FixtureInfo.ISOaxes.YGrid = 'on';
            ylabel(obj.FixtureInfo.ISOaxes,'Meters')
            xlabel(obj.FixtureInfo.ISOaxes,'Meters')
            colormap(obj.FixtureInfo.ISOaxes,jet)
            fixX = 2-(.5*obj.FixtureData.IESdata.Length);
            fixY = 2-(.5*obj.FixtureData.IESdata.Width);
            fixW = obj.FixtureData.IESdata.Length;
            fixH = obj.FixtureData.IESdata.Width;
            
            rectangle('Position',[fixX,fixY,fixW,fixH],'LineWidth',2)
%             points = bbox2points([fixX,fixY,fixW,fixH]);
            %             line(points([1;3;2;4],1),points([1;3;2;4],2),'Color','Black')
        end
        function initLASEPlot(obj)
            %plots in the bottom right quarter of the body
            x = obj.Body.Position(3)/2;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - floor(obj.Body.Position(4))/2);
            y = 0;
            
            obj.FixtureInfo.LSAEPlot = uipanel(obj.Body);
            obj.FixtureInfo.LSAEPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.LSAEPlot.BorderType        = 'none';
            obj.FixtureInfo.LSAEPlot.Units             = 'pixels';
            obj.FixtureInfo.LSAEPlot.Position          = [x,y,w,h];
            [IrrOut,outTable,LSAE] = fullLSAE(obj.FixtureData.spd,obj.FixtureData.ies,0.5:.5:4,100:100:500,3,10,10);
            obj.FixtureData.LSAE = LSAE;
            obj.FixtureData.outTable = outTable;
            LSAETableFile = fopen('LSAETable.txt');
            LSAEcell = textscan(LSAETableFile,'%s');
            fclose(LSAETableFile);
            html = char(LSAEcell{:});
            htmltext = reshape(html',1,[]);
            LSAEcol = reshape(obj.FixtureData.LSAE',[],1);
            fixcount = obj.FixtureData.outTable.LRcount.*obj.FixtureData.outTable.TBcount;
            textarray = cell(length(LSAEcol*2),1);
            for i = 1:length(LSAEcol)
                if LSAEcol(i)==max(LSAEcol)
                    textarray{3*i-2} = 'bold';
                elseif sum(LSAEcol(i)==max(LSAE))
                    textarray{3*i-2} = 'shade';
                else
                    textarray{3*i-2} = 'normal';
                end
                textarray{3*i-1} = LSAEcol(i);
                textarray{3*i} = fixcount(i);
            end
            je = javax.swing.JEditorPane('text/html', sprintf(htmltext,textarray{:}));
            jp = javax.swing.JScrollPane(je);
            [hcomponent, hcontainer] = javacomponent(jp, [], obj.FixtureInfo.LSAEPlot);
            set(hcontainer, 'units', 'normalized', 'position', [0,0,1.01,1],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 13));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
        end
    end
    
    methods (Static, Access = protected)
        
    end
    
end