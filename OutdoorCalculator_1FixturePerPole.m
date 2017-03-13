
close all
clear all
warning off MATLAB:divideByZero

min_required=0.2; %fc
max_required=4; %fc
GridSpacing=2.5; 

[fname, path] = uigetfile('*.ies','Please locate the IES file');
%------------------------------------------------------------------------------------
if fname==0
    err=errordlg('Invalid filename!','Error');
    waitfor(err);
    return
    % ----------------------------------------------------------------------------------
else
    fid = fopen(fullfile(path,fname));
    match = [];
    while isempty(match)
        tline = fgetl(fid);
        match = strmatch('TILT',tline);
        geometry = strmatch('TILT=NONE',tline);
        if geometry == 1
            A = [];
            while length(A)< 13
                tline = fgetl(fid);
                B = sscanf(tline,'%f');
                A = [A;B];
            end
            NoOfLamps = A(1);
            LumensPerLamp = A(2);
            CandelaMultiplier = A(3);
            NoVertAngles = A(4);
            NoHorizAngles = A(5);
            PhotoType = A(6);
            UnitsType = A(7);
            Width = A(8);
            Length = A(9);
            Height = A(10);
            BallastFactor = A(11);
            FutureUse = A(12);
            InputWatts = A(13);
            while (length(A)<(13+NoVertAngles+NoHorizAngles+NoVertAngles*NoHorizAngles))
                tline = fgetl(fid);
                B = sscanf(tline,'%f');
                A = [A;B];
            end
        end
    end
end
fclose(fid);

VertAngles = A(14:13+NoVertAngles);
HorizAngles = A(14+NoVertAngles:13+NoVertAngles+NoHorizAngles);
Candelas = A(14+NoVertAngles+NoHorizAngles:end)*CandelaMultiplier;

% Get candela matrix
M = zeros(NoVertAngles,NoHorizAngles);
for i = 1:NoHorizAngles
    M(:,i) = Candelas((i-1)*NoVertAngles+1:i*NoVertAngles);
end

if (HorizAngles(1)~=0 || HorizAngles(NoHorizAngles)~=180)
    msgbox('Horizontal angles are not from 0 to 180!', 'Horizontal Angle Warning', 'warn');
end

prompt   = {'Enter fixture Lateral distribution type (1, 2, 3, 4, or 5):',...
    'Enter fixture vertical distribution type, "v" for very short, "s" for short, "m" for medium, or "l" for long:',...
    'Enter light loss factor (from 0 to 1, 1 means no loss):'};
title    = 'Parameters for calculation';
lines = 1;
def     = {'3','m','1'};
matchwer1   = inputdlg(prompt,title,lines,def);
if isempty(matchwer1);
   return
else
   TypeLateral = matchwer1{1};
   TypeVertical = matchwer1{2};
   LossFactor = str2double(matchwer1{3});
end
M=M*LossFactor;

AE_all=zeros(7,1);
for n=1:7
PoleHeight=15+(n-1)*5;

AreaSize=PoleHeight*(GridSpacing*10); % square area side length in foot
S=AreaSize/GridSpacing;
if (rem(S,2)~=0 )
    %msgbox('Cell count is not an even number!', 'Odd cell count Warning', 'warn');
    S=(int32(S/2))*2;
end

%Calculate illuminances for a square area
P=zeros(S, (S/2), 4); %assuming symetric distribution along the road
for i=1:S
    for j=1:(S/2)
        x=(i-(S/2))*GridSpacing-GridSpacing/2; %assuming even number of cell counts along each side
        y=j*GridSpacing-GridSpacing/2; %assuming even number of cell counts along each side
        if (x==0 && y==0)
            HorizA=0;
            VertA=0;
        else
            HorizA=(atan((y/x)*1.0))*180/pi;
            if x<0
                HorizA=180+HorizA; 
            end
            VertA=(atan((sqrt(x*x+y*y))/PoleHeight))*180/pi;
        end
        P(i,j,1)=x;
        P(i,j,2)=y;
        P(i,j,3)=HorizA;
        P(i,j,4)=VertA;
    end
