function [IrrOut,outTable] = fullLSAE(SPD,IES,mountHeight,range, Uniformity,RoomLength, RoomWidth)
IrrOut =cell(length(mountHeight),length(range));
outTable = [];
for i1= 1:length(mountHeight)
    for i2 = 1:length(range)
        [Irr,historyTable] = LSAEReport(SPD, IES, range(i2), Uniformity ,mountHeight(i1),RoomLength, RoomWidth);
        IrrOut{i1,i2} = Irr;
        outTable = [outTable;historyTable];
    end
end
end