function [CU,fluxTotal] = calcCU(IES,mountHeight, roomLength, roomWidth)
% CALCCU Calculates the Coefficients of Utilization for a given IESFile
%% Define Constants
% All formulas Taken from IES handbook page 10.41-10.42
zoneMultiplier = [0,0;0.041,0.98;0.070,1.05;0.100,1.12;0.136,0.16;0.190,1.25;0.315,1.25;0.640,1.25;2.10,0.80];
RCRfactor = [1.000,0.827,0.689,0.579,0.489,0.415,0.355,0.306,0.265,0.231,0.202];
RCR = (5*distdim(mountHeight,'m','ft')*(distdim(roomLength,'m','ft')+distdim(roomWidth,'m','ft')))/(distdim(roomLength,'m','ft')*distdim(roomWidth,'m','ft'));
Fcc2fc = interp1(0:10,RCRfactor,RCR);
%% Run Calculation
zone = zeros(18,3);
zone(1:18,1) = 0:10:170;
zone(1:18,2) = 10:10:180;

for i1 = 1:length(zone)
    itp = mean(interp2(IES.HorizAngles,IES.VertAngles,IES.photoTable,0:360,zone(i1,2)-5));
    zone(i1,3) = 2*pi*itp*(cos(deg2rad(zone(i1,1))) - cos(deg2rad(zone(i1,2))));
end
fluxTotal = sum(zone(:,3));
fluxUp = sum(zone(10:17,3));
fluxDown = sum(zone(1:9,3));
propUp = (1/fluxTotal)*fluxUp;
propDown = (1/fluxTotal)*fluxDown;
temp = zeros(9,1);
for i2=1:9
    Krcr = exp(-zoneMultiplier(i2,1)*(RCR.^zoneMultiplier(i2,2)));
    temp(i2) = Krcr*zone(i2,3);
end
Drcr = (1/(propDown*fluxTotal))*sum(temp);
% formulas Taken from IES handbook page 10.42. 
% Note: Becasue this is assumed for a greenhouse ceiling and wall reflectances are 0 
C1 = ((1-0)*(1-Fcc2fc.^2)*RCR)/((2.5*0*(1-Fcc2fc.^2))+(RCR*Fcc2fc*1-0)); % formula Taken from IES handbook page 10.42
C2 = ((1-0)*(1+Fcc2fc))/(1+(0*Fcc2fc)); 
C3 = ((1-0.2)*(1+Fcc2fc))/(1+(0.2*Fcc2fc));
C0 = C1 + C2 + C3;
CU = ((2.5*0*C1*C3*(1-Drcr)*propDown)/(RCR*(1-0)*(1-0.2)*C0))+ ...
     ((0*C2*C3*propUp)/((1-0)*(1-0.2)*C0))+...
((1-((0.2*C3*(C1+C2))/((1-0.2)*C0)))*((Drcr*propDown)/(1-0.2)));
end