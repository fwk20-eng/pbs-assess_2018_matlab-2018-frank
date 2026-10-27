%% Function Description
%
% This function takes a standard PBS combination cell and modified each entry by replacing it with the text between
% a specified start and end key. Note that the start and end text are not included in the extracted text
%
%% Inputs
%
% * combinationCell: Standard PBS combination cell
% * startKey: beginning of text using regular expression notation
% * endKey: end of text using regular expression notation
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

function modifiedCombinationCell = editCombinationCellRegexpBetweenText(combinationCell, startKey, endKey)

nUnits = length(combinationCell);

% Loop through each unit
for iUnit = 1 : nUnits
    nAxles = length(combinationCell{iUnit});
    % Loop through each axle
    for iAxle = 1 : nAxles
        datasetName = combinationCell{iUnit}{iAxle};
        extractedText = regexpFindTextBetweenText(datasetName, startKey, endKey);
        textExtractedBetweenStartAndEndKey = extractedText;
        modifiedCombinationCell{iUnit}{iAxle} = textExtractedBetweenStartAndEndKey{:};
    end
end

end