end
[H_Angles temp]=meshgrid(HorizAngles, 1:NoVertAngles);
[temp V_Angles]=meshgrid(1:NoHorizAngles, VertAngles);
Intensity=interp2(H_Angles, V_Angles, M,  P(:,:,3), P(:,:,4));
Distance=sqrt((P(:,:,1).*P(:,:,1)+P(:,:,2).*P(:,:,2)+PoleHeight*PoleHeight));
Grid_1=(Intensity./(Distance.*Distance)).*(PoleHeight./Distance);

Grid_2=zeros(S, (S/2));
for i=1:S
    for j=1:(S/2)
        Grid_2(i,j)=Grid_1(i, (S/2)-j+1);
    end
end
GridAll=[Grid_2 Grid_1];

%if (TypeLateral=='2' || TypeLateral=='3' || TypeLateral=='4')
    %Gc=[zeros(1,S); GridAll(1:(S-1), :)];
    %Gc=Gc+rot90(Gc,2);
%else
%    GridAll=GridAll+rot90(GridAll,2);
%end

switch TypeVertical
    case {'v'}
        X_Length=1.0*PoleHeight;
    case {'s'}
        X_Length=2.25*PoleHeight;
    case {'m'}
        X_Length=3.75*PoleHeight;        
    case {'l'}
        X_Length=6.0*PoleHeight;
end

switch TypeLateral
    case {'1'}
        Y_Length=1*PoleHeight;
    case {'2'}
        Y_Length=1.75*PoleHeight;        
    case {'3'}
        Y_Length=2.75*PoleHeight;
    case {'4'}
        Y_Length=6.0*PoleHeight;
    case {'5'}
        X_Length=1.75*PoleHeight;
        Y_Length=1.75*PoleHeight;
end

Xcell=int32(X_Length/GridSpacing);
Ycell=int32(Y_Length/GridSpacing);
if (TypeLateral == '2' || TypeLateral == '3' || TypeLateral == '4') 
    G=GridAll(int32(S/2+1):int32(S/2+Ycell), int32(S/2-Xcell+1):int32(S/2+Xcell));
else
    G=GridAll(int32(S/2-Ycell+1):int32(S/2+Ycell), int32(S/2-Xcell+1):int32(S/2+Xcell));
end

L_lamps=NoOfLamps*LumensPerLamp;
L_Ground=sum(sum(GridAll))*GridSpacing*GridSpacing;
L_CU_SS=(sum(sum(GridAll(int32(S/2+1):int32(S/2+Ycell), :))))*GridSpacing*GridSpacing; %street side
L_CU_HS=(sum(sum(GridAll(int32(S/2-Ycell+1):int32(S/2), :))))*GridSpacing*GridSpacing; %house side
L_Task=sum(sum(G))*GridSpacing*GridSpacing;
L_Conforming=0;
Count_Conforming=0;
[rows,cols]=size(G);
Count_CellsTotal=rows*cols;
for i=1:rows
    for j=1:cols
        if (G(i,j)>=min_required && G(i,j)<=max_required)
            L_Conforming=L_Conforming+G(i,j)*GridSpacing*GridSpacing;
            Count_Conforming=Count_Conforming+1;
        end
    end
end

CU_SS=L_CU_SS/L_lamps;
CU_HS=L_CU_HS/L_lamps;

Ratio_Conforming=Count_Conforming/Count_CellsTotal;
AE=L_Conforming*Ratio_Conforming/InputWatts;
Ratio_LumensInTask=L_Task/L_Ground;
AE_all(n)=AE;

end

scrsz = get(0,'ScreenSize');
h1=figure('Name','Application Efficacy at different pole heights','Position',[scrsz(3)/6 scrsz(4)/2 scrsz(3)/3 scrsz(4)/3]);
X=15:5:45;
Y=AE_all';
plot(X,Y,'-r','LineWidth',3);
xlabel('Pole Height (feet)')
ylabel('System Application Efficacy (lm/W)')

