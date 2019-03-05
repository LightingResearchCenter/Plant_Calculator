function [Irr,Avg,Max,Min] = PPFCalculator(IESdata, varargin)
% PPFCALCULATOR calculates the ppf eff. of a fixture in a Length x Width space.

%% Input Checking
p = inputParser;
p.FunctionName = 'PPFCalculator';
defaultLength =10;  %in Meters
defaultWidth = 10;  %in Meters
defaultMountHeight = 1.5;   %in Meters
defaultCenter = [1,1]; % how many fixtures in both rows and collums (specifiable separately)
defaultSpacing = .25; %in Meters
defaultOrientation = 90; %in Degrees
defaultMultiplier = 1;
defaultColor = 0;
defaultLLF = 1;
addRequired(p,'IESdata',@(x) validateattributes(x,{'IESFile'},{'nonempty'}));
addParameter(p,'Length', defaultLength,@isnumeric)
addParameter(p,'Multiplier', defaultMultiplier,@isnumeric)
addParameter(p,'LLF', defaultLLF,@isnumeric)
addParameter(p,'Centers', defaultCenter)
addParameter(p,'calcSpacing', defaultSpacing,@isnumeric);
addParameter(p,'Width', defaultWidth,@isnumeric)
addParameter(p,'MountHeight',defaultMountHeight,@isnumeric);
addParameter(p,'fixtureOrientation',defaultOrientation, @isnumeric);
addParameter(p,'Color', defaultColor,@isnumeric)
parse(p,IESdata, varargin{:});

%% generate Calculation objects
rowStart = (p.Results.Width-(p.Results.calcSpacing*floor(p.Results.Width/p.Results.calcSpacing)))/2;
colStart = (p.Results.Length-(p.Results.calcSpacing*floor(p.Results.Length/p.Results.calcSpacing)))/2;
rows = (rowStart:p.Results.calcSpacing:p.Results.Width)';
columns = (colStart:p.Results.calcSpacing:p.Results.Length);

xFixtureLocations = p.Results.Centers(:,1);
yFixtureLocations = p.Results.Centers(:,2);

xFixtureLocations = reshape(xFixtureLocations',1,numel(xFixtureLocations));
yFixtureLocations = reshape(yFixtureLocations',1,numel(yFixtureLocations));
if p.Results.Color == 0
    [newXFixtureLocations,newYFixtureLocations,newIES] = descritizeFixture(xFixtureLocations,yFixtureLocations,p.Results.IESdata,p.Results.MountHeight);
else
    newXFixtureLocations = xFixtureLocations;
    newYFixtureLocations = yFixtureLocations;
    newIES = p.Results.IESdata;
end
orientation = (p.Results.fixtureOrientation)*pi/180*ones(size(newXFixtureLocations));

rows = rows(:);
columns = columns(:);

nMetersRows   = numel(rows);
nMetersColumns  = numel(columns);
nFixtures = numel(newXFixtureLocations);

A = ones(nMetersRows, nMetersColumns, nFixtures);
rows3   = gpuArray(bsxfun(@times, A, rows));
cols3   = gpuArray(bsxfun(@times, A, columns'));

xFix3   = gpuArray(bsxfun(@times, A, permute(newXFixtureLocations, [3 1 2])));
yFix3   = gpuArray(bsxfun(@times, A, permute(newYFixtureLocations, [3 1 2])));
orient3 = gpuArray(bsxfun(@times, A, permute(orientation, [3 1 2])));

x = rows3 - xFix3;
y = cols3 - yFix3;

r = sqrt(x.^2 + y.^2);

phiPt = atan2(y, x);
phiPtall = (mod(phiPt + pi + orient3, 2*pi))*(180/pi);
dsqall = r.^2 + (p.Results.MountHeight)^2;
thetaPtall = atand(r/p.Results.MountHeight);

Ipt = interp2(newIES.HorizAngles, newIES.VertAngles,newIES.photoTable,  ...
    phiPtall, thetaPtall,'linear');
Irr = ((Ipt.*p.Results.LLF.*(p.Results.Multiplier./1000)).*cosd(thetaPtall)./dsqall);
Irr = gather(sum(Irr,3)');
Avg = gather(mean2(Irr));
Max = max(max(Irr));
Min = min(min(Irr));
end