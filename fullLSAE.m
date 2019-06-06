function [IrrOut,outTable,LSAE,IrrArr] = fullLSAE(SPD,IES,mountHeight,range, Uniformity,RoomLength, RoomWidth,calcSpace,LLF)
%%  Test Files Exist
% file=java.io.File(SPD);
% assert(file.exists(),'SPD File does not exist');
hei = size(IES,1);
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
% SPDdata = load(SPD);
wave = SPD(:,1);
specFlux = SPD(:,2);
switch hei
    case 1
        IESdata = IESFile(IES(1,:));
    otherwise
        error('Wrong number of IES files');
end
%% Calculate LSAE
IrrOut =cell(length(mountHeight),length(range));
IrrArr=cell(length(mountHeight),length(range));
outTable = [];
itt = 0;
ittMax = length(mountHeight)*length(range);
LSAE = zeros(length(mountHeight),length(range));
% h = waitbar(itt/ittMax,sprintf('Calculating LSAE step %d out of %d', itt,ittMax));
for i1= 1:length(mountHeight)
    for i2 = 1:length(range)
        itt = itt+1;
%         try
%             if ishandle(h)
%                 h = waitbar(itt/ittMax,h,sprintf('Calculating LSAE step %d out of %d', itt,ittMax));
%             end
%         catch err
%             error('No waitbar available.');
%         end
        [Irr,historyTable] = LSAEReport(wave, specFlux, IESdata, LLF,range(i2), Uniformity ,mountHeight(i1),RoomLength, RoomWidth,calcSpace);
        IrrOut{i1,i2} = sort(Irr(:));
        IrrArr{i1,i2} = Irr;
        targetMin = range(i2)*Uniformity;
        compliantIrr = IrrOut{i1,i2}(IrrOut{i1,i2} >= targetMin);
        compliantPPF = compliantIrr* (calcSpace^2);
        PPF = sum(compliantPPF);
        coveragePercent = numel(compliantPPF)/numel(IrrOut{i1,i2});
        LSAE(i1,i2) = (PPF/(length(historyTable.count{:})*IESdata.InputWatts))*coveragePercent;
        historyTable.LSAE = LSAE(i1,i2);
        outTable = [outTable;historyTable];
        
    end
end
% if ishandle(h)
%     delete(h);
% end
end