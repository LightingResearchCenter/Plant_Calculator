useGInput = 1; % set to 1 to use mouse to locate fixture locations
fixtureOrientation = 0; % specify fixture orientation in degrees

%if(ishandle(2))
%    close(2)
%end
filePathName = '\\ROOT\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1.ies';
[I,thetas,phis] = readIES_FileFunction(filePathName);
%nadirLux = 61.0; % Illuminance in lux at nadir, 22.2, 61.0
nadirIrrad = 0.38; %1.52; % irradiance in W/m^2
%Distance = 2.946; % Distance in meters
Distance = 2.0; % Distance in meters
I = I/I(1,1)*nadirIrrad*Distance^2; % calibrate intensity in cd 
I = [I,I(:,1)];
phis = [phis;360];

Width = 5.33; % meters
Length = 6.63; % meters
gridSpacing = 0.25; % meters

rows = (gridSpacing:gridSpacing:Width)';
columns = (gridSpacing:gridSpacing:Length);
figure(4)
L1 = line([0,Length,Length,0,0],[0,0,Width,Width,0]);
set(L1,'Color','k','LineWidth',2)
L2 = line([0.3,6.3,6.3,0.3,0.3],[0,0,1,1,0]); % side1 bench
set(L2,'Color','k','LineWidth',2)
L3 = line([0.3,6.3,6.3,0.3,0.3],[4.33,4.33,5.33,5.33,4.33]); % side2 bench
set(L3,'Color','k','LineWidth',2)
L4 = line([1.17,5.44,5.44,1.17,1.17],[1.75,1.75,3.58,3.58,1.75]); % center bench
set(L4,'Color','k','LineWidth',2)
grid on
axis equal

if (useGInput==1)
    [y,x] = ginput()
    xFixtureLocations = x; %[3];
    yFixtureLocations = y; %[3];
    yFixtureLocations = [0.2838, 1.9981, 3.4942, 4.9904, 6.3151, 5.4267, 3.5254, 1.1877, 0.2838, 1.9981, 3.5098, 5.0215, 6.3151]';
    xFixtureLocations = [0.4909, 0.5221, 0.5065, 0.4909, 0.5065, 2.7663, 2.7663, 2.7507, 4.8547, 4.8079, 4.7456, 4.7767, 4.8079]';
else
    xFixtureLocationsCenter = [2.65,2.65,2.65,2.65,2.65];
    yFixtureLocationsCenter = [1.65,2.45,3.31,4.10,5.0];
    xFixtureLocationsSide1 = [0.5,0.5,0.5,0.5,0.5];
    yFixtureLocationsSide1 = [0.5,2.0,3.31,4.6,6];
    xFixtureLocationsSide2 = [4.80,4.80,4.80,4.80,4.80];
    yFixtureLocationsSide2 = [0.5,2.0,3.31,4.6,6];

    xFixtureLocations = [xFixtureLocationsCenter,xFixtureLocationsSide1,xFixtureLocationsSide2];
    yFixtureLocations = [yFixtureLocationsCenter,yFixtureLocationsSide1,yFixtureLocationsSide2];
end

%orientation = zeros(size(x));
orientation = fixtureOrientation*pi/180*ones(size(xFixtureLocations));
%orientation(1) = [90]*pi/180;

h = 2.0; % mounting height, meters

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
            Ipt = interp2(phis-180,thetas,I,phiPt*180/pi,thetaPt*180/pi,'*nearest',0.); % zero-180 plane is along fixture
            Irr(i1,i2) = Irr(i1,i2) + Ipt*cos(thetaPt)/dsq;
        end
    end
end

figure(4)
hold on
[CS,H] = contour(columns,rows,Irr,10);
hold on
plot(yFixtureLocations,xFixtureLocations,'ks','LineWidth',2)
hold off
clabel(CS, H)
axis equal
xlabel('Distance (meters)')
ylabel('Distance (meters)')
title('Greenhouse UVB Irradiance, W/m^2, 22Jul2016, fixtures perpendicular to benches')
