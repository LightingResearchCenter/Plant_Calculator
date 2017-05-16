function [IrrOut,outTable,LSAE] = fullLSAE(SPD,IES,mountHeight,range, Uniformity,RoomLength, RoomWidth)
IrrOut =cell(length(mountHeight),length(range));
outTable = [];
%%  Test Files Exist
file=java.io.File(SPD);
assert(file.exists(),'SPD File does not exist');
[hei,wid] = size(IES);
switch hei
    case 1
        file=java.io.File(IES);
        assert(file.exists(),'IES File does not exist');
        %     case 3
        %         file=java.io.File(IES);
        %         assert(file.exists(),'IES File does not exist');
    otherwise
        error('Wrong number of IES files');
end
%% Load files
SPDdata = load(SPD);
wave = SPDdata(:,1);
specFlux = SPDdata(:,2);
switch hei
    case 1
        IESdata = IESFile(IES(1,:));
    otherwise
        error('Wrong number of IES files');
end
%% Calculate LSAE
IrrOut =cell(length(mountHeight),length(range));
outTable = [];
for i1= 1:length(mountHeight)
    for i2 = 1:length(range)
        [Irr,historyTable] = LSAEReport(wave, specFlux, IESdata, range(i2), Uniformity ,mountHeight(i1),RoomLength, RoomWidth);
        IrrOut{i1,i2} = sort(Irr(:));
        outTable = [outTable;historyTable];
        targetMin = range(i2)/Uniformity;
        compliantIrr = IrrOut{i1,i2}(IrrOut{i1,i2} >=targetMin);
        runAvg = zeros(1,length(compliantIrr));
        compliantPPF = zeros(1,length(compliantIrr));
        for i3 = 1:length(compliantIrr)
            runAvg(i3) = mean(compliantIrr(1:i3));
            compliantPPF(i3) = compliantIrr(i3)* (0.5*0.5);
            if max(runAvg)>=range(i2)
               runAvg(i3) = 0;
               compliantPPF(i3) = 0;
               break
            end
        end
        PPF = sum(compliantPPF);
        LSAE(i1,i2) = PPF/((historyTable.LRcount *historyTable.TBcount)*IESdata.InputWatts);
    end
end

end