[Max_AE,I]=max(AE_all);
OptimumHeight=15+(I-1)*5;

prompt   = {['Optimum pole height for this fixture is ' num2str(OptimumHeight) ' feet, ' ...
    'which gives Application Efficacy of ' num2str(Max_AE) ' lm/W. ' ...
    'Enter the pole height you want to use:']};
title    = 'Pole height to be used';
lines = 1;
def     = {num2str(OptimumHeight)};
matchwer1   = inputdlg(prompt,title,lines,def);
if isempty(matchwer1);
   return
else
   PoleHeight= str2double(matchwer1{1});
end

AreaSize=PoleHeight*(GridSpacing*10); % square area side length in foot
S=AreaSize/GridSpacing;
if (rem(S,2)~=0 )
    %msgbox('Cell count is not an even number!', 'Odd cell count Warning', 'warn');
    S=(int32(S/2))*2;
end

%Calculate illuminances for a square area
P=zeros(S, (S/2), 4); %assuming symetric distribution along the road
for i=1:S
    for j=1:(S/2)
        x=(i-(S/2))*GridSpacing-GridSpacing/2; %assuming even number of cell counts along each side
        y=j*GridSpacing-GridSpacing/2; %assuming even number of cell counts along each side
        if (x==0 && y==0)
            HorizA=0;
            VertA=0;
        else
            HorizA=(atan((y/x)*1.0))*180/pi;
            if x<0
                HorizA=180+HorizA; 
            end
            VertA=(atan((sqrt(x*x+y*y))/PoleHeight))*180/pi;
        end
        P(i,j,1)=x;
        P(i,j,2)=y;
        P(i,j,3)=HorizA;
        P(i,j,4)=VertA;
    end
end
[H_Angles temp]=meshgrid(HorizAngles, 1:NoVertAngles);
[temp V_Angles]=meshgrid(1:NoHorizAngles, VertAngles);
Intensity=interp2(H_Angles, V_Angles, M,  P(:,:,3), P(:,:,4));
Distance=sqrt((P(:,:,1).*P(:,:,1)+P(:,:,2).*P(:,:,2)+PoleHeight*PoleHeight));
Grid_1=(Intensity./(Distance.*Distance)).*(PoleHeight./Distance);

Grid_2=zeros(S, (S/2));
for i=1:S
    for j=1:(S/2)
        Grid_2(i,j)=Grid_1(i, (S/2)-j+1);
    end
end
GridAll=[Grid_2 Grid_1];

%if (TypeLateral=='2' || TypeLateral=='3' || TypeLateral=='4')
    %Gc=[zeros(1,S); GridAll(1:(S-1), :)];
    %Gc=Gc+rot90(Gc,2);
%else
%    GridAll=GridAll+rot90(GridAll,2);
%end

QuarterSize=int32(S/4);
[X Y]=meshgrid(-QuarterSize+1:QuarterSize, -QuarterSize+1:QuarterSize);
HalfG=GridAll(QuarterSize+1:QuarterSize*3,QuarterSize+1:QuarterSize*3);
scrsz = get(0,'ScreenSize');
h2=figure('Name','3D illuminance profile','Position',[scrsz(3)/6 scrsz(4)/10 scrsz(3)/3 scrsz(4)/3]);
meshc(X, Y, HalfG);
h3=figure('Name','Isofootcandle plot per luminaire','Position',[scrsz(3)/2 scrsz(4)/10 scrsz(3)/3 scrsz(4)/3]);
[C, h]=contour(X, Y, HalfG, [0.1 0.25 0.5 1.0 2.0]);
clabel(C,h);
xTickLabel=get(gca,'XTickLabel');
[r,c]=size(xTickLabel);
xTick=zeros(1,r);
for t=1:r
    xTick(1,t)=(str2double(strcat(xTickLabel(t,:))))*GridSpacing;
