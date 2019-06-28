year = 0:Data.Years;
opphours = Data.oppHrs.*year;
Data.LampLife = 2000;
costYr = zeros(Data.Years+1,1);
% for i = 1:length(year)
%     cost = (testStruct.Eco.fix.kWYr*testStruct.Eco.enCost);
%     fixRelampint=[0,mod(opphours(2:end),Data.LampLife)-mod(opphours(1:end-1),Data.LampLife)<0];
%     
%     fixReflectorint=[0,mod(opphours(2:end),Data.ReflectorLife)-mod(opphours(1:end-1),Data.ReflectorLife)<0];
%     
% end
n=1;
lampChangeYr = [];
while(n*Data.LampLife)<opphours(end)
    lampChangeYr(n) = ceil(n*Data.LampLife/Data.oppHrs);
    n=n+1;
end
for i= 1:length(lampChangeYr)
    costYr(lampChangeYr(i))=costYr(lampChangeYr(i))+1;
end
disp(costYr)