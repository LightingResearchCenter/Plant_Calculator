function [Data] = calculateEconomics(Data,roomLength,roomWidth,varargin)

load('PlantCalculatorHPSfixtures.mat');
%% init variables
opperatingHrs =3000; %From talks with growers
installRate = 69; %$ per fixture from:RSMeans Data 2017
Eco.enCostLow = 0.1048;%$ per kW
Eco.enCostHigh = 0.20; %$ per kW
PPFD300 = Data.outTable((Data.outTable.targetPPFD == 300),:);
[~,ind] = max(PPFD300.LSAE);
ftArea = roomLength*roomWidth;
mArea = (roomLength*unitsratio('m','ft'))*(roomWidth*unitsratio('m','ft'));
%% initial costs
Eco.HPS1000.Qty = size(HPS1000Table.count{1},1); %2m @300ppfd target
Eco.HPS600.Qty = size(HPS600Table.count{1},1); %2m @300ppfd target
Eco.fix.Qty = size(PPFD300.count{ind},1);

Eco.HPS1000.Watt = 1057.3;
Eco.HPS600.Watt = HPS600IES.InputWatts;
Eco.fix.Watt = Data.IESdata.InputWatts;

Eco.HPS1000.Cost = 525;
Eco.HPS600.Cost = 460;
Eco.fix.Cost = Data.Price;

Eco.HPS1000.Init = Eco.HPS1000.Qty *(Eco.HPS1000.Cost+installRate);
Eco.HPS600.Init = Eco.HPS600.Qty *(Eco.HPS600.Cost+installRate);
Eco.fix.Init = Eco.fix.Qty*(Eco.fix.Cost+installRate);

Eco.HPS1000.InitFt = Eco.HPS1000.Init/ftArea;
Eco.HPS600.InitFt = Eco.HPS600.Init/ftArea;
Eco.fix.InitFt = Eco.fix.Init/ftArea;

Eco.HPS1000.InitM = Eco.HPS1000.Init/mArea;
Eco.HPS600.InitM = Eco.HPS600.Init/mArea;
Eco.fix.InitM = Eco.fix.Init/mArea;

%% Annual costs
Eco.HPS1000.WFt = (Eco.HPS1000.Watt*Eco.HPS1000.Qty)/ftArea;
Eco.HPS600.WFt = (Eco.HPS600.Watt*Eco.HPS600.Qty)/ftArea;
Eco.fix.WFt = (Eco.fix.Watt*Eco.fix.Qty)/ftArea;

Eco.HPS1000.WM = (Eco.HPS1000.Watt*Eco.HPS1000.Qty)/mArea;
Eco.HPS600.WM = (Eco.HPS600.Watt*Eco.HPS600.Qty)/mArea;
Eco.fix.WM = (Eco.fix.Watt*Eco.fix.Qty)/mArea;

Eco.HPS1000.kWYr = (Eco.HPS1000.Watt/1000)*opperatingHrs*Eco.HPS1000.Qty;
Eco.HPS600.kWYr = (Eco.HPS600.Watt/1000)*opperatingHrs*Eco.HPS600.Qty;
Eco.fix.kWYr = (Eco.fix.Watt/1000)*opperatingHrs*Eco.fix.Qty;

Eco.HPS1000.kWftYr = (Eco.HPS1000.kWYr)/ftArea;
Eco.HPS600.kWftYr = (Eco.HPS600.kWYr)/ftArea;
Eco.fix.kWftYr = (Eco.fix.kWYr)/ftArea;

Eco.HPS1000.kWmYr = (Eco.HPS1000.kWYr)/mArea;
Eco.HPS600.kWmYr = (Eco.HPS600.kWYr) /mArea;
Eco.fix.kWmYr = (Eco.fix.kWYr)/mArea;

