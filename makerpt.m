function rpt = makerpt(Data,rptname)
clc
import mlreportgen.dom.*
rpt = Document(rptname,'pdf','LRC_Hort_Metrics.pdftx');
open(rpt);
while ~strcmp(rpt.CurrentHoleId,'#end#')
    switch rpt.CurrentHoleId
        case 'Brand'
            append(rpt,Data.Brand);
        case 'Product'
            append(rpt,Data.Product);
        case 'Catalog1'
            append(rpt,Data.CatalogArr{1});
        case 'Voltage'
            append(rpt,sprintf('%0.0f',round(Data.Volts)));
        case 'PPF'
            append(rpt,sprintf('%0.0f',Data.PPF));
        case 'PSS'
            append(rpt,sprintf('%0.2f',Data.PSS));
        case 'FixtureImg'
            img = Image(Data.Image);
            img.Style = {Height('0.6in')};
            append(rpt,img);
        case 'Catalog2'
            append(rpt,Data.CatalogArr{2});
        case 'Power'
            append(rpt,sprintf('%d',round(Data.Wattage)));
        case 'PPFperW'
            append(rpt,sprintf('%0.2f',Data.PPFperW));
        case 'Catalog3'
            append(rpt,Data.CatalogArr{3});
        case 'PF'
            append(rpt,sprintf('%0.3f',Data.PF));
        case 'PPFper'
            append(rpt,sprintf('%0.1f',Data.PPFofTotal));
        case 'Catalog4'
            append(rpt,Data.CatalogArr{4});
        case 'THD'
            append(rpt,sprintf('%0.2f',Data.THD));
        case 'PPFRank'
            img = Image(Data.PPFRank);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'PPFDRank'
            img = Image(Data.PPFperWRank);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'Lamp2'
            append(rpt,Data.Source);
        case 'MountHeight'
            append(rpt,sprintf('%d',round(Data.mount)));
        case 'ISOPPFDpic'
            img = Image(Data.ISOPlot);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'IntenDistImg'
            img = Image(Data.IntensityDistplot);
            img.Style = {Height('2.5in')};
            append(rpt,img);
        case 'SPDpic'
            img = Image(Data.SPDPlot);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'SPDTheataPlot'
            if exist(Data.SPDthetaPlot,'file')
                img = Image(Data.SPDthetaPlot);
                img.Style = {Width('3.25in')};
                append(rpt,img);
            else
                append(rpt,'Not Available with the Data Provided');
            end
        case 'Costpic1'
            img = Image(Data.LCCA10Plot);
            img.Style = {Height('1.75in')};
            append(rpt,img);
        case 'Costpic2'
            img = Image(Data.LCCA20Plot);
            img.Style = {Height('1.75in')};
            append(rpt,img);
        case '#start#'
            sect = rpt.CurrentPageLayout;
            for i = 1:numel(sect.PageFooters)
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'GenTime'
                            date = datestr(now,'yyyy/mm/dd');
                            append(pageFooter,date);
                        otherwise
                            disp(pageFooter.CurrentHoleId);
                    end
                    moveToNextHole(pageFooter);
                end
            end
        case '#sect2#'
            sect = rpt.CurrentPageLayout;
            for i = 1:numel(sect.PageFooters)
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'GenTime'
                            date = datestr(now,'yyyy mmmm dd');
                            append(pageFooter,date);
                        otherwise
                            disp(pageFooter.CurrentHoleId);
                    end
                    moveToNextHole(pageFooter);
                end
            end
        case 'Eco01'
            append(rpt,sprintf('%d',round(Data.Eco.HPS1000.Qty)));%1000W HPS QTY
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(Data.Eco.HPS600.Qty)));%600W HPS QTY
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(Data.Eco.fix.Qty)));%Current Lamp QTY
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS1000.Init,',###')));%1000W HPS Init
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS600.Init,',###')));%600W HPS Init
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.fix.Init,',###')));%Current Lamp Init
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS1000.InitFt,',###')));%1000W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('($%s)',numberFormatter(Data.Eco.HPS1000.InitM,',###')));%1000W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS600.InitFt,',###')));%600W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('($%s)',numberFormatter(Data.Eco.HPS600.InitM,',###')));%600W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.fix.InitFt,',###')));%Current Lamp Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('($%s)',numberFormatter(Data.Eco.fix.InitM,',###')));%Current Lamp Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.WFt,',###')));%1000W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.WM,',###')));%1000W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.WFt,',###')));%600W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.WM,',###')));%600W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.WFt,',###')));%Current Lamp Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.WM,',###')));%Current Lamp Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.kWftYr,',###')));%1000W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.kWmYr,',###')));%1000W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.kWftYr,',###')));%600W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.kWmYr,',###')));%600W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.kWftYr,',###')));%Current Lamp Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.kWmYr,',###')));%Current Lamp Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.CostFtLow,',###.00')));%1000W HPS Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.CostmLow,',###.00')));%1000W HPS Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.CostFtLow,',###.00')));%600W HPS Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.CostmLow,',###.00')));%600W HPS Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.CostFtLow,',###.00')));%Current Lamp Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.CostmLow,',###.00')));%Current Lamp Energy Cost Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.CostFtHigh,',###.00')));%1000W HPS Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.CostmHigh,',###.00')));%1000W HPS Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.CostFtLow,',###.00')));%600W HPS Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.CostmLow,',###.00')));%600W HPS Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.CostFtHigh,',###.00')));%Current Lamp Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.CostmHigh,',###.00')));%Current Lamp Energy Cost High
            moveToNextHole(rpt);
            append(rpt,sprintf('%s%%',numberFormatter(Data.Eco.HPS1000.RORLow(1)*100,',###.0')));%1000W HPS ROR Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s%%',numberFormatter(Data.Eco.HPS1000.RORHigh(1)*100,',###.0')));%1000W HPS ROR Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s%%',numberFormatter(Data.Eco.HPS600.RORLow(1)*100,',###.0')));%600W HPS ROR Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s%%',numberFormatter(Data.Eco.HPS600.RORHigh(1)*100,',###.0')));%600W HPS ROR Low
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS1000.TotPayLow(end),',###')));%1000W HPS Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS600.TotPayLow(end),',###')));%600W HPS Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.fix.TotPayLow(end),',###')));%Current Lamp Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS1000.TotPayHigh(end),',###')));%1000W HPS Present Worth High
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.HPS600.TotPayHigh(end),',###')));%600W HPS Present Worth High
            moveToNextHole(rpt);
            append(rpt,sprintf('$%s',numberFormatter(Data.Eco.fix.TotPayHigh(end),',###')));%Current Lamp Present Worth High
        case 'LSAE101'
            lsaeIndex = 1;
            maxVal = max(Data.outTable.LSAE);
            LSAEmax(1) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==100));
            LSAEmax(2) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==200));
            LSAEmax(3) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==300));
            LSAEmax(4) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==400));
            LSAEmax(5) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==500));
            LSAEmax(6) = max(Data.outTable.LSAE(Data.outTable.targetPPFD(:)==1000));
            if Data.outTable.LSAE(lsaeIndex) == maxVal
                obj=append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)),'maxAll');
            elseif any(Data.outTable.LSAE(lsaeIndex) == LSAEmax)
                append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)),'max');
            else
                append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)));
            end
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(size(Data.outTable.count{lsaeIndex},1))));
            lsaeIndex =lsaeIndex +1;
            while lsaeIndex<49
                moveToNextHole(rpt);
                if Data.outTable.LSAE(lsaeIndex) == maxVal
                    append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)),'maxAll');
                elseif any(Data.outTable.LSAE(lsaeIndex) == LSAEmax)
                    append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)),'max');
                else
                    append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)));
                end
                moveToNextHole(rpt);
                append(rpt,sprintf('%d',round(size(Data.outTable.count{lsaeIndex},1))));
                lsaeIndex =lsaeIndex +1; 
            end
        case 'ratio11'
            ratioIndex = 1;
            append(rpt,sprintf('%0.2f',Data.UVaPer(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.bluePer(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.redPer(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.FRPer(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.blueRed(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.redFR(ratioIndex)));
            ratioIndex =ratioIndex +1;
            while ratioIndex<=6
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.UVaPer(ratioIndex)));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.bluePer(ratioIndex)));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.redPer(ratioIndex)));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.FRPer(ratioIndex)));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.blueRed(ratioIndex)));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.redFR(ratioIndex)));
                ratioIndex =ratioIndex +1;
            end
        otherwise
            disp(rpt.CurrentHoleId);
    end
    moveToNextHole(rpt);
end
close(rpt);
rptview(rpt.OutputPath);
end