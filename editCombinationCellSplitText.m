%% Function Description
%
% This function takes a standard PBS combination cell and splits each entry into components based on the splitText and
% index
%
%% Inputs
%
% * combinationCell: Standard PBS combination cell
% * splitText: The text used to split each string. Note if the string could be split with multiple characters, the
% splitText variable must be passed through as a cell array of strings in the form splitText = {'text 1', 'text 2',...}
% * index: The index of the portion of split string to return
%
%% Outputs
%
% * modifiedCombinationCell: Combination cell with the entries modified according to splitText and index
%
%% Change Log
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function modifiedCombinationCell = editCombinationCellSplitText(combinationCell, splitText, index)

nUnits = length(combinationCell);

for iUnit = 1 : nUnits
    % Loop through each axle
    nAxles = length(combinationCell{iUnit});
    for iAxle = 1 : nAxles
        datasetName = combinationCell{iUnit}{iAxle};
        breakdownOfDatasetName = split(datasetName, splitText);
        indexedSplitText = breakdownOfDatasetName(index);
        modifiedCombinationCell{iUnit}{iAxle} = indexedSplitText{:};
    end
end

end