Eco.HPS1000.CostLow = (Eco.HPS1000.kWYr*Eco.enCostLow);
Eco.HPS600.CostLow = (Eco.HPS600.kWYr*Eco.enCostLow);
Eco.fix.CostLow = (Eco.fix.kWYr*Eco.enCostLow);

Eco.HPS1000.CostHigh = (Eco.HPS1000.kWYr*Eco.enCostHigh);
Eco.HPS600.CostHigh = (Eco.HPS600.kWYr*Eco.enCostHigh);
Eco.fix.CostHigh = (Eco.fix.kWYr*Eco.enCostHigh);

Eco.HPS1000.CostFtLow= Eco.HPS1000.CostLow/ftArea;
Eco.HPS600.CostFtLow = Eco.HPS600.CostLow/ftArea;
Eco.fix.CostFtLow = Eco.fix.CostLow/ftArea;

Eco.HPS1000.CostFtHigh= Eco.HPS1000.CostHigh/ftArea;
Eco.HPS600.CostFtHigh = Eco.HPS600.CostHigh/ftArea;
Eco.fix.CostFtHigh = Eco.fix.CostHigh/ftArea;

Eco.HPS1000.CostmLow= Eco.HPS1000.CostLow/mArea;
Eco.HPS600.CostmLow = Eco.HPS600.CostLow/mArea;
Eco.fix.CostmLow = Eco.fix.CostLow/mArea;

Eco.HPS1000.CostmHigh= Eco.HPS1000.CostHigh/mArea;
Eco.HPS600.CostmHigh = Eco.HPS600.CostHigh/mArea;
Eco.fix.CostmHigh = Eco.fix.CostHigh/mArea;

%% 20Yr Cost Calculation
LEDfailerRate = [0.01, 0.25];
mainRate = 16;%$ perLamp per hourfrom:RSMeans Data 2017
cleaningRate = 60; %$ per fixture per hour from:RSMeans Data 2017
HPScleanTime = .5;%hrs
HPSreLampTime = 1; %hrs
LEDcleantime = .1;

pv = round(pvvar(eye(21), 0.03),3)'; %present Value
HPS1000Life = 10000;
HPS600Life = 10000;
HPS1000ReflectorLife = 10000;
HPS600ReflectorLife = 10000;

