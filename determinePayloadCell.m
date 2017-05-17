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
         determinePayloadCell(endParFileData, allParFileData, nUnits)
%% Extract descriptions of each payload for each unit
%
% * It is important to note that this only works due to the fact that the payloads and payload descriptions appear in 
% the par files in order of appearance. If this is not the case then the behaviour of this code will not correctly 
% assign payload names to the correct vehicle unit and mass value
%
% Extracting a list of names in order of appearance
payloadDescriptionArray = getDatasetNameFromPar(allParFileData, 'LOG_ENTRY Used Dataset: Payload', '} ');

%Initialise to the first payload description
iPayloadNum = 1;

for iUnit = 1:nUnits
%% Retrive payload mass data
    % Retrieve the payload mass values
    payloadMassArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<M_PL(', iUnit));

    payloadCoGxPositionArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<LX_CG_PL(', iUnit));
    payloadCoGyPositionArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<Y_CG_PL(', iUnit));
    payloadCoGzPositionArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<H_CG_PL(', iUnit));
    
    payloadMOIxArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<IXX_PL(', iUnit));
    payloadMOIyArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<IYY_PL(', iUnit));
    payloadMOIzArray = getVariableValuesFromPar(endParFileData, sprintf('%s%i', '\<IZZ_PL(', iUnit));
    
    % * Attempt to initialise cells in the future, shouldn't make a huge difference since cell arrays are small.
    % * I have used payloadMassArray as the logic operator as in some cases, the CoGx, CoGy, CoGz may be 0. Whereas a 0
    % mass means there is definitely no payload
    Payload.MassCell{:,iUnit} = payloadMassArray(payloadMassArray ~= 0);
    Payload.CoGxPositionCell{:,iUnit} = payloadCoGxPositionArray(payloadMassArray ~= 0);
    Payload.CoGyPositionCell{:,iUnit} = payloadCoGyPositionArray(payloadMassArray ~= 0);
    Payload.CoGzPositionCell{:,iUnit} = payloadCoGzPositionArray(payloadMassArray ~= 0);
    Payload.MOIxCell{:,iUnit} = payloadMOIxArray(payloadMassArray ~= 0);
    Payload.MOIyCell{:,iUnit} = payloadMOIyArray(payloadMassArray ~= 0);
    Payload.MOIzCell{:,iUnit} = payloadMOIzArray(payloadMassArray ~= 0);

%% Retrieve payload description data 
% * It is important to note that this only works due to the fact that the payloads and payload descriptions appear in 
% the par files in order of appearance. If this is not the case then the behaviour of this code will not correctly 
% assign payload names to the correct vehicle unit and mass value

    %Initialise the payload description cell for the unit
    Payload.DescriptionCell{iUnit} = {};
    
    % Determine the number of payloads for that unit
    nUnitPayloads = length(Payload.MassCell{iUnit});
    
    if nUnitPayloads
        for iPayload = 1:nUnitPayloads
            Payload.DescriptionCell{iUnit} = [Payload.DescriptionCell{iUnit} payloadDescriptionArray{iPayloadNum}];
            % Move on to the next payload
            iPayloadNum = iPayloadNum + 1;
        end    
    end
end

end