%% Function Description
% 
% This function extracts all the required data for the hitch. It also includes checks to ensure that the correct
% parameters have been entered into TruckSim
% 
%% Inputs
% 
% * endParFileData: End par file extracted to a cell array of strings
% * allParFileData: _all par file extracted to a cell array of strings
% 
%% Outputs
% 
% * hitchXPositionArray: Array of hitch longitudinal positions
% * hitchZPositionArray: Array of hitch heights
% * hitchDatasetArray: Array of hitch model descriptions
% * rollCoupledArray: Array of roll coupling (0 - false, 1 - true)
% * loadCoupledArray: Array of load coupling (as of 0.1.0 it is hard coded as true for all hitches)
% 
%% Change Log
%
% Future releases
%
% * TODO: Add functionality to determine the loadCoupled array. At the moment, everything has been roll-coupled and it
% should only be non-load coupled when a dolly comes into play. Currently the array is hardcoded to be loadCoupled in
% all cases
%
% [0.2.0] - 2017-05-01
% 
% Fixed
%
% * Changed to a structure variable output to neaten code
%
% [0.1.0] - 2017-01-25
% 
% Added
% 
% * First code

function [Hitch] = getHitchData(endParFileData, allParFileData)
                                            
Hitch.XPositionArray = getVariableValuesFromPar(endParFileData, '\<LX_H');

Hitch.RollMomentArray = getDatasetNameFromPar(allParFileData, 'LOG_ENTRY Used Dataset: Hitch: Roll Moment', '; ');

nHitches = length(Hitch.XPositionArray);

if nHitches == 1
    Hitch.ZPositionArray = getVariableValuesFromPar(endParFileData, '\<H_H\s');
else
    Hitch.ZPositionArray = getVariableValuesFromPar(endParFileData, '\<H_H\(');
end

hitchZPositionArrayCheck = getVariableValuesFromPar(endParFileData, '\<H_H_FRONT');

% Checks that the correct hitch position has been entered in TruckSim for the trailing unit sprung mass
if Hitch.ZPositionArray ~= hitchZPositionArrayCheck
    error('%s','Manual Error: The hitch position in the sprung mass of the trailing unit is incorrect');
end

Hitch.DatasetArray = getDatasetNameFromPar(allParFileData, 'LOG_ENTRY Used Dataset: Hitch: Joint Assembly', '; ');

% Determining the number of hitches
nHitches = length(Hitch.DatasetArray);

% Determining whether the hitches are rollCoupled
Hitch.RollCoupledArray = ones(nHitches);

% Hitches are hardcoded to be load coupled for now 
% TODO: Code function to determine if load coupled or not (depending on presence of a dolly)
Hitch.LoadCoupledArray = ones(nHitches);

% Loop through each hitch. If the roll stiffness model is 'zero Roll Stiffness', then a pintle hitch is being used to
% connect the units and no roll is transferred between the units
for iHitch = 1 : nHitches
%
% * TODO: Determine whether the below code functions when a pintle hitch is being used.
%
    if strcmp(Hitch.DatasetArray{iHitch},'Zero Roll Stiffness')
        Hitch.RollCoupledArray(iHitch) = 0;
    end
end