HPS1000LampCost = 120;
HPS600LampCost = 32;
HPS1000Reflector = 40;
HPS600Reflector = 40;
HPSfailerRate = 0.02;
if strcmpi(Data.Source, 'LED')
    for i = 1:length(LEDfailerRate)
        HPS1000Relampint = 1+floor(HPS1000Life/opperatingHrs):floor(HPS1000Life/opperatingHrs):21;
        HPS600Relampint = 1+floor(HPS600Life/opperatingHrs):floor(HPS600Life/opperatingHrs):21;
        
        HPS1000Reflectorint = 1+floor(HPS1000ReflectorLife/opperatingHrs):floor(HPS1000ReflectorLife/opperatingHrs):21;
        HPS600Reflectorint = 1+floor(HPS600ReflectorLife/opperatingHrs):floor(HPS600ReflectorLife/opperatingHrs):21;
        
        HPS1000Relampint = setdiff(HPS1000Relampint,HPS1000Reflectorint);
        HPS600Relampint = setdiff(HPS600Relampint,HPS600Reflectorint);
        
        HPS1000ReLampYr = (((mainRate+HPS1000LampCost)*Eco.HPS1000.Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.HPS1000.Qty))*ones(21,1);
        HPS1000ReLampYr(1) = Eco.HPS1000.Init;
        if ~isempty(HPS1000Relampint)
            HPS1000ReLampYr(HPS1000Relampint) = HPS1000ReLampYr(HPS1000Relampint)+...   % on years where a lamp life cycle ends
                ((mainRate+HPS1000LampCost)*ceil(Eco.HPS1000.Qty*HPSfailerRate))+...% spot Relamping from the cycle
                ((HPS1000LampCost+(cleaningRate*HPSreLampTime))*Eco.HPS1000.Qty);   % Group Relampng @ end of cycle
        end
        HPS1000ReLampYr(HPS1000Reflectorint) = HPS1000ReLampYr(HPS1000Reflectorint)+...   % on years where a lamp life cycle ends
            ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
            ((HPS600LampCost+HPS1000Reflector+(cleaningRate*HPScleanTime))*Eco.HPS600.Qty);   % Group Relampng and Reflector @ end of cycle
        
        HPS600ReLampYr = (((mainRate+HPS600LampCost)*Eco.HPS600.Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.HPS600.Qty))*ones(21,1);
        HPS600ReLampYr(1) = Eco.HPS600.Init;
        if ~isempty(HPS600Relampint)
            HPS600ReLampYr(HPS600Relampint) = HPS600ReLampYr(HPS600Relampint)+...   % on years where a lamp life cycle ends
                ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
                ((HPS600LampCost+(cleaningRate*HPSreLampTime))*Eco.HPS600.Qty);   % Group Relampng @ end of cycle
        end
        HPS600ReLampYr(HPS600Reflectorint) = HPS600ReLampYr(HPS600Reflectorint)+...   % on years where a lamp life cycle ends
            ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
            ((HPS600LampCost+HPS600Reflector+(cleaningRate*HPScleanTime))*Eco.HPS600.Qty);   % Group Relampng and Reflector @ end of cycle
        
        fixReLampYr = cleaningRate*LEDcleantime*Eco.fix.Qty*ones(21,1);
        fixReLampYr(1) = Eco.fix.Init;
        fixReLampYr(11) = fixReLampYr(11)+(Eco.fix.Qty*Eco.fix.Cost*LEDfailerRate(i));
        
        HPS1000CostYrLow = HPS1000ReLampYr+(Eco.HPS1000.kWYr*Eco.enCostLow);
        HPS1000CostYrLow(1) = Eco.HPS1000.Init;
        HPS600CostYrLow = HPS600ReLampYr+(Eco.HPS600.kWYr*Eco.enCostLow);
        HPS600CostYrLow(1) = Eco.HPS600.Init;
        fixCostYrLow = fixReLampYr+(Eco.fix.kWYr*Eco.enCostLow);
        fixCostYrLow(1) = Eco.fix.Init;
        
        HPS1000CostYrHigh = HPS1000ReLampYr+(Eco.HPS1000.kWYr*Eco.enCostHigh);
        HPS1000CostYrHigh(1) = Eco.HPS1000.Init;
        HPS600CostYrHigh= HPS600ReLampYr+(Eco.HPS600.kWYr*Eco.enCostHigh);
        HPS600CostYrHigh(1) = Eco.HPS600.Init;
        fixCostYrHigh = fixReLampYr+(Eco.fix.kWYr*Eco.enCostHigh);
        fixCostYrHigh(1) = Eco.fix.Init;
        
        Eco.HPS1000.TotPayLow(:,i) = cumsum(HPS1000CostYrLow.*pv);
        Eco.HPS600.TotPayLow(:,i) = cumsum(HPS600CostYrLow.*pv);
        Eco.fix.TotPayLow(:,i) = cumsum(fixCostYrLow.*pv);
        
        Eco.HPS1000.TotPayHigh(:,i) = cumsum(HPS1000CostYrHigh.*pv);
        Eco.HPS600.TotPayHigh(:,i) = cumsum(HPS600CostYrHigh.*pv);
        Eco.fix.TotPayHigh(:,i) = cumsum(fixCostYrHigh.*pv);
        
        Eco.HPS1000.CFLow(:,i) = HPS1000CostYrLow - fixCostYrLow;
        Eco.HPS1000.CFLow(1,1) = -fixCostYrLow(1);
        Eco.HPS1000.CFHigh(:,i) = HPS1000CostYrHigh - fixCostYrHigh;
        Eco.HPS1000.CFHigh(1,i) = -fixCostYrHigh(1);
        
        Eco.HPS600.CFLow(:,i) = HPS600CostYrLow - fixCostYrLow;
        Eco.HPS600.CFLow(1,i) = -fixCostYrLow(1);
        Eco.HPS600.CFHigh(:,i) = HPS600CostYrHigh - fixCostYrHigh;
        Eco.HPS600.CFHigh(1,i) = -fixCostYrHigh(1);
    end
