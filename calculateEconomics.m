function [Data] = calculateEconomics(Data)

LSAEcol = Data.LSAE(:,3);
fixcount = Data.outTable.count;
[~,ind]= max(LSAEcol);
ind = ((ind-1)*5)+3;
load('PlantCalculatorHPSfixtures.mat');
Eco.HPS1000qty = HPS1000Table.LRcount(59)*HPS1000Table.TBcount(59); %2m @300ppfd target
Eco.HPS600qty = HPS600Table.LRcount(59)*HPS600Table.TBcount(59); %2m @300ppfd target
Eco.HPS1000Cost = 525;
Eco.HPS600Cost = 460;
Eco.HPS1000watt = HPS1000IES.InputWatts;
Eco.HPS600watt=HPS600IES.InputWatts;
Eco.energyCost=0.1048;
Eco.fixtureCost = Data.Cost;
Eco.HPS1000WpM = (Eco.HPS1000watt*Eco.HPS1000qty)/100;
Eco.HPS600WpM = (Eco.HPS600watt*Eco.HPS600qty)/100;
Eco.FixtureWpM = (Data.Wattage*fixcount(ind))/100;
Eco.HPS1000Wpft = Eco.HPS1000WpM/10.7639; %convert to Watt/ft^2
Eco.HPS600Wpft = Eco.HPS600WpM/10.7639;   %convert to Watt/ft^2
Eco.FixtureWpft = Eco.FixtureWpM/10.7639; %convert to Watt/ft^2
Eco.HPS1000kWpY = (Eco.HPS1000WpM*365*12)/1000;
Eco.HPS600kWpY = (Eco.HPS600WpM*365*12)/1000;
Eco.FixturekWpY = (Eco.FixtureWpM*365*12)/1000;
Eco.HPS1000kWpYft = (Eco.HPS1000Wpft*365*12)/1000;
Eco.HPS600kWpYft = (Eco.HPS600Wpft*365*12)/1000;
Eco.FixturekWpYft = (Eco.FixtureWpft*365*12)/1000;
Eco.HPS1000EnCost = Eco.HPS1000kWpY*Eco.energyCost;
Eco.HPS600EnCost = Eco.HPS600kWpY*Eco.energyCost;
Eco.FixtureEnCost = Eco.FixturekWpY*Eco.energyCost;
Eco.HPS1000EnCostft = Eco.HPS1000kWpYft*Eco.energyCost;
Eco.HPS600EnCostft = Eco.HPS600kWpYft*Eco.energyCost;
Eco.FixtureEnCostft = Eco.FixturekWpYft*Eco.energyCost;
Eco.HPS1000Save = Eco.HPS1000EnCost-Eco.FixtureEnCost;
Eco.HPS600Save = Eco.HPS600EnCost-Eco.FixtureEnCost;
Eco.HPS1000Paynum = (Eco.fixtureCost*Eco.fixcount(ind))/Eco.HPS1000Save;
Eco.HPS600Paynum = (Eco.fixtureCost*Eco.fixcount(ind))/Eco.HPS600Save;
if Eco.HPS1000Save < 0
    Eco.HPS1000pari = 'pari';
    Eco.HPS1000SaveStr = sprintf('($%0.0f)',abs(Eco.HPS1000Save));
    Eco.HPS1000Pay = 'No Payback';
    Eco.incentive1000  = 0;
    Eco.newHPS1000Paynum = Eco.HPS1000Paynum;
    while (Eco.newHPS1000Paynum<0)
        Eco.incentive1000 = Eco.incentive1000+1;
        Eco.incentiveCost = (Eco.fixtureCost-Eco.incentive1000)*fixcount(ind);
        Eco.newHPS1000Paynum = Eco.incentiveCost/Eco.HPS1000Save;
        Eco.incentive1000str = sprintf('An incentive of at least $%0.0f per luminaire is required to have equal energy costs as the 1000 W HPS system.',Eco.incentive1000);
    end
else
    Eco.HPS1000pari = 'yw4l';
    Eco.HPS1000SaveStr = sprintf('$%0.0f',Eco.HPS1000Save);
    Eco.HPS1000Pay =sprintf('%0.0f',Eco.HPS1000Paynum);
    Eco.incentive1000  = 0;
    Eco.newHPS1000Paynum = Eco.HPS1000Paynum;
    if Eco.newHPS1000Paynum>3
        while (Eco.newHPS1000Paynum>3)
            Eco.incentive1000 = Eco.incentive1000+1;
            Eco.incentiveCost = (Eco.fixtureCost-Eco.incentive1000)*fixcount(ind);
            Eco.newHPS1000Paynum = Eco.incentiveCost/Eco.HPS1000Save;
            Eco.incentive1000str = sprintf('An incentive of $%0.0f per luminaire would reduce the payback period to less than 3 years compared to the 1000 W HPS system.',Eco.incentive1000);
        end
    else
        Eco.incentive1000str = 'No additional incentive is needed when compared to the 1000 W HPS system.';
    end
end
if Eco.HPS600Save < 0
    Eco.HPS600pari = 'pari';
    Eco.HPS600SaveStr = sprintf('($%0.0f)',abs(Eco.HPS600Save));
    Eco.HPS600Pay = 'No Payback';
    Eco.incentive600 = 0;
    Eco.newHPS600Paynum = Eco.HPS600Paynum;
    while (Eco.newHPS600Paynum<0)
        Eco.incentive600 = Eco.incentive600+1;
        Eco.incentiveCost = (Eco.fixtureCost-Eco.incentive600)*fixcount(ind);
        Eco.newHPS600Paynum = Eco.incentiveCost/Eco.HPS600Save;
        Eco.incentive600str = sprintf('An incentive of at least $%0.0f per luminaire is required to have equal energy costs as the 600 W HPS system.',Eco.incentive600);
    end
else
    Eco.HPS600pari = 'yw4l';
    Eco.HPS600SaveStr = sprintf('$%0.0f',Eco.HPS600Save);
    Eco.HPS600Pay = sprintf('%0.0f',Eco.HPS600Paynum);
    Eco.incentive600 = 0;
    Eco.newHPS600Paynum = Eco.HPS600Paynum;
    if Eco.newHPS600Paynum>3
        while (Eco.newHPS600Paynum>3)
            Eco.incentive600 = Eco.incentive600+1;
            Eco.incentiveCost = (Eco.fixtureCost-Eco.incentive600)*fixcount(ind);
            Eco.newHPS600Paynum = Eco.incentiveCost/Eco.HPS600Save;
            Eco.incentive600str = sprintf('An incentive of $%0.0f would reduce the payback period to less than 3 years compared to the 600 W HPS system.',Eco.incentive600);
        end
    else
        Eco.incentive600str = 'No additional incentive is needed when compared to the 600 W HPS system.';
    end
end

Data.Eco = Eco;
end
