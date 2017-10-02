%% Function Description
% 
% A function used to extract data from between parenthesis for a standard combination cell array
% 
%% Inputs
% 
% * cellArray: Standard PBS combination cell array with a dataset name
% * startKey: The beginning parenthesis (e.g. '\[')
% * endKey: The ending parenthesis (e.g. '\]')
% 
%% Outputs
% 
% * extractedCellArray: The data between the parenthesis will be extracted and placed in the respective cell in the cell
% array such that the structure in the extracted array is identical
% 
%% Change Log
% 
% [0.1.0] - 2017-05-22
% 
% *Added*
% 
% * First code

function extractedCellArray = extractTextBetweenParenthesis_CombinationCell(cellArray, startKey, endKey, isNum)

nUnits = length(cellArray);
% Extract the name only without any additional parameters stored in parethesis
for iUnit = 1 : nUnits
    % Loop through each axle
    nAxles = length(cellArray{iUnit});
    for iAxle = 1 : nAxles
        datasetName = cellArray{iUnit}{iAxle};
        extractedText = regexpFindTextBetweenText(datasetName, startKey, endKey);
        textBetweenStartAndEndKey = extractedText;
        extractedCellArray{iUnit}{iAxle} = textBetweenStartAndEndKey{:};
    end
end

%% Allow the user to convert to a numerical value if the data between parenthesis is numerical
if isNum
    extractedCellArray = cellfun(@(x) str2double(x), extractedCellArray, 'UniformOutput', false);
end

end