else
    i = 1;
    
    HPS1000Relampint = 1+floor(HPS1000Life/opperatingHrs):floor(HPS1000Life/opperatingHrs):21;
    HPS600Relampint = 1+floor(HPS600Life/opperatingHrs):floor(HPS600Life/opperatingHrs):21;
    fixRelampint = 1+floor(Data.LampLife/opperatingHrs):floor(Data.LampLife/opperatingHrs):21;
    
    HPS1000Reflectorint = 1+floor(HPS1000ReflectorLife/opperatingHrs):floor(HPS1000ReflectorLife/opperatingHrs):21;
    HPS600Reflectorint = 1+floor(HPS600ReflectorLife/opperatingHrs):floor(HPS600ReflectorLife/opperatingHrs):21;
    fixReflectorint = 1+floor(Data.ReflectorLife/opperatingHrs):floor(Data.ReflectorLife/opperatingHrs):21;
    
    HPS1000Relampint = setdiff(HPS1000Relampint,HPS1000Reflectorint);
    HPS600Relampint = setdiff(HPS600Relampint,HPS600Reflectorint);
    fixRelampint = setdiff(fixRelampint,fixReflectorint);
    
    HPS1000ReLampYr = ((cleaningRate*HPScleanTime)*Eco.HPS1000.Qty)*ones(21,1);
    HPS1000ReLampYr(1) = Eco.HPS1000.Init;
    if ~isempty(HPS1000Relampint)
        HPS1000ReLampYr(HPS1000Relampint) = HPS1000ReLampYr(HPS1000Relampint)+...   % on years where a lamp life cycle ends
            ((mainRate+HPS1000LampCost)*ceil(Eco.HPS1000.Qty*HPSfailerRate))+...% spot Relamping from the cycle
            ((HPS1000LampCost+(cleaningRate*HPSreLampTime))*Eco.HPS1000.Qty);   % Group Relampng @ end of cycle
    end
    HPS1000ReLampYr(HPS1000Reflectorint) = HPS1000ReLampYr(HPS1000Reflectorint)+...   % on years where a lamp life cycle ends
        ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
        ((HPS600LampCost+HPS1000Reflector+(cleaningRate*HPScleanTime))*Eco.HPS600.Qty);   % Group Relampng and Reflector @ end of cycle
    
    HPS600ReLampYr = (((mainRate+HPS600LampCost)*Eco.HPS600.Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.HPS600.Qty))*ones(21,1);
    HPS600ReLampYr(1) = Eco.HPS600.Init;
    if ~isempty(HPS600Relampint)
        HPS600ReLampYr(HPS600Relampint) = HPS600ReLampYr(HPS600Relampint)+...   % on years where a lamp life cycle ends
            ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
            ((HPS600LampCost+(cleaningRate*HPSreLampTime))*Eco.HPS600.Qty);   % Group Relampng @ end of cycle
    end
    HPS600ReLampYr(HPS600Reflectorint) = HPS600ReLampYr(HPS600Reflectorint)+...   % on years where a lamp life cycle ends
        ((mainRate+HPS600LampCost)*ceil(Eco.HPS600.Qty*HPSfailerRate))+...% spot Relamping from the cycle
        ((HPS600LampCost+HPS600Reflector+(cleaningRate*HPScleanTime))*Eco.HPS600.Qty);   % Group Relampng and Reflector @ end of cycle
    
    fixReLampYr = (((mainRate+Data.LampCost)*Eco.fix.Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.fix.Qty))*ones(21,1);
    fixReLampYr(1) = Eco.fix.Init;
    if ~isempty(fixRelampint)
        fixReLampYr(fixRelampint) = fixReLampYr(fixRelampint)+...   % on years where a lamp life cycle ends
            ((mainRate+Data.LampCost)*ceil(Eco.fix.Qty*HPSfailerRate))+...% spot Relamping from the cycle
            ((Data.LampCost+(cleaningRate*HPSreLampTime))*Eco.fix.Qty);   % Group Relampng @ end of cycle
    end
    fixReLampYr(fixReflectorint) = fixReLampYr(fixReflectorint)+...   % on years where a lamp life cycle ends
        ((mainRate+Data.LampCost)*ceil(Eco.fix.Qty*HPSfailerRate))+...% spot Relamping from the cycle
        ((Data.LampCost+Data.ReflectorCost+(cleaningRate*HPScleanTime))*Eco.fix.Qty);   % Group Relampng and Reflector @ end of cycle
    
    HPS1000CostYrLow = HPS1000ReLampYr+(Eco.HPS1000.kWYr*Eco.enCostLow);
    HPS1000CostYrLow(1) = Eco.HPS1000.Init;
    HPS600CostYrLow = HPS600ReLampYr+(Eco.HPS600.kWYr*Eco.enCostLow);
    HPS600CostYrLow(1) = Eco.HPS600.Init;
    fixCostYrLow = fixReLampYr+(Eco.fix.kWYr*Eco.enCostLow);
    fixCostYrLow(1) = Eco.fix.Init;
    
    HPS1000CostYrHigh = HPS1000ReLampYr+(Eco.HPS1000.kWYr*Eco.enCostHigh);
    HPS1000CostYrHigh(1) = Eco.HPS1000.Init;
    HPS600CostYrHigh= HPS600ReLampYr+(Eco.HPS600.kWYr*Eco.enCostHigh);
    HPS600CostYrHigh(1) = Eco.HPS600.Init;
    fixCostYrHigh = fixReLampYr+(Eco.fix.kWYr*Eco.enCostHigh);
    fixCostYrHigh(1) = Eco.fix.Init;
    
    Eco.HPS1000.TotPayLow(:,i) = cumsum(HPS1000CostYrLow.*pv);
    Eco.HPS600.TotPayLow(:,i) = cumsum(HPS600CostYrLow.*pv);
    Eco.fix.TotPayLow(:,i) = cumsum(fixCostYrLow.*pv);
    
    Eco.HPS1000.TotPayHigh(:,i) = cumsum(HPS1000CostYrHigh.*pv);
    Eco.HPS600.TotPayHigh(:,i) = cumsum(HPS600CostYrHigh.*pv);
    Eco.fix.TotPayHigh(:,i) = cumsum(fixCostYrHigh.*pv);
    
    Eco.HPS1000.CFLow(:,i) = HPS1000CostYrLow - fixCostYrLow;
    Eco.HPS1000.CFLow(1,1) = -fixCostYrLow(1);
    Eco.HPS1000.CFHigh(:,i) = HPS1000CostYrHigh - fixCostYrHigh;
    Eco.HPS1000.CFHigh(1,i) = -fixCostYrHigh(1);
    
    Eco.HPS600.CFLow(:,i) = HPS600CostYrLow - fixCostYrLow;
    Eco.HPS600.CFLow(1,i) = -fixCostYrLow(1);
    Eco.HPS600.CFHigh(:,i) = HPS600CostYrHigh - fixCostYrHigh;
    Eco.HPS600.CFHigh(1,i) = -fixCostYrHigh(1);
