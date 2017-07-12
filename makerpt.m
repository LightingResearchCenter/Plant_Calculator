function makerpt(Data,rptname,rpttemplate)
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
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
            plot1 = Image(char("\\root\projects\IPH_PlantPathology\GrowLightPhotosLEA\110102_sq.jpg"));
            plot1.Height = '.9in';
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