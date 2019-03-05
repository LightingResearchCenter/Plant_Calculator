function rpt = makerpt(Data,rptname,logFile)
import mlreportgen.dom.*
rpt = Document(rptname,'pdf','LRC_Hort_Metrics.pdftx');
fid = fopen(logFile, 'w');
if fid == -1
  error('Cannot open log file.');
end
dispatcher = MessageDispatcher.getTheDispatcher;
l = addlistener(dispatcher,'Message', ...
      @(src, evtdata) fprintf(fid, '%s: %s\n', datestr(now, 0), evtdata.Message.formatAsText));
open(rpt);
dispatch(dispatcher, ProgressMessage('Starting Report',rpt));
while ~strcmp(rpt.CurrentHoleId,'#end#')
    switch rpt.CurrentHoleId
        case 'MaxArr'
            append(rpt,max(Data.outTable.maxCount));
        case 'Brand'
            append(rpt,Data.Brand);
        case 'Product'
            append(rpt,Data.Product);
        case 'Catalog'
            append(rpt,regexprep(Data.Catalog,'\s+',' '));
        case 'Voltage'
            append(rpt,sprintf('%0.0f',round(Data.Volts)));
        case 'PPF'
            append(rpt,sprintf('%0.0f',Data.PPF));
        case 'PSS'
            append(rpt,sprintf('%0.2f',Data.PSS));
        case 'FixtureImg'
            img = Image(Data.Image);
            img.Style = {Height('0.85in')};
            append(rpt,img);
        case 'Power'
            append(rpt,sprintf('%d',round(Data.Wattage)));
        case 'PPFperW'
            append(rpt,sprintf('%0.1f',Data.PPFperW));
        case 'PF'
            append(rpt,sprintf('%0.2f',Data.PF));
        case 'PPFper'
            append(rpt,sprintf('%0.1f',Data.PPFofTotal));
        case 'THD'
            append(rpt,sprintf('%0.1f',Data.THD));
        case 'PPFRank'
            img = Image(Data.PPFRank);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'PPFDRank'
            img = Image(Data.PPFperWRank);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'Lamp2'
            append(rpt,sprintf('This %s',Data.Source));
        case 'MountHeight'
            append(rpt,sprintf('%0.0f',round(Data.mount)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.1f',Data.mount*unitsratio('m','ft')));
        case 'ISOPPFDpic'
            img = Image(Data.ISOPlot);
            img.Style = {Height('2.1in')};
            append(rpt,img);
        case 'IntenDistImg'
            img = Image(Data.IntensityDistplot);
            img.Style = {Height('2in')};
            append(rpt,img);
        case 'SPDpic'
            img = Image(Data.SPDPlot);
            img.Style = {Width('3.25in')};
            append(rpt,img);
        case 'SPDThetaPlot'
            if exist(Data.SPDthetaPlot,'file')
                img = Image(Data.SPDthetaPlot);
                img.Style = {Height('1.75in')};
                append(rpt,img);
            else
                append(rpt,'Not Available with the Data Provided');
            end
        case 'Costpic1'
            if exist(Data.LCCA10Plot,'file')
                img = Image(Data.LCCA10Plot);
                img.Style = {Height('95pt')};
                append(rpt,img);
            else
                append(rpt,'Not Available with the Data Provided');
            end
        case 'Costpic2'
            if exist(Data.LCCA20Plot,'file')
                img = Image(Data.LCCA20Plot);
                img.Style = {Height('95pt')};
                append(rpt,img);
            else
                append(rpt,'Not Available with the Data Provided');
            end
        case 'CostLgnd'
            if exist(Data.LCCALgnd,'file')
                img = Image(Data.LCCALgnd);
                img.Style = {Height('.25in')};
                append(rpt,img);
            else
                append(rpt,'Not Available with the Data Provided');
            end
        case '#start#'
            sect = rpt.CurrentPageLayout;
            for i = 1:numel(sect.PageFooters)
                pageFooter = sect.PageFooters(i);
                while ~strcmp(pageFooter.CurrentHoleId,'#end#')
                    switch pageFooter.CurrentHoleId
                        case 'GenTime'
                            date = datestr(now,'yyyy-mm-dd');
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
                            date = datestr(now,'yyyy-mm-dd');
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
            append(rpt,sprintf('%d',round(Data.Eco.HPS1000.Cost)));%1000W HPS Cost
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(Data.Eco.HPS600.Cost)));%600W HPS Cost
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(Data.Eco.fix.Cost)));%Current Lamp Cost
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.Init,',##0')));%1000W HPS Init
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.Init,',##0')));%600W HPS Init
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.Init,',##0')));%Current Lamp Init
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.InitFt,',##0')));%1000W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.InitM,',##0')));%1000W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.InitFt,',##0')));%600W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.InitM,',##0')));%600W HPS Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.InitFt,',##0')));%Current Lamp Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.InitM,',##0')));%Current Lamp Init Area
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.WFt,',##0')));%1000W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.WM,',##0')));%1000W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.WFt,',##0')));%600W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.WM,',##0')));%600W HPS Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.WFt,',##0')));%Current Lamp Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.WM,',##0')));%Current Lamp Power Density
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.kWftYr,',##0')));%1000W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.kWmYr,',##0')));%1000W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.kWftYr,',##0')));%600W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.kWmYr,',##0')));%600W HPS Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.kWftYr,',##0')));%Current Lamp Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.kWmYr,',##0')));%Current Lamp Yr Energy
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.CostFtLow,',##0.00')));%1000W HPS Energy Cost Low per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.CostmLow,',##0.00')));%1000W HPS Energy Cost Low per m
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.CostFtLow,',##0.00')));%600W HPS Energy Cost Low per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.CostmLow,',##0.00')));%600W HPS Energy Cost Low per m 
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.CostFtLow,',##0.00')));%Current Lamp Energy Cost Low per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.CostmLow,',##0.00')));%Current Lamp Energy Cost Low per m
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.CostFtHigh,',##0.00')));%1000W HPS Energy Cost High per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS1000.CostmHigh,',##0.00')));%1000W HPS Energy Cost High per m
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.CostFtLow,',##0.00')));%600W HPS Energy Cost High per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.HPS600.CostmLow,',##0.00')));%600W HPS Energy Cost High per m
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.CostFtHigh,',##0.00')));%Current Lamp Energy Cost High per ft
            moveToNextHole(rpt);
            append(rpt,sprintf('(%s)',numberFormatter(Data.Eco.fix.CostmHigh,',##0.00')));%Current Lamp Energy Cost High per m
            moveToNextHole(rpt);
            diff = Data.Eco.HPS1000.TotPayLow(2:end,1)-Data.Eco.fix.TotPayLow(2:end,1);
            payYear1000Low = find(diff>0,1);
            if ~isempty(payYear1000Low)&&(diff(end)>0)
                append(rpt,sprintf('%s%% - Payback at year %d.',numberFormatter(Data.Eco.HPS1000.RORLow(1)*100,',##0.0'),payYear1000Low));%1000W HPS ROR Low
            else
                if Data.Eco.HPS1000.RORLow(1)<=0
                    append(rpt,sprintf('<%s%% - No Payback within 20 years.',numberFormatter(0,',##0.0')));
                else
                    append(rpt,sprintf('%s%% - No Payback within 20 years.',numberFormatter(Data.Eco.HPS1000.RORLow(1)*100,',##0.0')));%1000W HPS ROR Low
                end
            end
            moveToNextHole(rpt);
            diff = Data.Eco.HPS1000.TotPayHigh(2:end,1)-Data.Eco.fix.TotPayHigh(2:end,1);
            payYear1000High = find(diff>0,1);
            if ~isempty(payYear1000High)&&(diff(end)>0)
                append(rpt,sprintf('%s%% - Payback at year %d.',numberFormatter(Data.Eco.HPS1000.RORHigh(1)*100,',##0.0'),payYear1000High));
            else
                if Data.Eco.HPS1000.RORHigh(1)<=0
                    append(rpt,sprintf('<%s%% - No Payback within 20 years.',numberFormatter(0,',##0.0')));
                else
                    append(rpt,sprintf('%s%% - No Payback within 20 years.',numberFormatter(Data.Eco.HPS1000.RORHigh(1)*100,',##0.0')));%1000W HPS ROR High
                end
            end
            moveToNextHole(rpt);
            diff = Data.Eco.HPS600.TotPayLow(2:end,1)-Data.Eco.fix.TotPayLow(2:end,1);
            payYear600Low = find(diff>0,1);
            if ~isempty(payYear600Low)&&(diff(end)>0)
                append(rpt,sprintf('%s%% - Payback at year %d.',numberFormatter(Data.Eco.HPS600.RORLow(1)*100,',##0.0'),payYear600Low));
            else
                if Data.Eco.HPS600.RORLow(1)<=0
                    append(rpt,sprintf('<%s%% - No Payback within 20 years.',numberFormatter(0,',##0.0')));
                else
                    append(rpt,sprintf('%s%% - No Payback within 20 years.',numberFormatter(Data.Eco.HPS600.RORLow(1)*100,',##0.0')));%600W HPS ROR Low
                end
            end
            moveToNextHole(rpt);
            diff = Data.Eco.HPS600.TotPayHigh(2:end,1)-Data.Eco.fix.TotPayHigh(2:end,1);
            payYear600High = find(diff>0,1);
            if ~isempty(payYear600High)&&(diff(end)>0)
                append(rpt,sprintf('%s%% - Payback at year %d.',numberFormatter(Data.Eco.HPS600.RORHigh(1)*100,',##0.0'),payYear600High));
            else
                if Data.Eco.HPS600.RORHigh(1)<=0
                    append(rpt,sprintf('<%s%% - No Payback within 20 years.',numberFormatter(0,',##0.0')));
                else
                    append(rpt,sprintf('%s%% - No Payback within 20 years.',numberFormatter(Data.Eco.HPS600.RORHigh(1)*100,',##0.0')));%600W HPS ROR High
                end
            end
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.TotPayLow(end,1),',##0')));%1000W HPS Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.TotPayLow(end,1),',##0')));%600W HPS Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.TotPayLow(end,1),',##0')));%Current Lamp Present Worth Low
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS1000.TotPayHigh(end,1),',##0')));%1000W HPS Present Worth High
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.HPS600.TotPayHigh(end,1),',##0')));%600W HPS Present Worth High
            moveToNextHole(rpt);
            append(rpt,sprintf('%s',numberFormatter(Data.Eco.fix.TotPayHigh(end,1),',##0')));%Current Lamp Present Worth High
        case 'LSAE101'
            clear('LSAEmax');
            printstr = @(x,y) sprintf('%0.2f%s',x,y);
            lsaeIndex = 1;
            maxVal = max(Data.outTable.LSAE);
            LSAEmax(1) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==75));
            LSAEmax(2) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==150));
            LSAEmax(3) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==225));
            LSAEmax(4) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==300));
            LSAEmax(5) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==500));
            LSAEmax(6) = max(Data.outTable.LSAE(Data.outTable.targetPPFD==1000));
            if any(LSAEmax == 0)
                LSAEmax(LSAEmax == 0)=[];
            end
            outstr = [];
            if Data.outTable.LSAE(lsaeIndex) == maxVal
                if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                    outstr = [outstr,'*'];
                end
                if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)*0.9
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxAllRed');
                else
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxAll');
                end
            elseif any(Data.outTable.LSAE(lsaeIndex) == LSAEmax)
                if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                    outstr = [outstr,'*'];
                end
                if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)*0.9
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxRed');
                else
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'max');
                end
            else
                if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                    outstr = [outstr,'*'];
                end
                 if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)*0.9
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'Red');
                else
                    append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr));
                end
            end
            outstr=[];
            moveToNextHole(rpt);
            append(rpt,sprintf('%d',round(size(Data.outTable.count{lsaeIndex},1))));
            lsaeIndex =lsaeIndex +1;
            while lsaeIndex<49
                moveToNextHole(rpt);
                if Data.outTable.LSAE(lsaeIndex) == maxVal
                    if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                        outstr = [outstr,'* '];
                    end
                    if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)*0.9
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxAllRed');
                    else
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxAll');
                    end
                elseif any(Data.outTable.LSAE(lsaeIndex) == LSAEmax)
                    if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                        outstr = [outstr,'* '];
                    end
                    if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'maxRed');
                    else
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'max');
                    end
                else
                    if Data.outTable.MinToAvg(lsaeIndex) <= Data.outTable.targetUniform(lsaeIndex)
                        outstr = [outstr,'* '];
                    end
                    if Data.outTable.Avg(lsaeIndex) <= Data.outTable.targetPPFD(lsaeIndex)
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr),'Red');
                    else
                        append(rpt,printstr(Data.outTable.LSAE(lsaeIndex),outstr));
                    end
                end
                outstr=[];
                moveToNextHole(rpt);
                append(rpt,sprintf('%d',round(size(Data.outTable.count{lsaeIndex},1))));
                lsaeIndex =lsaeIndex +1; 
            end
        case 'TargetPPFD'
            clear('LSAEmax');
            PPFD300 = Data.outTable((Data.outTable.targetPPFD == 300),:);
            [~,ind] = max(PPFD300.LSAE);
            if PPFD300.Avg(ind) <= PPFD300.targetPPFD(ind)*0.9
                PPFD300 = Data.outTable((Data.outTable.targetPPFD <= 300),:);
                [~,ind] = max(PPFD300.LSAE);
            else
                ind = 3;
            end
            append(rpt,sprintf('%d',PPFD300.targetPPFD(ind)));
        case 'ratio11'
            ratioIndex = 1;
            append(rpt,sprintf('%0.2f%%',Data.UVaPer(ratioIndex)*100));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f%%',Data.bluePer(ratioIndex)*100));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f%%',Data.redPer(ratioIndex)*100));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f%%',Data.FRPer(ratioIndex)*100));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.blueRed(ratioIndex)));
            moveToNextHole(rpt);
            append(rpt,sprintf('%0.2f',Data.redFR(ratioIndex)));
            ratioIndex =ratioIndex +1;
            while ratioIndex<=6
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f%%',Data.UVaPer(ratioIndex)*100));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f%%',Data.bluePer(ratioIndex)*100));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f%%',Data.redPer(ratioIndex)*100));
                moveToNextHole(rpt);
                append(rpt,sprintf('%0.2f%%',Data.FRPer(ratioIndex)*100));
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
% rptview(rpt.OutputPath);
delete (l);
fclose(fid);
end