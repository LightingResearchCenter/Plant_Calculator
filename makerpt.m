function makerpt(Data,rptname,rpttemplate)
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
while ~strcmp(rpt.CurrentHoleId,'#end#')
    switch rpt.CurrentHoleId
        case 'Brand1'
            append(rpt,Data.Brand1);
        case 'Brand2'
            append(rpt,Data.Brand2);
        case 'Brand3'
            append(rpt,Data.Brand3);
        case 'Brand4'
            append(rpt,Data.Brand4);
        case 'Voltage'
            append(rpt,Data.Voltage);
        case 'PPF'
            append(rpt,Data.PPF);
        case 'YPF'
            append(rpt,Data.YPF);
        case 'PSS'
            append(rpt,Data.PSS);
        case 'FixtureImg'
            plot1 = Image(char('D:\Users\Timothy\Documents\MATLAB\Plant_Calculator\incandescent.png'));
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
    end
    moveToNextHole(rpt);
end

close(rpt);
rptview(rpt.OutputPath);