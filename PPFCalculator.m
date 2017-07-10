function [Irr,Avg,Max,Min] = PPFCalculator(IESdata, varargin)
% PPFCALCULATOR calculates the ppf eff. of a fixture in a Length x Width space.

%% Input Checking
p = inputParser;
p.FunctionName = 'PPFCalculator';
defaultLength =10;  %in Meters
defaultWidth = 10;  %in Meters
defaultMountHeight = 1.5;   %in Meters
defaultCount = 3; % how many fixtures in both rows and collums (specifiable separately)
defaultSpacing = .125; %in Meters
defaultOrientation = 90; %in Degrees
defaultMultiplier = 1;
defaultColor = 0;
addRequired(p,'IESdata',@(x) validateattributes(x,{'IESFile'},{'nonempty'}));
addParameter(p,'Length', defaultLength,@isnumeric)
addParameter(p,'Multiplier', defaultMultiplier,@isnumeric)
addParameter(p,'LRcount', defaultCount,@(x)validateattributes(x,{'numeric'},{'nonempty','integer','positive'}))
addParameter(p,'TBcount', defaultCount,@(x)validateattributes(x,{'numeric'},{'nonempty','integer','positive'}))
addParameter(p,'calcSpacing', defaultSpacing,@isnumeric);
addParameter(p,'Width', defaultWidth,@isnumeric)
addParameter(p,'MountHeight',defaultMountHeight,@isnumeric);
addParameter(p,'fixtureOrientation',defaultOrientation, @isnumeric);
addParameter(p,'Color', defaultColor,@isnumeric)

parse(p,IESdata, varargin{:});

% Check that files are valid
%% generate Calculation objects
rows = (p.Results.calcSpacing-(p.Results.calcSpacing/2):p.Results.calcSpacing:p.Results.Width-(p.Results.calcSpacing/2))';
columns = (p.Results.calcSpacing-(p.Results.calcSpacing/2):p.Results.calcSpacing:p.Results.Length-(p.Results.calcSpacing/2));
b = ones(p.Results.LRcount,p.Results.TBcount);
deltaX = (((1:p.Results.LRcount)*(1/(p.Results.LRcount)*p.Results.Width))-(0.5*(1/(p.Results.LRcount)*p.Results.Width)));
deltaY = (((1:p.Results.TBcount)*(1/(p.Results.TBcount)*p.Results.Length))-(0.5*(1/(p.Results.TBcount)*p.Results.Length)));
xFixtureLocations = times( b ,deltaX');
yFixtureLocations = times( b ,deltaY);

xFixtureLocations = reshape(xFixtureLocations',1,numel(xFixtureLocations));
yFixtureLocations = reshape(yFixtureLocations',1,numel(yFixtureLocations));
if p.Results.Color == 0 
    [newXFixtureLocations,newYFixtureLocations,newIES] = descritizeFixture(xFixtureLocations,yFixtureLocations,p.Results.IESdata,p.Results.MountHeight);
else
    newXFixtureLocations = xFixtureLocations;
    newYFixtureLocations = yFixtureLocations;
    newIES = p.Results.IESdata;
end
orientation = p.Results.fixtureOrientation*pi/180*ones(size(newXFixtureLocations));

rows = rows(:);
columns = columns(:);

nMeters   = numel(rows);
nFixtures = numel(newXFixtureLocations);

A = ones(nMeters, nMeters, nFixtures);
rows3   = bsxfun(@times, A, rows);
cols3   = bsxfun(@times, A, columns');

xFix3   = bsxfun(@times, A, permute(newXFixtureLocations, [3 1 2]));
yFix3   = bsxfun(@times, A, permute(newYFixtureLocations, [3 1 2]));
orient3 = bsxfun(@times, A, permute(orientation, [3 1 2]));

x = rows3 - xFix3;
y = cols3 - yFix3;

r = sqrt(x.^2 + y.^2);

phiPt = atan2(y, x);
phiPt(x == 0) = 0;
phiPtall = (mod(phiPt + pi + orient3, 2*pi) - pi)*180/pi;
dsqall = r.^2 + (p.Results.MountHeight)^2;
thetaPtall = atan(r/p.Results.MountHeight)*180/pi;
        
Ipt = interp2(newIES.HorizAngles-180, newIES.VertAngles,newIES.photoTable,  ...
            phiPtall, thetaPtall,'linear', 0.); 
Irr = (Ipt.*cosd(thetaPtall)./dsqall).*(p.Results.Multiplier./1000);
Irr = sum(Irr,3);
Avg = mean2(Irr);
Max = max(max(Irr));
Min = min(min(Irr));
end