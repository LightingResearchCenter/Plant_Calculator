LRcount = 3;
TBcount = 4;
Width = 10;
Length = 10;


% testxFixtureLocations = [];
% testyFixtureLocations = [];

b = ones(LRcount,TBcount);
testx = (((1:LRcount)*(1/(LRcount)*Width))-(0.5*(1/(LRcount)*Width)));
testy = (((1:TBcount)*(1/(TBcount)*Length))-(0.5*(1/(TBcount)*Length)));
testxFixtureLocations = times( b ,testx');
testyFixtureLocations = times( b ,testy);

testxFixtureLocations = reshape(testxFixtureLocations',1,numel(testxFixtureLocations));
testyFixtureLocations = reshape(testyFixtureLocations',1,numel(testyFixtureLocations));

% for i1 = 1:LRcount
%     for i2 = 1:TBcount
%         testxFixtureLocations = [testxFixtureLocations,(i1/(LRcount)*Width) - (0.5*(1/(LRcount))*Width)];
%         testyFixtureLocations = [testyFixtureLocations,(i2/(TBcount)*Length) - (0.5*(1/(TBcount))*Length)];
%     end
% end
load('Results.mat')
assert(isequal(testxFixtureLocations,xFixtureLocations));
assert(isequal(testyFixtureLocations,yFixtureLocations))
