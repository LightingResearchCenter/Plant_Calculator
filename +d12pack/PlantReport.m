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
            obj.Type = 'LRC Horticultural Metrics';
            obj.PageNumber = [1,2];
            obj.background = [1,1,1];
            obj.HeaderHeight = 75;
            obj.Body.BackgroundColor = obj.background;
            if nargin == 0
                obj.FixtureData = struct('Lamp', 'LED',...
                    'Voltage',120,...
                    'PPF',380.7,...
                    'YPF',337.8,...
                    'PPFofTotal',.9,...
                    'PSS',0.868,...
                    'RCR',37.8,...
                    'ImagePath','E:\Users\plummt\Documents\MATLAB\Plant_Calculator\incandescent.png',...
                    'Product','LED109056',...
                    'Catalog', 'Unknown',...
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
            uistack(obj.LRClogo,'top');
            align([obj.FixtureInfo.ISOaxes, obj.FixtureInfo.LSAEPlot],'distribute','top');
            
        end % End of class constructor
    end
    
    methods (Access = protected)
        function initFixtureInfo(obj)
            %Plots the header portion of the document
            oldUnits = obj.Header.Units;
            obj.Header.Units = 'pixels';
            
            x = 0;
            w = 4*ceil(obj.Header.Position(3)/5)+10;
            h = ceil(obj.Header.Position(4));
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
            % print data into HEADERTABLE.TXT
            data{1} = [obj.FixtureData.Brand, ' ',obj.FixtureData.Product];
            A_str = num2str(round(obj.FixtureData.Voltage));
            data{2} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.PPF,3);
            data{3} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.YPF,3);
            data{4} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.PSS,2);
            data{5} = A_str;
            A_str = num2str(round(obj.FixtureData.Wattage));
            data{6} = A_str;
            [~, A_str] = sd_round((obj.FixtureData.PPF/obj.FixtureData.Wattage),3);
            data{7} = A_str;
            [~, A_str] = sd_round((obj.FixtureData.YPF/obj.FixtureData.Wattage),3);
            data{8} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.RCR,2);
            data{9} = A_str;
            data{10} = obj.FixtureData.Catalog;
            [~, A_str] = sd_round(obj.FixtureData.PowerFactor,2);
            data{11} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.PPFofTotal,2);
            data{12} = A_str;
            A_str = num2str(round(obj.FixtureData.Cost));
            data{13} = A_str;
            [~, A_str] = sd_round(obj.FixtureData.THD,2);
            data{14} = A_str;
            outputText = cellfun(@char,data,'uni',0);
            [str,~] = sprintf(htmltext,outputText{:});
            je = javax.swing.JEditorPane('text/html', str);
            jp = javax.swing.JScrollPane(je);
            [~, hcontainer] = javacomponent(jp, [],obj.FixtureInfo.Title);
            set(hcontainer, 'units', 'normalized', 'position', [-.005,0,1.01,1.01],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 10));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
            
            x = w-5;
            w = ceil(obj.Header.Position(3)/5)+10;
            h = ceil(obj.Header.Position(4));
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
            h = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2)-10;
            y = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2);
            
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
                HPS1000SaveStr = sprintf('($%0.0f)',abs(HPS1000Save));
                HPS1000Pay = 'No Payback';
                incentive1000  = 0;
                newHPS1000Paynum = HPS1000Paynum;
                while (newHPS1000Paynum<0)
                    incentive1000 = incentive1000+1;
                    incentiveCost = (fixtureCost-incentive1000)*fixcount(ind);
                    newHPS1000Paynum = incentiveCost/HPS1000Save;
                    incentive1000str = sprintf('An incentive of at least $%0.0f per luminaire is required to have equal energy costs as the 1000 W HPS system.',incentive1000);
                end
            else
                HPS1000pari = 'yw4l';
                HPS1000SaveStr = sprintf('$%0.0f',HPS1000Save);
                HPS1000Pay =sprintf('%0.0f',HPS1000Paynum);
                incentive1000  = 0;
                newHPS1000Paynum = HPS1000Paynum;
                if newHPS1000Paynum>3
                    while (newHPS1000Paynum>3)
                        incentive1000 = incentive1000+1;
                        incentiveCost = (fixtureCost-incentive1000)*fixcount(ind);
                        newHPS1000Paynum = incentiveCost/HPS1000Save;
                        incentive1000str = sprintf('An incentive of $%0.0f per luminaire would reduce the payback period to less than 3 years compared to 1000 W HPS system.',incentive1000);
                    end
                else
                    incentive1000str = 'No additional incentive is needed when compared to the 1000 W HPS system.';
                end
            end
            if HPS600Save < 0
                HPS600pari = 'pari';
                HPS600SaveStr = sprintf('($%0.0f)',abs(HPS600Save));
                HPS600Pay = 'No Payback';
                incentive600 = 0;
                newHPS600Paynum = HPS600Paynum;
                while (newHPS600Paynum<0)
                    incentive600 = incentive600+1;
                    incentiveCost = (fixtureCost-incentive600)*fixcount(ind);
                    newHPS600Paynum = incentiveCost/HPS600Save;
                    incentive600str = sprintf('An incentive of at least $%0.0f per luminaire is required to have equal energy costs as the 600 W HPS system.',incentive600);
                end
            else
                HPS600pari = 'yw4l';
                HPS600SaveStr = sprintf('$%0.0f',HPS600Save);
                HPS600Pay = sprintf('%0.0f',HPS600Paynum);
                incentive600 = 0;
                newHPS600Paynum = HPS600Paynum;
                if newHPS600Paynum>3
                while (newHPS600Paynum>3)
                    incentive600 = incentive600+1;
                    incentiveCost = (fixtureCost-incentive600)*fixcount(ind);
                    newHPS600Paynum = incentiveCost/HPS600Save;
                    incentive600str = sprintf('An incentive of $%0.0f would reduce the payback period to less than 3 years compared to the 600 W HPS system.',incentive600);
                end
                else
                    incentive600str = 'No additional incentive is needed when compared to the 600 W HPS system.';
                end
            end
            EcoCell = textscan(EconomicTableFile,'%s');
            html = char(EcoCell{:});
            htmltext = reshape(html',1,[]);
            % pring numbers into ECONOMICTABLE.TXT
            data = {obj.FixtureData.Lamp,HPS1000qty,HPS600qty,fixcount(ind),...
                HPS1000qty*HPS1000Cost,HPS600qty*HPS600Cost,...
                obj.FixtureData.Cost*fixcount(ind),...
                HPS1000WpM,HPS600WpM,FixtureWpM,...
                HPS1000kWpY,HPS600kWpY,FixturekWpY,...
                HPS1000EnCost,HPS600EnCost,FixtureEnCost,...
                obj.FixtureData.Lamp,HPS1000pari,HPS1000SaveStr,...
                obj.FixtureData.Lamp,HPS600pari,HPS600SaveStr,...
                incentive1000str,HPS1000Pay,incentive600str,HPS600Pay,...
                energyCost};
            [str,~] = sprintf(htmltext,data{:});
            je = javax.swing.JEditorPane('text/html', str);
            jp = javax.swing.JScrollPane(je);
            [~, hcontainer] = javacomponent(jp, [],obj.FixtureInfo.Economic);
            set(hcontainer, 'units', 'normalized', 'position', [-.005,0,1.01,1.01],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 10));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
            
        end
        function initSPDPlot(obj)
            %plots in the top right quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = obj.Body.Position(3)/2+20;
            w = obj.Body.Position(3)/2;
            h = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2);
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
            ax = gca;
            ax.FontSize = 8;
            title(obj.FixtureInfo.SPDaxes,'Spectral Power Distribution (SPD)^1^0');
            
            xlabel(obj.FixtureInfo.SPDaxes,'Wavelength (nm)','FontSize',10)
            ylabel(obj.FixtureInfo.SPDaxes,'Relative Spectrum (Arb. Units)','FontSize',10)
            obj.FixtureInfo.SPDaxes.YGrid = 'On';
            text(obj.FixtureInfo.SPDaxes,400,.95,sprintf('(Absolute mult.=%0.2f W/nm)',max(obj.FixtureData.Spectrum(:,2))),'FontSize',8);
        end
        function initISOPPFPlot(obj)
            %plots in the bottom left quarter of the body
            oldUnits = obj.Body.Units;
            obj.Body.Units = 'pixels';
            
            x = -10;
            w = ceil(obj.Body.Position(3)/2)+18;
            h = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2)+42;
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
            [Irr,~,~,~] = PPFCalculator(obj.FixtureData.IESdata,'MountHeight',mount,'Length',4,'Width',4,'LRcount',1,'TBcount',1,'calcSpacing',.125,'Multiplier',round(ConversionFactor,1));
            plotLabels = {'-1.5';'-1';'-0.5';'0';'0.5';'1';'1.5'};
            plotMax = 4;
            plotMin = 0;
            plotSplits = size(plotLabels,1)-1;
            X = (calcSpacing-(calcSpacing/2):calcSpacing:plotMax-(calcSpacing/2))';
            Y = (calcSpacing-(calcSpacing/2):calcSpacing:plotMax-(calcSpacing/2));
            obj.FixtureInfo.ISOaxes = axes(obj.FixtureInfo.ISOPlot);
            
            [C,h] = contour(obj.FixtureInfo.ISOaxes,X,Y,Irr,[25,50,100:100:500]);
            
            obj.FixtureInfo.ISOaxes.YTick =[plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
            obj.FixtureInfo.ISOaxes.YTickLabel = plotLabels;
            obj.FixtureInfo.ISOaxes.XTick = [plotMin,(plotMax)/plotSplits:(plotMax)/plotSplits:plotMax-((plotMax)/plotSplits),plotMax];
            obj.FixtureInfo.ISOaxes.XTickLabel = plotLabels;
            obj.FixtureInfo.ISOaxes.YLim = [plotMin,plotMax];
            obj.FixtureInfo.ISOaxes.XLim = [plotMin,plotMax];
            ax = gca;
            ax.FontSize = 8;
            title(obj.FixtureInfo.ISOaxes,sprintf('Iso-PPFD Contours (MH = %0.1f m)^1^1',mount));
            clabel(C,h,'FontSize',8);
            axis(obj.FixtureInfo.ISOaxes,'square');
            obj.FixtureInfo.ISOaxes.XGrid = 'on';
            obj.FixtureInfo.ISOaxes.YGrid = 'on';
            ylabel(obj.FixtureInfo.ISOaxes,'Meters')
            xlabel(obj.FixtureInfo.ISOaxes,'Meters')
            colormap(obj.FixtureInfo.ISOaxes,jet)
            fixX = (plotMax/2)-(obj.FixtureData.IESdata.Width*.5);
            fixY = (plotMax/2)-(obj.FixtureData.IESdata.Length*0.5);
            fixW = obj.FixtureData.IESdata.Width;
            fixH = obj.FixtureData.IESdata.Length;
            rectangle('Position',[fixX,fixY,fixW,fixH],'LineWidth',2);
            align([obj.FixtureInfo.ISOPlot,obj.FixtureInfo.ISOaxes],'center','top');
            uistack(obj.FixtureInfo.ISOPlot,'top');
        end
        function initLASEPlot(obj)
            %plots in the bottom right quarter of the body
            x = obj.Body.Position(3)/2+10;
            w = obj.Body.Position(3)/2-15;
            h = (obj.Body.Position(4) - ceil(obj.Body.Position(4))/2);
            y = 0;
            
            obj.FixtureInfo.LSAEPlot = uipanel(obj.Body);
            obj.FixtureInfo.LSAEPlot.BackgroundColor   = obj.background;
            obj.FixtureInfo.LSAEPlot.BorderType        = 'none';
            obj.FixtureInfo.LSAEPlot.Units             = 'pixels';
            obj.FixtureInfo.LSAEPlot.Position          = [x,y,w,h];
            [~,outTable,LSAE] = fullLSAE(obj.FixtureData.spd,obj.FixtureData.ies,0.5:.5:4,100:100:500,3,10,10);
            obj.FixtureData.LSAE = LSAE;
            obj.FixtureData.outTable = outTable;
            LSAETableFile = fopen('LSAETable.txt');
            LSAEcell = textscan(LSAETableFile,'%s');
            fclose(LSAETableFile);
            html = char(LSAEcell{:});
            htmltext = reshape(html',1,[]);
            LSAEcol = reshape(obj.FixtureData.LSAE',[],1);
            fixcount = obj.FixtureData.outTable.LRcount.*obj.FixtureData.outTable.TBcount;
            % print data into LSAETABLE.TXT
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
            [~, hcontainer] = javacomponent(jp, [], obj.FixtureInfo.LSAEPlot);
            set(hcontainer, 'units', 'normalized', 'position', [0,0,1.01,1.01],'backgroundcolor',[1,1,1]);
            
            java.lang.System.setProperty('awt.useSystemAAFontSettings', 'on');
            je.setFont(java.awt.Font('Arial', java.awt.Font.PLAIN, 10));
            je.putClientProperty(javax.swing.JEditorPane.HONOR_DISPLAY_PROPERTIES, true);
            uistack(obj.FixtureInfo.LSAEPlot,'bottom');
        end
    end
    
    methods (Static, Access = protected)
        
    end
    
end
