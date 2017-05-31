function output = generatePlantReport(varargin)
%GENERATEPLANTREPORT Creates and saves a Plant Report for an IES and SPD
%
% Syntax:   [output] = generatePlantReport()
%           [output] = generatePlantReport(IESFileLoc, SPDFileLoc)
%           [output] = generatePlantReport(IESFileLoc, SPDFileLoc,outputLoc)
%
% Inputs:
%    IESFileLoc - 
%    SPDFileLoc - 
%    outputLoc  - 
%
% Outputs:
%    output1 - Description
%    output2 - Description
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: D12PACK.PLANTREPORT,  D12PACK.REPORT, FULLLSAE, IESFILE, 

% Author: Tim Plummer, Lighting Reseach Center, RPI
% 21 Union ST Troy, NY 12180
% email: plummt@rpu.edu
% Website: http://www.lrc.rpi.edu
% May 2017; Last revision: 5-31-2017
%% Input
p = inputParser;
p.FunctionName = 'generatePlantReport';
% Defaults
defaultIESFileLoc = '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\HPS109056\HPS109056_LT_10mil_IntSlic_repaired.ies';
defaultSPDFileLoc =  '\\root\projects\NRCAn\2013 Horticultural Lighting\SphereTesting\HPS109056\Trial2\SPD\HPS109056109056SPD.txt';
defaultOutputLoc  = pwd;
% Parameters
addOptional(p,'IESFileLoc',defaultIESFileLoc,@iscell);
addOptional(p,'SPDFileLoc',defaultSPDFileLoc,@iscell);
addOptional(p,'outputLoc',defaultOutputLoc,@ischar);

% parse inputs
parse(p,varargin{:});
% check if files exist
[~,w]=size(p.Results.IESFileLoc);
[~,w2]=size(p.Results.IESFileLoc);
if w~=w2
   error('There are not the same number of IES files and SPD files') 
end
for i = 1:w
file=java.io.File(p.Results.IESFileLoc{i});
assert(file.exists(),'IES File does not exist');
file=java.io.File(p.Results.SPDFileLoc{i});
assert(file.exists(),'IES File does not exist');
end
file=java.io.File(p.Results.outputLoc);
assert(file.isDirectory(),'Can not write to output location');
%% Create Plant Reports

end