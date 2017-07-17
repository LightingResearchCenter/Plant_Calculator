function rpt = makerpt(Data,rptname,rpttemplate)
import mlreportgen.dom.*
rpt = Document(rptname,'pdf',rpttemplate);
rpt.CurrentHoleId
while ~strcmp(rpt.CurrentHoleId,'#end#')
    
    switch rpt.CurrentHoleId
        case 'RPIlogo'
            imgObj = Image('images\rpiLogo.png');
            imgObj.Style = {Height('0.4in')};
            append(rpt,imgObj);
        case 'GenTime'
            
        case 'NRCanLogo'
            imgObj = Image('images\NRCan-logo1024x512.png');
            imgObj.Style = {Height('0.4in')};
            append(rpt,imgObj);
        case 'LRCLogo'
            imgObj = Image('images\lrcLogo.png');
            imgObj.Style = {Height('0.4in')};
            append(rpt,imgObj);
        case 'LEAlogo'
            imgObj = Image('images\LightingEnergyAlliance_Logo0_27_133.png');
            imgObj.Style = {Height('0.4in')};
            append(rpt,imgObj);
    end
    moveToNextHole(rpt);
    rpt.CurrentHoleId
end

close(rpt);
rptview(rpt.OutputPath);