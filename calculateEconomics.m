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
Eco.HPS1000Qty = size(HPS1000Table.count{1},1); %2m @300ppfd target
Eco.HPS600Qty = size(HPS600Table.count{1},1); %2m @300ppfd target
Eco.fixQty = size(PPFD300.count{ind},1);

Eco.HPS1000Watt = 1057.3;
Eco.HPS600Watt = HPS600IES.InputWatts;
Eco.fixWatt = Data.IESdata.InputWatts;

Eco.HPS1000Cost = 525;
Eco.HPS600Cost = 460;
Eco.fixCost = Data.Cost;

Eco.HPS1000Init = Eco.HPS1000Qty *(Eco.HPS1000Cost+installRate);
Eco.HPS600Init = Eco.HPS600Qty *(Eco.HPS600Cost+installRate);
Eco.fixInit = Eco.fixQty*(Eco.fixCost+installRate);

Eco.HPS1000InitFt = Eco.HPS1000Init/ftArea;
Eco.HPS600InitFt = Eco.HPS600Init/ftArea;
Eco.fixInitFt = Eco.fixInit/ftArea;

Eco.HPS1000InitM = Eco.HPS1000Init/mArea;
Eco.HPS600InitM = Eco.HPS600Init/mArea;
Eco.fixInitM = Eco.fixInit/mArea;

%% Annual costs
Eco.HPS1000WFt = (Eco.HPS1000Watt*Eco.HPS1000Qty)/ftArea;
Eco.HPS600WFt = (Eco.HPS600Watt*Eco.HPS600Qty)/ftArea;
Eco.fixWFt = (Eco.fixWatt*Eco.fixQty)/ftArea;

Eco.HPS1000WM = (Eco.HPS1000Watt*Eco.HPS1000Qty)/mArea;
Eco.HPS600WM = (Eco.HPS600Watt*Eco.HPS600Qty)/mArea;
Eco.fixWM = (Eco.fixWatt*Eco.fixQty)/mArea;

Eco.HPS1000kWYr = (Eco.HPS1000Watt/1000)*opperatingHrs*Eco.HPS1000Qty;
Eco.HPS600kWYr = (Eco.HPS600Watt/1000)*opperatingHrs*Eco.HPS600Qty;
Eco.fixkWYr = (Eco.fixWatt/1000)*opperatingHrs*Eco.fixQty;

Eco.HPS1000kWftYr = (Eco.HPS1000kWYr)/ftArea;
Eco.HPS600kWftYr = (Eco.HPS600kWYr)/ftArea;
Eco.fixkWftYr = (Eco.fixkWYr)/ftArea;

Eco.HPS1000kWmYr = (Eco.HPS1000kWYr)/mArea;
Eco.HPS600kWmYr = (Eco.HPS600kWYr) /mArea;
Eco.fixkWmYr = (Eco.fixkWYr)/mArea;

Eco.HPS1000CostLow = (Eco.HPS1000kWYr*Eco.enCostLow);
Eco.HPS600CostLow = (Eco.HPS600kWYr*Eco.enCostLow);
Eco.fixCostLow = (Eco.fixkWYr*Eco.enCostLow);

Eco.HPS1000CostHigh = (Eco.HPS1000kWYr*Eco.enCostHigh);
Eco.HPS600CostHigh = (Eco.HPS600kWYr*Eco.enCostHigh);
Eco.fixCostHigh = (Eco.fixkWYr*Eco.enCostHigh);

Eco.HPS1000CostFtLow= Eco.HPS1000CostLow/ftArea;
Eco.HPS600CostFtLow = Eco.HPS600CostLow/ftArea;
Eco.fixCostFtLow = Eco.fixCostLow/ftArea;

Eco.HPS1000CostFtHigh= Eco.HPS1000CostHigh/ftArea;
Eco.HPS600CostFtHigh = Eco.HPS600CostHigh/ftArea;
Eco.fixCostFtHigh = Eco.fixCostHigh/ftArea;

Eco.HPS1000CostmLow= Eco.HPS1000CostLow/mArea;
Eco.HPS600CostmLow = Eco.HPS600CostLow/mArea;
Eco.fixCostmLow = Eco.fixCostLow/mArea;

Eco.HPS1000CostmHigh= Eco.HPS1000CostHigh/mArea;
Eco.HPS600CostmHigh = Eco.HPS600CostHigh/mArea;
Eco.fixCostmHigh = Eco.fixCostHigh/mArea;

