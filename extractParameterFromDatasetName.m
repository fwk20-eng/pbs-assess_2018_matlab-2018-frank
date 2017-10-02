%% Function Description
%
% This function extracts a dataset type from a TruckSim database name. The dataset type must be typed between a set of
% square parenthesis in order to be extracted.
%
%% Inputs
%
% * datasetTypeCellArray: a standard combination cell array containing dataset names for a certain axle parameter
%
%% Outputs
%
% * datasetTypeCellArray: the data type for each axle dataset is extracted into this array. e.g it will determine the
% spring type from the spring dataset name
%
%% Change Log
%
% [0.2.0] 2017-06-04
%
% *Added*
%
% * Ability to pass through start and end keys
%
% [0.1.0] - 2017-05-07
%
% *Added*
%
% * First code

function datasetTypeCellArray = extractParameterFromDatasetName(combinationDatasetTable, startKey, endKey)

nUnits = length(combinationDatasetTable);

% Loop through each unit
for iUnit = 1 : nUnits
    % Loop through each axle
    nAxles = length(combinationDatasetTable{iUnit});
    for iAxle = 1 : nAxles
        axleDatasetModelAndType = combinationDatasetTable{iUnit}{iAxle};
        % If not start or end key has been entered, use square brackets as default
        if ~exist('startKey')
            axleParameter = regexpFindTextBetweenText(axleDatasetModelAndType, '\[', '\]');
        else
            axleParameter = regexpFindTextBetweenText(axleDatasetModelAndType, startKey, endKey);
        end
        datasetTypeCellArray{iUnit}{iAxle} = axleParameter{:};
    end
end