end
set(gca,'XTickLabel',xTick(1,:))
yTickLabel=get(gca,'YTickLabel');
[r,c]=size(yTickLabel);
yTick=zeros(1,r);
for t=1:r
    yTick(1,t)=(str2double(strcat(yTickLabel(t,:))))*GridSpacing;
end
set(gca,'YTickLabel',yTick(1,:))
xlabel('Dimension in Longituidal Direction (feet)')
ylabel('Dimension in Transversal Direction (feet)')

switch TypeVertical
    case {'v'}
        X_Length=1.0*PoleHeight;
    case {'s'}
        X_Length=2.25*PoleHeight;
    case {'m'}
        X_Length=3.75*PoleHeight;        
    case {'l'}
        X_Length=6.0*PoleHeight;
end

switch TypeLateral
    case {'1'}
        Y_Length=1*PoleHeight;
    case {'2'}
        Y_Length=1.75*PoleHeight;        
    case {'3'}
        Y_Length=2.75*PoleHeight;
    case {'4'}
        Y_Length=6.0*PoleHeight;
    case {'5'}
        X_Length=1.75*PoleHeight;
        Y_Length=1.75*PoleHeight;
end

Xcell=int32(X_Length/GridSpacing);
Ycell=int32(Y_Length/GridSpacing);
if (TypeLateral == '2' || TypeLateral == '3' || TypeLateral == '4') 
    G=GridAll(int32(S/2+1):int32(S/2+Ycell), int32(S/2-Xcell+1):int32(S/2+Xcell));
else
    G=GridAll(int32(S/2-Ycell+1):int32(S/2+Ycell), int32(S/2-Xcell+1):int32(S/2+Xcell));
end

L_lamps=NoOfLamps*LumensPerLamp;
L_Ground=sum(sum(GridAll))*GridSpacing*GridSpacing;
L_CU_SS=(sum(sum(GridAll(int32(S/2+1):int32(S/2+Ycell), :))))*GridSpacing*GridSpacing; %street side
L_CU_HS=(sum(sum(GridAll(int32(S/2-Ycell+1):int32(S/2), :))))*GridSpacing*GridSpacing; %house side
L_Task=sum(sum(G))*GridSpacing*GridSpacing;
L_Conforming=0;
Count_Conforming=0;
[rows,cols]=size(G);
Count_CellsTotal=rows*cols;
for i=1:rows
    for j=1:cols
        if (G(i,j)>=min_required && G(i,j)<=max_required)
            L_Conforming=L_Conforming+G(i,j)*GridSpacing*GridSpacing;
            Count_Conforming=Count_Conforming+1;
        end
    end
end

%X=(-Xcell+1:1:Xcell);
%[max_G_rows,I]=max(G,[],2); %max along the rows
%[max_G,max_I]=max(max_G_rows);
%Y=G(max_I,:);
%h=figure('Name', [fname '  ' 'Plot of Illumiance Contour Along Maximum Value']);
%plot(X,Y,'-r','LineWidth',2);
%xlabel('Position of Cells Along the Road')
%ylabel('Illuminance (fc)')
%title([fname '  ' 'Plot of Illumiance Contour Along Maximum Value'])
%saveas(h,fname,'jpg')

CU_SS=L_CU_SS/L_lamps;
CU_HS=L_CU_HS/L_lamps;

Ratio_Conforming=Count_Conforming/Count_CellsTotal;
AE=L_Conforming*Ratio_Conforming/InputWatts;
Ratio_LumensInTask=L_Task/L_Ground;

%if (TypeLateral=='2' || TypeLateral=='3' || TypeLateral=='4')
%    Gc=[zeros(1,S); GridAll(1:(S-1), :)];
%    Gc=Gc+rot90(Gc,2);
%else
    Gc=GridAll;
%end

