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
            append(rpt,sprintf('%d',round(Data.Volts)));
        case 'PPF'
            append(rpt,sprintf('%0.1f',Data.PPF));
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
            append(rpt,sprintf('%0.3f',Data.PPFperW));
        case 'PPFper'
            append(rpt,sprintf('%0.2f',Data.PPFofTotal));
        case 'Catalog4'
            append(rpt,Data.CatalogArr{4});
        case 'THD'
            append(rpt,sprintf('%0.3f',Data.THD));
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
                            date = datestr(now,'yyyy mmmm dd');
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
            EcoIndex = 1;
            append(rpt,EcoIndex);
            EcoIndex =EcoIndex +1;
            while EcoIndex<32
                moveToNextHole(rpt);
                append(rpt,EcoIndex);
                EcoIndex =EcoIndex +1;
            end
        case 'LSAE101'
            lsaeIndex = 1;
            append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(size(Data.outTable.count{lsaeIndex},1))));
            lsaeIndex =lsaeIndex +1;
            while lsaeIndex<49
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f',Data.outTable.LSAE(lsaeIndex)));
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