%% 20Yr Cost Calculation
LEDfailerRate = [0.01, 0.25];
for i = 1:length(LEDfailerRate)
    mainRate = 16;%$ perLamp per hourfrom:RSMeans Data 2017
    cleaningRate = 60; %$ per fixture per hour from:RSMeans Data 2017
    HPScleanTime = .5;%hrs
    HPSreLampTime = 1; %hrs
    LEDcleantime = .1;
    
    pv = round(pvvar(eye(21), 0.03),3)'; %present Value
    HPS1000Life = 10000;
    HPS600Life = 12000;
    
    HPS1000LampCost = 100;
    HPS600LampCost = 32;
    HPS1000Reflector = 40;
    HPS600Reflector = 40;
    HPSfailerRate = 0.02;
    
    
    HPS1000Relampint = 1+floor(HPS1000Life/opperatingHrs):floor(HPS1000Life/opperatingHrs):21;
    HPS600Relampint = 1+floor(HPS600Life/opperatingHrs):floor(HPS600Life/opperatingHrs):21;
    HPS1000ReLampYr = (((mainRate+HPS1000LampCost)*Eco.HPS1000Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.HPS1000Qty))*ones(21,1);
    HPS1000ReLampYr(1) = Eco.HPS1000Init;
    HPS1000ReLampYr(HPS1000Relampint) = HPS1000ReLampYr(HPS1000Relampint)+((HPS1000Reflector+HPS1000LampCost+cleaningRate*HPSreLampTime)*Eco.HPS1000Qty);
    
    HPS600ReLampYr = (((mainRate+HPS600LampCost)*Eco.HPS600Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.HPS600Qty))*ones(21,1);
    HPS600ReLampYr(1) = Eco.HPS600Init;
    HPS600ReLampYr(HPS600Relampint) = HPS600ReLampYr(HPS600Relampint)+((HPS600Reflector+HPS600LampCost+cleaningRate*HPSreLampTime)*Eco.HPS600Qty);
    
    fixReLampYr = cleaningRate*LEDcleantime*Eco.fixQty*ones(21,1);
    fixReLampYr(1) = Eco.fixInit;
    fixReLampYr(11) = fixReLampYr(11)+(Eco.fixQty*Eco.fixCost*LEDfailerRate(i));
    
    HPS1000CostYrLow = HPS1000ReLampYr+(Eco.HPS1000kWYr*Eco.enCostLow);
    HPS1000CostYrLow(1) = Eco.HPS1000Init;
    HPS600CostYrLow = HPS600ReLampYr+(Eco.HPS600kWYr*Eco.enCostLow);
    HPS600CostYrLow(1) = Eco.HPS600Init;
    fixCostYrLow = fixReLampYr+(Eco.fixkWYr*Eco.enCostLow);
    fixCostYrLow(1) = Eco.fixInit;
    
    HPS1000CostYrHigh = HPS1000ReLampYr+(Eco.HPS1000kWYr*Eco.enCostHigh);
    HPS1000CostYrHigh(1) = Eco.HPS1000Init;
    HPS600CostYrHigh= HPS600ReLampYr+(Eco.HPS600kWYr*Eco.enCostHigh);
    HPS600CostYrHigh(1) = Eco.HPS600Init;
    fixCostYrHigh = fixReLampYr+(Eco.fixkWYr*Eco.enCostHigh);
    fixCostYrHigh(1) = Eco.fixInit;
    
    Eco.HPS1000TotPayLow(:,i) = cumsum(HPS1000CostYrLow.*pv);
    Eco.HPS600TotPayLow(:,i) = cumsum(HPS600CostYrLow.*pv);
    Eco.fixTotPayLow(:,i) = cumsum(fixCostYrLow.*pv);
    
    Eco.HPS1000TotPayHigh(:,i) = cumsum(HPS1000CostYrHigh.*pv);
    Eco.HPS600TotPayHigh(:,i) = cumsum(HPS600CostYrHigh.*pv);
    Eco.fixTotPayHigh(:,i) = cumsum(fixCostYrHigh.*pv);
    
    Eco.HPS1000CFLow(:,i) = HPS1000CostYrLow - fixCostYrLow;
    Eco.HPS1000CFLow(1,1) = -fixCostYrLow(1);
    Eco.HPS1000CFHigh(:,i) = HPS1000CostYrHigh - fixCostYrHigh;
    Eco.HPS1000CFHigh(1,i) = -fixCostYrHigh(1);
    
    Eco.HPS600CFLow(:,i) = HPS600CostYrLow - fixCostYrLow;
    Eco.HPS600CFLow(1,i) = -fixCostYrLow(1);
    Eco.HPS600CFHigh(:,i) = HPS600CostYrHigh - fixCostYrHigh;
    Eco.HPS600CFHigh(1,i) = -fixCostYrHigh(1);
