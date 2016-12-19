% Calculate PAR (Photosynthetic Active Radiation)

% fileList {path and file name, input power (watts)}
%{
fileList = {'C:\AndyNewStuff\PlantLighting\NRCANTesting\HPS109056\Trial1\SPD\HPS109056109056',729.7;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\LED109053\trial1\SPD\LED109053LED109053',298.0;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\LED109054\trial1\SPD\LED109054LED109054',288.2;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\LED109055\trial1\SPD\LED109055LED109055',290.7;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\LED109057\Trial1\SPD\LED109057109057',372.8;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\LED109450\Trial1\SPD\LED109450109450',276.6;...
    'C:\AndyNewStuff\PlantLighting\NRCANTesting\HPS\Trial1\SPD\HPSHPS1',645.7};
%}
 
% fileList = {'\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109053\Trial2\SPD\LED109053109053SPD.txt',297.7;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109054\Trial2\SPD\LED109054109054SPD.txt',288.4;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109055\Trial2\SPD\LED109055109055SPD.txt',290.8;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109057\Trial2\SPD\LED109057109057SPD.txt',371.6;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\LED109450\Trial2\SPD\LED109450109450SPD.txt',276.4;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\HPS109056\Trial2\SPD\HPS109056109056SPD.txt',690.2;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\HPS\Trial1\SPD\HPSHPS1',645.7;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\HPS100WJeremySpreadsheet.txt',127.1;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\MHJeremySpreadsheet.txt',194.8;...
%     '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\Icetron100WJeremySpreadsheet.txt',109.0};


% fileList = {'C:\Users\radetl\Documents\HLP\WarmWhiteRebelM0.txt',1.77;...
%     'C:\Users\radetl\Documents\HLP\Blue1.txt',4.72;...
%     'C:\Users\radetl\Documents\HLP\Red4AndBlue1.txt',6.89;...
%     'C:\Users\radetl\Documents\HLP\Red4.txt',2.17;...
%     'C:\Users\radetl\Documents\HLP\CoolWhite_UN.txt',1.77};
fileList = {'F:\Cool LED average.txt',0.065*2.9;...
    'F:\Warm LED average.txt',0.065*2.9};
%Names = {'LED 53';'LED 54';'LED 55';'LED 57';'LED 50';'HPS 56';'HPS 1';'JeremyHPS';'JeremyMH';'JeremyInduction'};
%Names = {'Warm White XH-G LED';'XPE Blue';'XPE Red and Blue';'XPE Red';'CoolWhite UN'};
Names = {'Cool White Nichia LED';'Warm White Nichia LED'};
McCreeFromGraph = load('McCree1972.txt');
h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant

for loop = 1:length(fileList)
    spd = load(fileList{loop,1});
    elecPower = fileList{loop,2};
    wave = spd(:,1);
    specFlux = spd(:,2);
    if strcmp(Names{loop},'HPS 1')
        specFlux = specFlux*79442/Lxy23Sep05(spd); % SPD does not have SAF corection, so apply it here non-spectrally
    end
    McCreePhoton = interp1(McCreeFromGraph(:,1),McCreeFromGraph(:,2),wave,'linear',0.0);
    McCreeWatt = McCreePhoton.*((wave*1e-9)/(h*c*Avo)); % convert growth/photon to growth/joule
    McCreeWatt = McCreeWatt/max(McCreeWatt);
    %{
    figure(10)
    plot(wave,McCreePhoton,'b')
    hold on
    plot(wave,McCreeWatt,'r')
    hold off
    legend('Quantum yield [growth/photon]','Energy yield [growth/joule]')
    pause
    %}
    q1 = find(wave>=400,1,'first');
    q2 = find(wave<=700,1,'last');
    PPF_W(loop) = trapz(wave(q1:q2),specFlux(q1:q2)); % Watts
    PPF_WperW(loop) = PPF_W(loop)/elecPower;
    
    PPF_mole(loop) = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*(wave(q1:q2)*1e-9))/(h*c*Avo); % micromoles/s
    PPF_molePerW(loop) = PPF_mole(loop)/elecPower;
    
    YPF_W(loop) = trapz(wave,specFlux.*McCreeWatt); % Watts
    YPF_WperW(loop) = YPF_W(loop)/elecPower;
    
    YPF_mole(loop) = 1e6*trapz(wave,McCreePhoton.*specFlux.*(wave*1e-9))/(h*c*Avo); % micromoles/s
    YPF_molePerW(loop) = YPF_mole(loop)/elecPower;
    
    [Lux(loop),x(loop),y(loop)] = Lxy23Sep05([wave,specFlux]);
    LPW(loop) = Lux(loop)/elecPower;
    Tc(loop) = CCT23Sep05(spd);
    
    figure(loop)
    h1 = plot(wave,specFlux,'k-','LineWidth',2);
    xlabel('Wavelength (nm)','FontSize',14);
    ylabel('Spectral flux (W/nm)','FontSize',14);
    yLim = get(gca,'YLim');
    yLim(1) = 0;
    set(gca,'YLim',yLim)
    text(650,0.80*yLim(2),['PPF = ',num2str(PPF_W(loop),'%.1f'),' W']);
    text(650,0.75*yLim(2),['PPF eff. = ',num2str(PPF_WperW(loop),'%.3f'),' W per W']);
    text(650,0.70*yLim(2),['PPF = ',num2str(PPF_mole(loop),'%.1f'),' \muMoles/s']);
    text(650,0.65*yLim(2),['PPF eff = ',num2str(PPF_molePerW(loop),'%.3f'),' \muMoles/s per W']);
    text(650,0.60*yLim(2),['YPF = ',num2str(YPF_W(loop),'%.1f'),' W']);
    text(650,0.55*yLim(2),['YPF eff = ',num2str(YPF_WperW(loop),'%.3f'),' W per W']);
    text(650,0.50*yLim(2),['YPF = ',num2str(YPF_mole(loop),'%.1f'),' \muMoles/s']);
    text(650,0.45*yLim(2),['YPF eff = ',num2str(YPF_molePerW(loop),'%.3f'),' \muMoles/s per W']);
    title(Names(loop),'FontSize',14);
end

[spectrumLocus,PlankLocus,isoTempLines] = SpecLocusPlankLocusFun();
figure(loop+1)
plot(spectrumLocus(:,1),spectrumLocus(:,2),'k-')
hold on
plot(PlankLocus(:,1),PlankLocus(:,2),'k-')
h2 = plot(x,y,'bd');
set(h2,'MarkerFaceColor',[0,0,1]);
axis equal
for loop = 1:length(fileList)
    text(x(loop)+0.02,y(loop),Names{loop},'FontSize',10);
end
hold off
set(gca,'FontSize',12)
xlabel('x','FontSize',12);
ylabel('y','FontSize',12);

% Print table of results
fprintf(1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','ID','Input Power','PPF_W','PPF_W per W','PPF_quanta','PPF_quanta per W','YPF_W','YPF_W per W','YPF quanta','YPF_quanta per W','Luminous flux','LPW','CIE x','CIE y')
fprintf(1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','','W','W','','micromoles/s','(micromoles/s)/W','W','','micromoles/s','(micromoles/s)/W','lumen','lm/W','x','y')
for loop = 1:length(fileList)
    fprintf(1,'%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
        Names{loop},fileList{loop,2},PPF_W(loop),PPF_WperW(loop),PPF_mole(loop),PPF_molePerW(loop),...
        YPF_W(loop),YPF_WperW(loop),YPF_mole(loop),YPF_molePerW(loop),Lux(loop),LPW(loop),x(loop),y(loop));
end


