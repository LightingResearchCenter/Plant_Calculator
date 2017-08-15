clc
import mlreportgen.dom.*
rpt = Document('LRCHortReport.pdf','pdf','LRC_Hort_Metrics.pdftx');
open(rpt);
while ~strcmp(rpt.CurrentHoleId,'#end#')
    switch rpt.CurrentHoleId
        case 'Manufac'
            append(rpt,'need');
        case 'Product'
            append(rpt,'need');
        case 'Brand1'
            append(rpt,'need');
        case 'Voltage'
            append(rpt,'need');
        case 'PPF'
            %append(rpt,'need');
        case 'YPF'
            append(rpt,'need');
        case 'PSS'
            append(rpt,'need');
        case 'FixtureImg'
            append(rpt,'need');
        case 'Brand2'
            append(rpt,'need');
        case 'Power'
            append(rpt,'need');
        case 'PPFperW'
            append(rpt,'need');
        case 'YPFperW'
            append(rpt,'need');
        case 'RCR'
            append(rpt,'need');
        case 'Brand3'
            append(rpt,'need');
        case 'PF'
            append(rpt,'need');
        case 'PPFper'
            append(rpt,'need');
        case 'Brand4'
            append(rpt,'need');
        case 'THD'
            append(rpt,'need');
        case 'PPFRank'
            append(rpt,'need');
        case 'PPFDRank'
            append(rpt,'need');
        case 'Lamp2'
            append(rpt,'need');
        case 'MountHeight'
            append(rpt,'need');
        case 'ISOPPFDpic'
            append(rpt,'need');
        case 'IntenDistImg'
            append(rpt,'need');
        case 'SPDpic'
            append(rpt,'need');
        case 'SPDpic2'
            append(rpt,'need');
        case 'SPDTheataPlot'
            append(rpt,'need');
        case 'Costpic1'
            append(rpt,'need');
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
            append(rpt,lsaeIndex);
            moveToNextHole(rpt);
            append(rpt,lsaeIndex);
            lsaeIndex =lsaeIndex +1;
            while lsaeIndex<49
                moveToNextHole(rpt);
                append(rpt,lsaeIndex);
                moveToNextHole(rpt);
                append(rpt,lsaeIndex);
                lsaeIndex =lsaeIndex +1;
                
            end
        case 'ratio11'
            ratioIndex = 1;
            append(rpt,ratioIndex);
            ratioIndex =ratioIndex +1;
            while ratioIndex<37
                moveToNextHole(rpt);
                append(rpt,ratioIndex);
                ratioIndex =ratioIndex +1;
                
            end
        otherwise
            disp(rpt.CurrentHoleId);
    end
    moveToNextHole(rpt);
end
close(rpt);
rptview(rpt.OutputPath);