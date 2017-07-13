function makerpt(Data,rptname,rpttemplate)
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
rpt.CurrentHoleId
while ~strcmp(rpt.CurrentHoleId,'#end#')
    
    switch rpt.CurrentHoleId
        case 'Brand1'
            append(rpt,Data.brand1);
        case 'Brand2'
            append(rpt,Data.brand2);
        case 'Brand3'
            append(rpt,Data.brand3);
        case 'Brand4'
            append(rpt,Data.brand4);
        case 'Voltage'
            append(rpt,Data.Voltage);
        case 'PPF'
            append(rpt,Data.PPF);
        case 'YPF'
            append(rpt,Data.YPF);
        case 'PSS'
            append(rpt,Data.PSS);
        case 'FixtureImg'
            plot1 = Image(char('incandescent.png'));
            plot1.Height = '.7in';
            append(rpt,plot1);
        case 'Power'
            append(rpt,Data.Power);
        case 'PPFperW'
            append(rpt,Data.PPFperW);
        case 'YPFperW'
            append(rpt,Data.YPFperW);
        case 'RCR'
            append(rpt,Data.RCR);
        case 'PF'
            append(rpt,Data.PF);
        case 'PPFper'
            append(rpt,Data.PPFper);
        case 'THD'
            append(rpt,Data.THD);
        case 'Lamp'
            append(rpt,'LED');
        case 'HPS1000qty'
            append(rpt,'LED');
        case 'HPS600qty'
            append(rpt,'LED');
        case 'Lampqty'
            append(rpt,'LED');
        case 'HPS1000init'
            append(rpt,'LED');
        case 'HPS600init'
            append(rpt,'LED');
        case 'Lampinit'
            append(rpt,'LED');
        case 'HPS1000initPerM'
            append(rpt,'LED');
        case 'HPS600initPerM'
            append(rpt,'LED');
        case 'LampinitPerM'
            append(rpt,'LED');
        case 'HPS1000initPerFt'
            append(rpt,'LED');
        case 'HPS600WperM'
            append(rpt,'LED');
        case 'LampWperM'
            append(rpt,'LED');
        case 'HPS1000WperFt'
            append(rpt,'LED');
        case 'HPS600WperFt'
            append(rpt,'LED');
        case 'LampWperFt'
            append(rpt,'LED');
        case 'HPS1000WperMYear'
            append(rpt,'LED');
        case 'HPS600WperMYear'
            append(rpt,'LED');
        case 'LampWperMYear'
            append(rpt,'LED');
        case 'HPS1000CostMYear'
            append(rpt,'LED');
        case 'HPS600CostMYear'
            append(rpt,'LED');
        case 'LampCostMYear'
            append(rpt,'LED');
        case 'HPS1000CostFtYear'
            append(rpt,'LED');
        case 'HPS600CostFtYear'
            append(rpt,'LED');
        case 'LampCostFtYear'
            append(rpt,'LED');
        case 'HPS1000Save'
            append(rpt,'LED');
        case 'HPS600Save'
            append(rpt,'LED');
        case 'HPS1000Pay'
            append(rpt,'LED');
        case 'HPS600Pay'
            append(rpt,'LED');
        case 'SPDpic'
            append(rpt,'LED');
        case 'LSAEidealMH'
            append(rpt,'LED');
        case 'ISOPPFDimg'
            append(rpt,'LED');
    end
    moveToNextHole(rpt);
    rpt.CurrentHoleId
end

close(rpt);
rptview(rpt.OutputPath);