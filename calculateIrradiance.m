useGInput = 0; % set to 1 to use mouse to locate fixture locations
fixtureOrientation = 0; % specify fixture orientation in degrees
close all
%if(ishandle(2))
%    close(2)
%end
filePathName = '\\ROOT\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1.ies';
ies = IESFile(filePathName);


 
Width = 30; % meters
Length = 30; % meters
gridSpacing = .5; % meters

rows = (gridSpacing-(gridSpacing/2):gridSpacing:Width-(gridSpacing/2))';
columns = (gridSpacing-(gridSpacing/2):gridSpacing:Length-(gridSpacing/2));
figure(4)
L1 = line([0,Length,Length,0,0],[0,0,Width,Width,0]);
set(L1,'Color','k','LineWidth',2)
grid on
axis equal

if (useGInput==1)
    [y,x] = ginput();
    xFixtureLocations = x; %[3];
    yFixtureLocations = y; %[3];
else
    xFixtureLocations = [.25*Width, .25*Width, .25*Width, .5*Width, .5*Width, .5*Width, .75*Width, .75*Width, .75*Width ];
    yFixtureLocations = [.25*Length, .5*Length, .75*Length, .25*Length, .5*Length, .75*Length,.25*Length, .5*Length, .75*Length];
    
%     xFixtureLocations = Width/2;
%     yFixtureLocations = Length/2;
end

%orientation = zeros(size(x));
orientation = fixtureOrientation*pi/180*ones(size(xFixtureLocations));
%orientation(1) = [90]*pi/180;

h = 5.0; % mounting height, meters

Irr = zeros(length(rows),length(columns));
for i1 = 1:length(rows)
    for i2 = 1:length(columns)
        Irr(i1,i2) = 0;
        for i3 = 1:length(xFixtureLocations)
            x = rows(i1)-xFixtureLocations(i3);
            y = columns(i2)-yFixtureLocations(i3);
            r = sqrt(x^2 + y^2);
            thetaPt = atan(r/h);
            if x==0
                phiPt = 0;
            else
                phiPt = atan2(y,x);
            end
            %{
            if isnan(phiPt)
                phiPt = 0;
                disp('phiPt NAN')
            end
            if isnan(thetaPt)
                thetaPt = pi/2;
                disp('thetaPt NAN')
            end
            %}
            phiPt = phiPt+pi + orientation(i3);
            phiPt = mod(phiPt,2*pi)-pi;
            dsq = r^2+h^2;
            Ipt = interp2(ies.HorizAngles-180,ies.VertAngles,ies.photoTable,phiPt*180/pi,thetaPt*180/pi,'*nearest',0.); % zero-180 plane is along fixture
            Irr(i1,i2) = Irr(i1,i2) + Ipt*cos(thetaPt)/dsq;
        end
    end
end

figure(4)
hold on
[CS,H] = contour(columns,rows,Irr,5);
hold on
plot(yFixtureLocations,xFixtureLocations,'ks','LineWidth',2)
hold off
clabel(CS, H)
axis equal
xlabel('Distance (meters)')
ylabel('Distance (meters)')
title('Greenhouse UVB Irradiance, W/m^2, 22Jul2016, fixtures perpendicular to benches')
