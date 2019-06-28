function [Data] = simpleCalcEconomics(qty,Data,IESdata,roomLength,roomWidth,varargin)


%% init variables
opperatingHrs =Data.oppHrs; %From talks with growers
installRate = Data.installRate; %$ per fixture from:RSMeans Data 2017
Eco.enCost = Data.enCost;%$ per kW

ftArea = roomLength*roomWidth;
mArea = (roomLength*unitsratio('m','ft'))*(roomWidth*unitsratio('m','ft'));
%% initial costs

Eco.fix.Qty = qty;

Eco.fix.Watt = IESdata.InputWatts;

Eco.fix.Cost = Data.Price;

Eco.fix.Init = Eco.fix.Qty*(Eco.fix.Cost+installRate);

Eco.fix.InitFt = Eco.fix.Init/ftArea;

Eco.fix.InitM = Eco.fix.Init/mArea;

%% Annual costs
Eco.fix.WFt = (Eco.fix.Watt*Eco.fix.Qty)/ftArea;

Eco.fix.WM = (Eco.fix.Watt*Eco.fix.Qty)/mArea;

Eco.fix.kWYr = (Eco.fix.Watt/1000)*opperatingHrs*Eco.fix.Qty;

Eco.fix.kWftYr = (Eco.fix.kWYr)/ftArea;

Eco.fix.kWmYr = (Eco.fix.kWYr)/mArea;

Eco.fix.CostYr = (Eco.fix.kWYr*Eco.enCost);

Eco.fix.CostFtYr = Eco.fix.CostYr/ftArea;

Eco.fix.CostmYr = Eco.fix.CostYr/mArea;

%% 20Yr Cost Calculation
LEDfailerRate = [0.01, 0.25];
mainRate = 16;%$ perLamp per hourfrom:RSMeans Data 2017
cleaningRate = 60; %$ per fixture per hour from:RSMeans Data 2017
HPScleanTime = .5;%hrs
HPSreLampTime = 1; %hrs
LEDcleantime = .1;

pv = round(pvvar(eye(Data.Years+1), 0.03),3)'; %present Value
HPSfailerRate = 0.02;
if strcmpi(Data.Source, 'LED')
    for i = 1:length(LEDfailerRate)
        year = 0:Data.Years;
        opphours = opperatingHrs.*year;
        fixRelampint=[0,mod(opphours(2:end),Data.LampLife)-mod(opphours(1:end-1),Data.LampLife)<0];
        
        fixReflectorint=[0,mod(opphours(2:end),Data.ReflectorLife)-mod(opphours(1:end-1),Data.ReflectorLife)<0];
        
        fixRelampint = or(fixRelampint, fixReflectorint);
        
        fixReLampYr = cleaningRate*LEDcleantime*Eco.fix.Qty*ones(Data.Years+1,1);
        fixReLampYr(1) = Eco.fix.Init;
        fixReLampYr(11) = fixReLampYr(11)+(Eco.fix.Qty*Eco.fix.Cost*LEDfailerRate(i));
        
        fixCostYr = fixReLampYr+(Eco.fix.kWYr*Eco.enCost);
        fixCostYr(1) = Eco.fix.Init;
        
        Eco.fix.TotPay(:,i) = cumsum(fixCostYr.*pv);
        
    end
else
    i = 1;
    year = 0:Data.Years;
    opphours = opperatingHrs.*year;
