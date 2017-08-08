function [Data] = calculateEconomics(Data,roomLength,roomWidth)

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
% Eco.HPS1000Qty = size(HPS1000Table.count{59},1); %2m @300ppfd target
% Eco.HPS600Qty = size(HPS600Table.count{59},1); %2m @300ppfd target
Eco.HPS1000Qty = HPS1000Table.TBcount(59)*HPS1000Table.LRcount(59); %2m @300ppfd target
Eco.HPS600Qty = HPS600Table.TBcount(59)*HPS600Table.LRcount(59); %2m @300ppfd target
Eco.fixQty = size(PPFD300.count{ind},1);

Eco.HPS1000Watt = HPS1000IES.InputWatts;
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

Eco.HPS1000kWYr = (Eco.HPS1000Watt/1000)*opperatingHrs*Eco.HPS1000Qty;
Eco.HPS600kWYr = (Eco.HPS600Watt/1000)*opperatingHrs*Eco.HPS600Qty;
Eco.fixkWYr = (Eco.fixWatt/1000)*opperatingHrs*Eco.fixQty;

Eco.HPS1000kWftYr = (Eco.HPS1000kWYr)/ftArea;
Eco.HPS600kWftYr = (Eco.HPS600kWYr)/ftArea;
Eco.fixkWftYr = (Eco.fixkWYr)/ftArea;

Eco.HPS1000kWmYr = (Eco.HPS1000kWYr)/mArea;
Eco.HPS600kWmYr = (Eco.HPS600kWYr) /mArea;
Eco.fixkWmYr = (Eco.fixkWYr)/mArea;

Eco.HPS1000CostFtLow= (Eco.HPS1000kWYr*Eco.enCostLow)/ftArea;
Eco.HPS600CostFtLow = (Eco.HPS600kWYr*Eco.enCostLow)/ftArea;
Eco.fixCostFtLow = (Eco.fixkWYr*Eco.enCostLow)/ftArea;

Eco.HPS1000CostFtHigh= (Eco.HPS1000kWYr*Eco.enCostHigh)/ftArea;
Eco.HPS600CostFtHigh = (Eco.HPS600kWYr*Eco.enCostHigh)/ftArea;
Eco.fixCostFtHigh = (Eco.fixkWYr*Eco.enCostHigh)/ftArea;

Eco.HPS1000CostmLow= (Eco.HPS1000kWYr*Eco.enCostLow)/mArea;
Eco.HPS600CostmLow = (Eco.HPS600kWYr*Eco.enCostLow)/mArea;
Eco.fixCostmLow = (Eco.fixkWYr*Eco.enCostLow)/mArea; 

Eco.HPS1000CostmHigh= (Eco.HPS1000kWYr*Eco.enCostHigh)/mArea;
Eco.HPS600CostmHigh = (Eco.HPS600kWYr*Eco.enCostHigh)/mArea;
Eco.fixCostmHigh = (Eco.fixkWYr*Eco.enCostHigh)/mArea; 
%% 20Yr Cost Calculation
LEDfailerRate = [0.01, 0.25];
for i = 1:length(LEDfailerRate)
mainRate = 16;%$ perLamp from:RSMeans Data 2017
HPScleaningRate = 60; %$ per fixture from:RSMeans Data 2017
LEDcleaningRate = 6;
pv = round(pvvar(eye(21), 0.03),3)'; %present Value
HPS1000Life = 10000;
HPS600Life = 12000;

HPS1000LampCost = 100;
HPS600LampCost = 32;
HPS1000Reflector = 40;
HPS600Reflector = 40;
HPSfailerRate = 0.02;


HPS1000Relampint = 1+floor(HPS1000Life/opperatingHrs):floor(HPS1000Life/opperatingHrs):20;
HPS600Relampint = 1+floor(HPS600Life/opperatingHrs):floor(HPS600Life/opperatingHrs):20;
HPS1000ReLampYr = ((opperatingHrs/HPS1000Life)*(HPS1000LampCost*Eco.HPS1000Qty)*HPSfailerRate)*ones(21,1);
HPS1000ReLampYr(1) = 0;
HPS1000ReLampYr(HPS1000Relampint) = HPS1000ReLampYr(HPS1000Relampint)+((HPS1000Reflector+HPS1000LampCost+HPScleaningRate)*Eco.HPS1000Qty);
HPS600ReLampYr = ((opperatingHrs/HPS600Life)*(HPS600LampCost+mainRate)*Eco.HPS600Qty)*ones(21,1);
HPS600ReLampYr(1) = Eco.HPS600Init;
HPS600ReLampYr(HPS600Relampint) = HPS600ReLampYr(HPS600Relampint)+((HPS600Reflector+HPS600LampCost+HPScleaningRate)*Eco.HPS600Qty);

fixReLampYr = zeros(21,1);
fixReLampYr(11) = (Eco.fixQty*Eco.fixCost*LEDfailerRate(i));
HPS1000YrClean = Eco.HPS1000Qty*HPScleaningRate;
HPS600YrClean = Eco.HPS600Qty*HPScleaningRate;
fixYrClean = Eco.fixQty*LEDcleaningRate;

HPS1000CostYrLow = HPS1000ReLampYr+HPS1000YrClean+(Eco.HPS1000kWYr*Eco.enCostLow);
HPS1000CostYrLow(1) = Eco.HPS1000Init;
HPS600CostYrLow = HPS600ReLampYr+HPS600YrClean+(Eco.HPS600kWYr*Eco.enCostLow);
HPS600CostYrLow(1) = Eco.HPS600Init;
fixCostYrLow = fixReLampYr+fixYrClean+(Eco.fixkWYr*Eco.enCostLow);
fixCostYrLow(1) = Eco.fixInit;

HPS1000CostYrHigh = HPS1000ReLampYr+HPS1000YrClean+(Eco.HPS1000kWYr*Eco.enCostHigh);
HPS1000CostYrHigh(1) = Eco.HPS1000Init;
HPS600CostYrHigh= HPS600ReLampYr+HPS600YrClean+(Eco.HPS600kWYr*Eco.enCostHigh);
HPS600CostYrHigh(1) = Eco.HPS600Init;
fixCostYrHigh = fixReLampYr+fixYrClean+(Eco.fixkWYr*Eco.enCostHigh);
fixCostYrHigh(1) = Eco.fixInit;

Eco.HPS1000WTotPayLow(:,i) = cumsum(HPS1000CostYrLow.*pv);
Eco.HPS600WTotPayLow(:,i) = cumsum(HPS600CostYrLow.*pv);
Eco.fixTotPayLow(:,i) = cumsum(fixCostYrLow.*pv);

Eco.HPS1000WTotPayHigh(:,i) = cumsum(HPS1000CostYrHigh.*pv);
Eco.HPS600WTotPayHigh(:,i) = cumsum(HPS600CostYrHigh.*pv);
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

figure;
plot(Eco.fixTotPayLow,0:20)
end