end
Eco.HPS1000.CumCFLow = cumsum(Eco.HPS1000.CFLow);
Eco.HPS1000.CumCFHigh = cumsum(Eco.HPS1000.CFHigh);

Eco.HPS600.CumCFLow = cumsum(Eco.HPS600.CFLow);
Eco.HPS600.CumCFHigh = cumsum(Eco.HPS600.CFHigh);

Eco.HPS1000.RORLow = mean(Eco.HPS1000.CFLow(2:end,:),1)/Eco.fix.Init;
Eco.HPS1000.RORHigh = mean(Eco.HPS1000.CFHigh(2:end,:),1)/Eco.fix.Init;

Eco.HPS600.RORLow = mean(Eco.HPS600.CFLow(2:end,:),1)/Eco.fix.Init;
Eco.HPS600.RORHigh = mean(Eco.HPS600.CFHigh(2:end,:),1)/Eco.fix.Init;
%% add to data for output
Data.Eco = Eco;
hLow = figure('units','in');
set(hLow,'Renderer','painters');
aLow = axes(hLow);
hold on
if strcmpi(Data.Source, 'LED')
    plot(aLow,0:20,Eco.fix.TotPayLow(:,1),'LineWidth',2,'Color',[166,206,227]/255);
    plot(aLow,0:20,Eco.fix.TotPayLow(:,2),'LineStyle','--','LineWidth',2,'Color',[31,120,180]/255);
    plot(aLow,0:20,Eco.HPS600.TotPayLow(:,1),'LineStyle','-','LineWidth',1,'Color',[51,160,44]/255);
    plot(aLow,0:20,Eco.HPS1000.TotPayLow(:,1),'LineStyle','-','LineWidth',1,'Color',[227,26,28]/255);
