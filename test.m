spd = '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\Trial2\SPD\LED109053109053SPD.txt';
IES = ['\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies';...
    '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies';...
    '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\LED109053Trial1-repaired.ies'];
SPDdata = load(spd);
wave = SPDdata(:,1);
specFlux = SPDdata(:,2);
    IESdata =cell(3,1);
    IESdata{1} = IESFile(IES(1,:));   % Red Color data
    IESdata{2} = IESFile(IES(2,:));   % Green Color data
    IESdata{3} = IESFile(IES(3,:));   % Blue Color data


% preconditions

%% Test 1: 1 IES File
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata(1),'LRcount',1,'TBcount',1);
assert(all(size(Irr)==[60,60]));
assert(all(size(Irr)==[60,60]));
assert(abs(Avg-6.0009) <= (0.01*6.0009))
assert(abs(Max-1034) <= (0.01*1034 ))
assert(abs(Min-0.0006) <= (0.01))
%% Test 2: Color IES Files
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',1,'TBcount',1);
assert(all(size(Irr)==[60,60,3]));

%% Test 3: 25 fixtures 1 IES File
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata(1),'LRcount',5,'TBcount',5);
assert(all(size(Irr)==[60,60]));

%% Test 4: 25 fixtures 3 IES File
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',5,'TBcount',5);
assert(all(size(Irr)==[60,60,3]));

%% Test 5: 9 fixtures 1 IES File
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata(1),'LRcount',3,'TBcount',3);
assert(all(size(Irr)==[60,60]));
assert(abs(Avg-53.7665) <= (0.01*53.7665))
assert(abs(Max-1036) <= (0.01*1036))
assert(abs(Min-0.0867 ) <= (0.01))

%% Test 6: 9 fixtures 3 IES File
[Irr,Avg,Max,Min] = PPFCalculator(wave,specFlux,IESdata,'LRcount',3,'TBcount',3);
assert(all(size(Irr)==[60,60,3]));
