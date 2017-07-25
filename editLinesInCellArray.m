%% Function Description
% 
% Describe the function here
% 
%% Inputs
% 
% * cellArray
% * searchText
% * replacementText
% 
%% Outputs
% 
% * modifiedCellArray: modified cell array with 
% 
%% Change Log
% 
% [0.1.0] - 2017-01-01
% 
% *Added*
% 
% * First code based on getVariableValuesFromPar

function modifiedCellArray = editLinesInCellArray(cellArray, searchText, replacementText, regExp)

% Determine the indices of the search text within a cell string array
varIndices = indexTextArray(cellArray, searchText);

nVar = length(varIndices{1,2});

% Determine the number of variables named the same as searchText, if more than 1 index, a warning will occur
if nVar > 1
    warnMultiple = questdlg('There are multiple lines in the text file with the same searchText', 'Do you want to replace them all?', 'Yes', 'Cancel');
    switch warnRunExists
        case 'Yes'
            uiwait(msgbox(sprintf('%s%i%s%s%s', 'All ', nVar, ' occurrences of ', searchText, ' will be modified')));
        case 'Cancel'
            error('Manually initiated error in order to jump out of the script');
    end
end

% Loop through each string where the variable was found and extract the value of the variable
modifiedCellArray = cellArray;

for iInstance = 1:nVar
	index = varIndices{1,2}(iInstance);
    str = modifiedCellArray{index};
    modString = regexprep(str, regExp, replacementText);
    modifiedCellArray{index} = modString;
end

end