else
    plot(aLow,0:20,Eco.fix.TotPayLow(:,1),'LineWidth',2,'Color',[255,255,255]/255);
    plot(aLow,0:20,Eco.fix.TotPayLow(:,1),'LineWidth',2,'Color',[31,120,180]/255);
    plot(aLow,0:20,Eco.HPS600.TotPayLow(:,1),'LineStyle','-','LineWidth',1,'Color',[51,160,44]/255);
    plot(aLow,0:20,Eco.HPS1000.TotPayLow(:,1),'LineStyle','-','LineWidth',1,'Color',[227,26,28]/255);
end

hold off

hHigh = figure('units','inches');
aHigh = axes(hHigh);
set(hHigh,'Renderer','painters');
hold on
if strcmpi(Data.Source, 'LED')
    plot(aHigh,0:20,Eco.fix.TotPayHigh(:,1),'LineWidth',2,'Color',[166,206,227]/255);
    plot(aHigh,0:20,Eco.fix.TotPayHigh(:,2),'LineStyle','--','LineWidth',2,'Color',[31,120,180]/255);
    plot(aHigh,0:20,Eco.HPS600.TotPayHigh(:,1),'LineStyle','-','LineWidth',1,'Color',[51,160,44]/255);
    plot(aHigh,0:20,Eco.HPS1000.TotPayHigh(:,1),'LineStyle','-','LineWidth',1,'Color',[227,26,28]/255);
else
    plot(aHigh,0:20,Eco.fix.TotPayHigh(:,1),'LineWidth',2,'Color',[255,255,255]/255);
    plot(aHigh,0:20,Eco.fix.TotPayHigh(:,1),'LineWidth',2,'Color',[31,120,180]/255);
    plot(aHigh,0:20,Eco.HPS600.TotPayHigh(:,1),'LineStyle','-','LineWidth',1,'Color',[51,160,44]/255);
    plot(aHigh,0:20,Eco.HPS1000.TotPayHigh(:,1),'LineStyle','-','LineWidth',1,'Color',[227,26,28]/255);
end

hold off
set(aLow,'YLim',get(aHigh,'YLim'))

if strcmpi(Data.Source, 'LED')
    lgndLow = legend(aLow,'This LED(1% Failure at year 10)',' This LED(25% Failure at year 10)','600 W HPS','1000 W HPS','Location','best');
