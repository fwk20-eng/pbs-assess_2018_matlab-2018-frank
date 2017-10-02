%% Function Description
%
% This function will extract the payloads for each combination and store them as per the Wits post processor.
%
%% Inputs
%
% * endParFileData: data extracted from the end par file.
% * nUnits: number of units.
%
%% Outputs
%
% * payloadMassCell: Payload mass of each payload (rows) for each unit (columns).
% * payloadCoGxPositionCell: Payload mass of each payload (rows) for each unit (columns).
% * payloadCoGzPositionCell: Payload mass of each payload (rows) for each unit (columns).
%
%% Change Log
%
% [0.7.0]
%
% * Updated to extract payloads correctly when there is more than 1 payload per unit or when a unit has no payload. This
% was malfunctioning due to issues with the way TruckSim has changed the way it stores the payloads in the par files.
%
% [0.6.0]
%
% * Updated to TruckSim 2017.1 variables
%
%
% [0.5.0] - 2017-05-09
%
% *Added*
%
% * Extracted Moments of Inertia for PBS report purposes
%
% [0.4.0]
%
% Fixed
%
% * Output variables consolidated into a structure
%
% [0.3.0]
%
% Added
%
% * Fixed error causing index exceeded when a unit has no payloads
%
% [0.2.0] - 2017-04-24
% Added
%
% * Functionality to extract the dataset name for each payload
%
% [0.1.0] - 2017-04-20
%
% Added
%
% * First code

function [Payload] =...
    extractPayload(endParFileData, allParFileData, nUnits)
%% Extract descriptions of each payload for each unit
%
% * It is important to note that this only works due to the fact that the payloads and payload descriptions appear in
% the par files in order of appearance. If this is not the case then the behaviour of this code will not correctly
% assign payload names to the correct vehicle unit and mass value
%
% Extracting a list of names in order of appearance
payloadDescriptionArray = getDatasetNameFromPar(allParFileData, 'LOG_ENTRY Used Dataset: Payload', '} ');

% Initialising the payload cells
for iUnit = 1 : nUnits
    Payload.MassCell{iUnit} = [];
    Payload.CoGxPositionCell{iUnit} = [];
    Payload.CoGyPositionCell{iUnit} = [];
    Payload.CoGzPositionCell{iUnit} = [];
    Payload.MOIxCell{iUnit} = [];
    Payload.MOIyCell{iUnit} = [];
    Payload.MOIzCell{iUnit} = [];
    Payload.DescriptionCell{iUnit} = [];
end

%% Retrive payload mass data
% Retrieve the payload mass values
payloadMassArray = getVariableValuesFromPar(endParFileData, '^M_PL');

payloadCoGxPositionArray = getVariableValuesFromPar(endParFileData, '^LX_CG_PL');
payloadCoGyPositionArray = getVariableValuesFromPar(endParFileData, '^Y_CG_PL');
payloadCoGzPositionArray = getVariableValuesFromPar(endParFileData, '^Z_CG_PL');

payloadMOIxArray = getVariableValuesFromPar(endParFileData, '^IXX_PL');
payloadMOIyArray = getVariableValuesFromPar(endParFileData, '^IYY_PL');
payloadMOIzArray = getVariableValuesFromPar(endParFileData, '^IZZ_PL');

% Retrieve the unit number for the location of each payload
payloadSprungMassUnit = getVariableValuesFromPar(endParFileData, '^OPT_PL_BODY_ID');

nPayloads = length(payloadSprungMassUnit);

% Loop through the payloads and assign them to the correct sprung mass units
for iPayload = 1 : nPayloads
    iUnit = payloadSprungMassUnit(iPayload);
    
    Payload.MassCell{iUnit} = [Payload.MassCell{iUnit} payloadMassArray(iPayload)];
    
    Payload.CoGxPositionCell{iUnit} = [Payload.CoGxPositionCell{iUnit} payloadCoGxPositionArray(iPayload)];
    Payload.CoGyPositionCell{iUnit} = [Payload.CoGyPositionCell{iUnit} payloadCoGyPositionArray(iPayload)];
    Payload.CoGzPositionCell{iUnit} = [Payload.CoGzPositionCell{iUnit} payloadCoGzPositionArray(iPayload)];
    
    Payload.MOIxCell{iUnit} = [Payload.MOIxCell{iUnit} payloadMOIxArray(iPayload)];
    Payload.MOIyCell{iUnit} = [Payload.MOIyCell{iUnit} payloadMOIyArray(iPayload)];
    Payload.MOIzCell{iUnit} = [Payload.MOIzCell{iUnit} payloadMOIzArray(iPayload)];
    
    Payload.DescriptionCell{iUnit} = [Payload.DescriptionCell{iUnit} payloadDescriptionArray{iPayload}];
end

end