end
Eco.HPS1000CumCFLow = cumsum(Eco.HPS1000CFLow);
Eco.HPS1000CumCFHigh = cumsum(Eco.HPS1000CFHigh);

Eco.HPS600CumCFLow = cumsum(Eco.HPS600CFLow);
Eco.HPS600CumCFHigh = cumsum(Eco.HPS600CFHigh);

Eco.HPS1000RORLow = mean(Eco.HPS1000CFLow(2:end,:),1)/Eco.fixInit;
Eco.HPS1000RORHigh = mean(Eco.HPS1000CFHigh(2:end,:),1)/Eco.fixInit;

Eco.HPS600RORLow = mean(Eco.HPS600CFLow(2:end,:),1)/Eco.fixInit;
Eco.HPS600RORHigh = mean(Eco.HPS600CFHigh(2:end,:),1)/Eco.fixInit;
%% add to data for output
Data.Eco = Eco;
hLow = figure;
aLow = axes(hLow);
hold on
plot(aLow,0:20,Eco.fixTotPayLow(:,1),'LineWidth',2,'Color',[166,206,227]/255);
plot(aLow,0:20,Eco.fixTotPayLow(:,2),'LineStyle','--','LineWidth',2,'Color',[31,120,180]/255);
plot(aLow,0:20,Eco.HPS600TotPayLow(:,1),'LineWidth',1,'Color',[51,160,44]/255);
plot(aLow,0:20,Eco.HPS1000TotPayLow(:,1),'LineWidth',1,'Color',[227,26,28]/255);
hold off

hHigh = figure;
aHigh = axes(hHigh);
hold on
plot(aHigh,0:20,Eco.fixTotPayHigh(:,1),'LineWidth',2,'Color',[166,206,227]/255);
plot(aHigh,0:20,Eco.fixTotPayHigh(:,2),'LineStyle','--','LineWidth',2,'Color',[31,120,180]/255);
plot(aHigh,0:20,Eco.HPS600TotPayHigh(:,1),'LineWidth',1,'Color',[51,160,44]/255);
plot(aHigh,0:20,Eco.HPS1000TotPayHigh(:,1),'LineWidth',1,'Color',[227,26,28]/255);
hold off
set(aLow,'YLim',get(aHigh,'YLim'))
Formatfunc = @(x) sprintf('$%d',x);
set(aLow,'YTickLabel',arrayfun(Formatfunc, get(aLow,'YTick').', 'UniformOutput',0))
legend(aLow,'LED(1% Failure at year 10)','LED(25% Failure at year 10)','600 W HPS','1000 W HPS','Location','northwest');
xlabel(aLow,'Years')
ylabel(aLow,sprintf('Total Payments (US $)\n(Lower is better)'))
set(aLow,'xGrid','on')
set(aLow,'yGrid','on')
set(aLow,'xMinorGrid','on')
set(aHigh,'YTickLabel',arrayfun(Formatfunc, get(aHigh,'YTick').', 'UniformOutput',0))
legend(aHigh,'LED(1% Failure at year 10)','LED(25% Failure at year 10)','600 W HPS','1000 W HPS','Location','northwest');
xlabel(aHigh,'Years')
ylabel(aHigh,sprintf('Total Payments (US $)\n(Lower is better)'))
set(aHigh,'xGrid','on')
set(aHigh,'yGrid','on')
set(aHigh,'xMinorGrid','on')
if numel(varargin)==2
    saveas(hLow, varargin{1})
    RemoveWhiteSpace([], 'file', varargin{1});
    close(hLow);
    saveas(hHigh, varargin{2})
    RemoveWhiteSpace([], 'file', varargin{2});
    close(hHigh);
else
    title(aHigh,sprintf('LCCA  with $0.20/kWh Energy Rate \n(Present Worth Comparisons)'))
    title(aLow,sprintf('LCCA  with $0.10/kWh Energy Rate \n(Present Worth Comparisons)'))
    
end
end