else
    lgndLow = legend(aLow,' ',sprintf('This %s Luminaire',Data.Source),'600 W HPS','1000 W HPS','Location','best');
end
set(lgndLow,'FontSize',6,'Visible','off');
xlabel(aLow,'Years','FontSize',7,'FontWeight','Bold')
ylabel(aLow,sprintf('Total Payments (US $)'),'FontSize',7,'FontWeight','Bold')
set(aLow,'xGrid','on','yGrid','on','xMinorGrid','on','Box','on')

if strcmpi(Data.Source, 'LED')
    lgndHigh = legend(aHigh,'Thi LED(1% Failure at year 10)','This LED(25% Failure at year 10)','600 W HPS','1000 W HPS','Location','best');
else
    lgndHigh = legend(aHigh,' ',sprintf('This %s Luminaire',Data.Source),'600 W HPS','1000 W HPS','Location','best');
end
set(lgndHigh,'FontSize',6,'Visible','off');

xlabel(aHigh,'Years','FontSize',7,'FontWeight','Bold')
ylabel(aHigh,sprintf('Total Payments (US $)'),'FontSize',7,'FontWeight','Bold')
set(aHigh,'xGrid','on','yGrid','on','xMinorGrid','on','Box','on')
if numel(varargin)==3
    lgndFig = figure;
    axe2 = axes(lgndFig);
    lgnd2 = legend(axe2,[aLow.Children(1:2)],'1000 {\itW} HPS','600 {\itW} HPS');
    axe2.Visible= 'off';
    lgnd2.Location = 'north';
    print(lgndFig,'-dpng', 'temp1.png','-r600');
    RemoveWhiteSpace([], 'file', 'temp1.png');
    if strcmpi(Data.Source, 'LED')
        lgnd2 = legend(axe2,[aLow.Children(3:4)],'This LED (25% Failure at year 10)','This LED (1% Failure at year 10)');
    else
        lgnd2 = legend(axe2,[aLow.Children(3:4)],sprintf('This %s Luminaire',Data.Source),' ');
    end
    axe2.Visible= 'off';
    lgnd2.Location = 'north';
    print(lgndFig,'-dpng','temp2.png','-r600');
    RemoveWhiteSpace([], 'file', 'temp2.png');
    legend1 = imread('temp1.png');
    legend2 = imread('temp2.png');
    imwrite([legend1(6:end-5,6:end-5,:),legend2(6:end-5,6:end-5,:)],varargin{3})
    close(lgndFig);
    pos = get(hLow,'InnerPosition');
    set(hLow,'InnerPosition',[pos(1),pos(2),3.5,1.5])
    set(aLow,'units', 'normalized','outerPosition',[0 0 1 1],'fontsize',7)
    Formatfunc = @(x) sprintf('$%d K',x/1000);
    set(aLow,'YTickLabel',arrayfun(Formatfunc, get(aLow,'YTick').', 'UniformOutput',0))
    print(hLow,'-dpng', varargin{1},'-r600');
    RemoveWhiteSpace([], 'file', varargin{1});
    close(hLow);
    pos = get(hHigh,'InnerPosition');
    set(hHigh,'InnerPosition',[pos(1),pos(2),3.5,1.5])
    set(aHigh,'units', 'normalized','outerPosition',[0 0 1 1],'fontsize',7)
    set(aHigh,'YTickLabel',arrayfun(Formatfunc, get(aHigh,'YTick').', 'UniformOutput',0))
    print(hHigh,'-dpng', varargin{2},'-r600');
    RemoveWhiteSpace([], 'file', varargin{2});
    close(hHigh);
    
else
    title(aHigh,sprintf('LCCA  with $0.20/kWh Energy Rate \n(Present Worth Comparisons)'))
    title(aLow,sprintf('LCCA  with $0.10/kWh Energy Rate \n(Present Worth Comparisons)'))
end
end
