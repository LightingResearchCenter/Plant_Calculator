function [outputArg1,outputArg2] = calcPPF( SPD )
%CALCPPF Summary of this function goes here
%   Detailed explanation goes here
h = 6.63e-34; % Joule seconds, Planck's constant
c = 3.00e8; % meter/second
Avo = 6.02e23; % Avogardo constant
wave = SPD(:,1);
specFlux = SPD(:,2);
multiplier = max(specFlux);
if multiplier == 1
    qstring = 'This SPD is already relative. Is there a known multiplier?';
    title = 'Multiplier?';
    str1 = 'Yes';
    str2 = 'No';
    default = str1;
    button = questdlg(qstring,title,str1,str2,default);
    switch button
        case str1
            prompt = {'Spectrum Multiplier:'};
            dlg_title = 'Multiplier';
            num_lines = 1;
            defaultans = {'.1687'};
            multip = inputdlg(prompt,dlg_title,num_lines,defaultans);
            multiplier = str2double(multip{1});
        case str2
            multiplier = max(specFlux);
        otherwise
            error('There was an error entering the multiplier.');
    end
end

specFluxRelative = specFlux/multiplier;
q1 = find(wave>=400,1,'first');
q2 = find(wave<=700,1,'last');

PPF = 1e6*trapz(wave(q1:q2),specFlux(q1:q2).*...
    (wave(q1:q2)*1e-9)/(h*c*Avo)); % micromoles/s
end

