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
% [1.1.0] - 2017-0-21
%
% *Added*
% Included support for dollys
%
% [1.0.0] - 2017-07-11
%
% * Updated for TruckSim 2017.1
%
% [0.1.0] - 2017-04-29
% 
% Added
% 
% * First code

function [referencePointsCell] = extractReferencePoints(allParFileData, Sprung, Combination)

motionSensorData = spliceAllPar(allParFileData, {'ENTER_PARSFILE Output\Sensors\MoSen', ...
    'EXIT_PARSFILE Output\Sensors\MoSen'});

nPreviousDollyUnits = 0;

for iUnit = 1 : Sprung.numberOffUnits
    
    % Dolly units have reference points of zeros. This is to maintain the numerical integrity of unit and reference points.
    
    if any(iUnit == Combination.dollys)
        nPreviousDollyUnits = nPreviousDollyUnits + 1;
        referencePointsCell{iUnit,1} = zeros(9,1);
        referencePointsCell{iUnit,2} = zeros(9,1);
        referencePointsCell{iUnit,3} = zeros(9,1);
    else
        xSensor = getVariableValuesFromPar(motionSensorData{iUnit - nPreviousDollyUnits}, '\<X_S')';
        ySensor = getVariableValuesFromPar(motionSensorData{iUnit - nPreviousDollyUnits}, '\<Y_S')';
        zSensor = getVariableValuesFromPar(motionSensorData{iUnit - nPreviousDollyUnits}, '\<Z_S')';

        referencePointsCell{iUnit,1} = xSensor(1:9);
        referencePointsCell{iUnit,2} = ySensor(1:9);
        referencePointsCell{iUnit,3} = zSensor(1:9);
    end
    
end

end