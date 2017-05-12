function [Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata, varargin)
% PPFCALCULATOR calculates the ppf eff. of a fixture in a Length x Width space.

%% Input Checking
p = inputParser;
p.FunctionName = 'PPFCalculator';
defaultLength =10;  %in Meters
defaultWidth = 10;  %in Meters
defaultMountHeight = 1.5;   %in Meters
defaultCount = 3; % how many fixtures inboth rows and collums (specifiable sepratly)
defaultSpacing = .5; %in Meters
defaultOrientation = 0; %in Degrees
defaultMultiplier = 1;
addRequired(p,'wave',@isnumeric);
addRequired(p,'specFlux',@isnumeric);
addRequired(p,'IESdata',@(x) validateattributes(x,{'IESFile'},{'nonempty'}));
addParameter(p,'Length', defaultLength,@isnumeric)
addParameter(p,'Multiplier', defaultMultiplier,@isnumeric)
addParameter(p,'LRcount', defaultCount,@(x)validateattributes(x,{'numeric'},{'nonempty','integer','positive'}))
addParameter(p,'TBcount', defaultCount,@isnumeric)
addParameter(p,'calcSpacing', defaultSpacing,@isnumeric);
addParameter(p,'Width', defaultWidth,@isnumeric)
addParameter(p,'MountHeight',defaultMountHeight,@isnumeric);
addParameter(p,'fixtureOrientation',defaultOrientation, @isnumeric);

parse(p,wave,specFlux,IESdata, varargin{:});

% Check that files are vaild
%% generate Calculation objects
rows = (p.Results.calcSpacing-(p.Results.calcSpacing/2):p.Results.calcSpacing:p.Results.Width-(p.Results.calcSpacing/2))';
columns = (p.Results.calcSpacing-(p.Results.calcSpacing/2):p.Results.calcSpacing:p.Results.Length-(p.Results.calcSpacing/2));
xFixtureLocations = [];
yFixtureLocations = [];
for i1 = 1:p.Results.LRcount
    for i2 = 1:p.Results.TBcount
        xFixtureLocations = [xFixtureLocations,(i1/(p.Results.LRcount)*p.Results.Width) - (0.5*(1/(p.Results.LRcount))*p.Results.Width)];
        yFixtureLocations = [yFixtureLocations,(i2/(p.Results.TBcount)*p.Results.Length) - (0.5*(1/(p.Results.TBcount))*p.Results.Length)];
    end
end
orientation = p.Results.fixtureOrientation*pi/180*ones(size(xFixtureLocations));

Irr = zeros(length(rows),length(columns),length(xFixtureLocations));
for i1 = 1:length(rows)
    for i2 = 1:length(columns)
        parfor i3 = 1:length(xFixtureLocations)
            x = rows(i1)-xFixtureLocations(i3);
            y = columns(i2)-yFixtureLocations(i3);
            r = sqrt(x^2 + y^2);
            thetaPt = atan(r/p.Results.MountHeight);
            if x==0
                phiPt = 0;
            else
                phiPt = atan2(y,x);
            end
            phiPt = phiPt+pi + orientation(i3);
            phiPt = mod(phiPt,2*pi)-pi;
            dsq = r^2+(p.Results.MountHeight)^2;
            Ipt = interp2(p.Results.IESdata.HorizAngles-180,p.Results.IESdata.VertAngles,p.Results.IESdata.photoTable,phiPt*180/pi,thetaPt*180/pi,'*nearest',0.); 
            Irr(i1,i2,i3) = round((Ipt*cos(thetaPt)/dsq)*(p.Results.Multiplier/1000),3);
        end
    end
end
Irr = sum(Irr,3);
Avg = mean2(Irr);
Max = max(max(Irr));
Min = min(min(Irr));
end