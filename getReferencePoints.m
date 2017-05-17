%% Function Description
% 
% This function extracts the X, Y and Z reference points for each unit in the combination
% 
%% Inputs
% 
% * endParFileData: End par file extracted to a cell array of strings
% * nUnits: Number of vehicle units
% 
%% Outputs
% 
% * referencePointsCell: A cell containing the reference points for each vehicle unit in the form:
%   {[unit 1 X] [unit 1 Y] [unit 1 Z]; [unit 2 X] [unit 2 Y] [unit 2 Z]} where [unit n X/Y/Z] is a column vector
% 
%% Change Log
%
% [0.1.0] - 2017-04-29
% 
% Added
% 
% * First code

function [referencePointsCell] = getReferencePoints(endParFileData, nUnits)

for iUnit = 1 : nUnits
    referencePointsCell{iUnit,1} = getVariableValuesFromPar(endParFileData, strcat('\<X_RP(', num2str(iUnit)))';
    referencePointsCell{iUnit,2} = getVariableValuesFromPar(endParFileData, strcat('\<Y_RP(', num2str(iUnit)))';
    referencePointsCell{iUnit,3} = getVariableValuesFromPar(endParFileData, strcat('\<H_RP(', num2str(iUnit)))';
end

end