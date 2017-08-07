load('variables.mat');
targetMounts =[1,2:2:16]*unitsratio('m','ft');
targetPPFDs = [minPPFD:stepPPFD:maxPPFD,1000];
targetUni = 0.6;
[Irr,outTable,LSAE,IrrArr] = fullLSAE(Data.spd,Data.ies,targetMounts,targetPPFDs,targetUni,roomLength,roomWidth,calcSpacing,2);
Data.LSAE = LSAE;
Data.outTable = outTable;