[X Y]=meshgrid(-QuarterSize+1:QuarterSize, -QuarterSize+1:QuarterSize);
scrsz = get(0,'ScreenSize');
h4=figure('Name','Isofootcandle plot per pole (1 or 2 Luminaires)','Position',[scrsz(3)/2 scrsz(4)/2 scrsz(3)/3 scrsz(4)/3]);
[C, h]=contour(X, Y, Gc(QuarterSize+1:QuarterSize*3,QuarterSize+1:QuarterSize*3), [0.1 0.25 0.5 1.0 2.0]);
clabel(C,h);
xTickLabel=get(gca,'XTickLabel');
[r,c]=size(xTickLabel);
xTick=zeros(1,r);
for t=1:r
    xTick(1,t)=(str2double(strcat(xTickLabel(t,:))))*GridSpacing;
end
set(gca,'XTickLabel',xTick(1,:))
yTickLabel=get(gca,'YTickLabel');
[r,c]=size(yTickLabel);
yTick=zeros(1,r);
for t=1:r
    yTick(1,t)=(str2double(strcat(yTickLabel(t,:))))*GridSpacing;
end
set(gca,'YTickLabel',yTick(1,:))
xlabel('Dimension in Longituidal Direction (feet)')
ylabel('Dimension in Transversal Direction (feet)')

for i=1:S/2    
    for j=1:S/2
        if Gc(i,j)>=0.1
            i1=i;
            j1=j;
            break
        end
    end
    if Gc(i,j)>=0.1
        break
    end
end
for j=1:S/2
    for i=1:S/2
        if Gc(i,j)>=0.1
            i2=i;
            j2=j;
            break
        end
    end
    if Gc(i,j)>=0.1
        break
    end
end
  
Y_spacing=S-2*min(i1,i2); %Intitial recommended spacing between luminaires on vertical direction
X_spacing=S-2*min(j1,j2); %Intitial recommended spacing between luminaires on horizontal direction
x_half=int32(X_spacing/2);
y_half=int32(Y_spacing/2);

Gi=Gc((S/2-y_half)+1:(S/2+y_half),(S/2-x_half)+1:(S/2+x_half));

for i=1:Y_spacing
    if mean(Gi(i,:))>=0.05
        i_final=i;
        break
    end
end
for j=1:X_spacing
    if mean(Gi(:,j))>=0.05
        j_final=j;
        break
    end
end

G_final=Gi(i_final:(Y_spacing-i_final+1), j_final:(X_spacing-j_final+1));
Y_spacing=Y_spacing-2*i_final;
X_spacing=X_spacing-2*j_final;

AAE=mean(mean(G_final)); % Average Application Illuminance, fc
min_E=min(min(G_final));
uniformity=AAE/min_E;

prompt   = {['Application Efficacy is ' num2str(AE) ' lm/W. Recommended spacing between luminaires is '...
    num2str(X_spacing*GridSpacing) ' feet along the roadway direction, and ' num2str(Y_spacing*GridSpacing) ' feet across the roadway direction. '...
    'Average illuminance in the recommended area by a single pole is ' num2str(AAE) ' footcandle. '...
    'Uniformity Ratio (Avg/Min) in the recommended area by a single pole is ' num2str(uniformity) '. '...
    'CU on the street side is ' num2str(CU_SS) ';  CU on the house side is ' num2str(CU_HS) '. '...
    'Enter luminaire price in $:'],...
    'Enter initial pole installtion cost in $:',...
    'Enter lamp life in hours:',...
    'Enter number of operation hours per day:',...
    'Enter lamp replacement cost (including parts and labor) in $:',...
    'Enter electricity cost in cents per KWH:',...
    'Enter annual interest rate in %:',...
    'Enter number of years for Life Cycle Cost consideration:'};
title    = 'Parameters for calculation';
lines = 1;
def     = {'1000','500', '10000', '12', '200', '10','5', '30'};
matchwer1   = inputdlg(prompt,title,lines,def);
if isempty(matchwer1);
   return