%     fixReLampYr = (((mainRate+Data.LampCost)*Eco.fix.Qty*HPSfailerRate)+((cleaningRate*HPScleanTime)*Eco.fix.Qty))*zeros(Data.Years+1,1);
    fixReLampYr = zeros(Data.Years+1,1);
    fixReLampYr(1) = Eco.fix.Init;
    if Data.LampLife>0 && Data.LampLife<opphours(end)
        lampChangeYr = zeros(floor(opphours(end)/Data.LampLife),1);
        for i= 1:length(lampChangeYr)
            lampChangeYr(i) = ceil(i*Data.LampLife/Data.oppHrs)+1;
            fixReLampYr(lampChangeYr(i))=fixReLampYr(lampChangeYr(i))+...   % on years where a lamp life cycle ends
                (Data.LampCost+Data.LampLabor)*ceil(Eco.fix.Qty);% spot Relamping from the cycle
        end
    end
    if Data.ReflectorLife>0 && Data.ReflectorLife<opphours(end)
        ReflectorChangeYr = zeros(floor(opphours(end)/Data.ReflectorLife),1);
        for i= 1:length(ReflectorChangeYr)
            ReflectorChangeYr(i) = ceil(i*Data.ReflectorLife/Data.oppHrs)+1;
            fixReLampYr(ReflectorChangeYr(i))=fixReLampYr(ReflectorChangeYr(i))+...   % on years where a reflector life cycle ends
                (Data.ReflectorCost+Data.ReflectorLabor)*ceil(Eco.fix.Qty);
        end
    end
    
    if Data.BallastLife>0 && Data.BallastLife<opphours(end)
        BallastChangeYr = zeros(floor(opphours(end)/Data.BallastLife),1);
        for i= 1:length(BallastChangeYr)
            BallastChangeYr(i) = ceil(i*Data.BallastLife/Data.oppHrs)+1;
            fixReLampYr(BallastChangeYr(i))=fixReLampYr(BallastChangeYr(i))+...   % on years where a ballast life cycle ends
                (Data.BallastCost+Data.BallastLabor)*ceil(Eco.fix.Qty);
        end
    end
    fixCostYr = fixReLampYr+(Eco.fix.kWYr*Eco.enCost);
    fixCostYr(1) = Eco.fix.Init;
    
    Eco.fix.TotPay(:,1) = cumsum(fixCostYr.*pv);
    
end

%% add to data for output
Data.Eco = Eco;
hLow = figure('units','in');
set(hLow,'Renderer','painters');
aLow = axes(hLow);
hold on
if strcmpi(Data.Source, 'LED')
    plot(aLow,0:Data.Years,Eco.fix.TotPay(:,1),'LineWidth',2,'Color',[166,206,227]/255);
    plot(aLow,0:Data.Years,Eco.fix.TotPay(:,2),'LineStyle','--','LineWidth',2,'Color',[31,120,180]/255);
else
    plot(aLow,0:Data.Years,Eco.fix.TotPay(:,1),'LineWidth',2,'Color',[255,255,255]/255);
    plot(aLow,0:Data.Years,Eco.fix.TotPay(:,1),'LineWidth',2,'Color',[31,120,180]/255);
end

hold off

if strcmpi(Data.Source, 'LED')
    lgndLow = legend(aLow,'This LED(1% Failure at year 10)',' This LED(25% Failure at year 10)','Location','best');
else
    lgndLow = legend(aLow,' ',sprintf('This %s Luminaire',Data.Source),'Location','best');
end
set(lgndLow,'FontSize',6,'Visible','off');
xlabel(aLow,'Years','FontSize',7,'FontWeight','Bold')
ylabel(aLow,sprintf('Total Payments (US $)'),'FontSize',7,'FontWeight','Bold')
set(aLow,'xGrid','on','yGrid','on','xMinorGrid','on','Box','on')
Formatfunc = @(x) sprintf('$%d K',x/1000);
set(aLow,'YTickLabel',arrayfun(Formatfunc, get(aLow,'YTick').', 'UniformOutput',0))
if numel(varargin)==1
    pos = get(hLow,'InnerPosition');
    set(hLow,'InnerPosition',[pos(1),pos(2),3.5,1.5])
    set(aLow,'units', 'normalized','outerPosition',[0 0 1 1],'fontsize',7)
    Formatfunc = @(x) sprintf('$%d K',x/1000);
    set(aLow,'YTickLabel',arrayfun(Formatfunc, get(aLow,'YTick').', 'UniformOutput',0))
    print(hLow,'-dpng', varargin{1},'-r600');
    RemoveWhiteSpace([], 'file', varargin{1});
    close(hLow);
else
    title(aLow,sprintf('LCCA  with $%.4f/kWh Energy Rate \n(Present Worth Comparisons)',Eco.enCost))
    close(hLow);
end
end