else
   LuminiareCost = str2double(matchwer1{1});
   InitialCost = str2double(matchwer1{2});
   LampLife=str2double(matchwer1{3});
   NumHours=str2double(matchwer1{4});
   ReplaceCost=str2double(matchwer1{5});
   ElectricityCost=(str2double(matchwer1{6}))/100;
   %InflationRate=str2double(matchwer1{7});
   InterestRate=(str2double(matchwer1{7}))/100;
   NumYears=str2double(matchwer1{8});
end

if (TypeLateral=='2' || TypeLateral=='3' || TypeLateral=='4')
    NumLuminaires=2;
else
    NumLuminaires=1;
end

InstallCost=InitialCost+NumLuminaires*LuminiareCost;
NumReplacements=ceil(NumYears*365*NumHours/LampLife);
ReplaceCost=NumLuminaires*ReplaceCost;
AnnualElecCost=NumLuminaires*(365*NumHours*InputWatts/1000)*ElectricityCost;

PW_rep=zeros(1,NumReplacements);
Rep_interval=NumYears*1.00/NumReplacements;
for w=1:NumReplacements
    PW_rep(1,w)=ReplaceCost/((1+InterestRate)^(w*Rep_interval));
end
PW_replacements=sum(PW_rep(1,:));

if InterestRate~=0
    PW_electricity=AnnualElecCost*((1+InterestRate)^NumYears-1)/(InterestRate*(1+InterestRate)^NumYears);
else
    PW_electricity=AnnualElecCost*NumYears;
end

LCC=InstallCost+PW_replacements+PW_electricity; % Life Cycle Cost
RecArea=(X_spacing*GridSpacing)*(Y_spacing*GridSpacing);
%RecAreaPerLuminaire=RecArea/NumLuminaires;
ALCC=LCC/RecArea; % Average Life Cycle Cost per square foot

% Next, calculate visual efficacy at mesopic level
prompt   = {['Life Cycle Cost for this pole (with 1 or 2 luminaires) is $' num2str(LCC) ...
    '; Average Life Cycle Cost per square foot is ' num2str(ALCC) '$/sqft. Recommended coverage area per pole is ' num2str(RecArea)...
    ' sq.ft.. Enter S/P ratio of the base case light source:'], 'Enter the reflectance of the pavement in percent (i.e., 0 to 100)'};
title    = 'Unified System of Photometry Calculator';
lines = 1;
def     = {'0.65', '7'};
answer1   = inputdlg(prompt,title,lines,def);

if isempty(answer1);
   return
			else
   			SP1 = str2double(answer1{1});
            R1  = str2double(answer1{2});            
end

AAE_lx=AAE*10.76; %change to lux
L1 = AAE_lx * (R1/100) / 3.1416;
if L1>=0.6;
    E_new=L1;
else
    prompt    = {'Enter S/P ratio of the alternative light source:'};
    title     = 'Unified System of Photometry Calculator';
    lines     = 1;
    def       = {'2.15'};
    answer2   = inputdlg(prompt,title,lines,def);
    if isempty(answer2);
        return
    else
        SP2 = str2double(answer2);
    end
    
    P1=L1;
    S1=SP1*L1;
    
    UL1 = 0.834*P1-0.335*S1-0.2+(0.696*P1^2-0.333*P1-0.56*P1*S1+0.113*S1^2+0.537*S1+0.04)^0.5;
    
    ul1=round(UL1*10000);
    
    for i=UL1/2:((UL1-UL1/2)/1000):UL1*3;
        P2=i;
        S2=SP2*P2;
        UL2 = 0.834*P2-0.335*S2-0.2+(0.696*P2^2-0.333*P2-0.56*P2*S2+0.113*S2^2+0.537*S2+0.04)^0.5;
        ul2=round(UL2*10000);
        if abs(ul2 - ul1)<ul1*0.01;
            E_new = i; %round(i*1000000)/100000;
            break
        end
    end
end

E_new = (E_new*3.1416/(R1/100))/10.76;
r=(1-E_new/AAE)*100;
msgbox(['Illuminance can be reduced to is ' num2str(E_new) ' fc, which is ' num2str(r) '% lower than the initial light source.'], 'Illuminance Level');