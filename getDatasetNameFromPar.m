%% Function Description
%
% This function extracts the dataset name from an all_par
%
%% Inputs
%
% * parFileData: this needs to be an _all.par file for it to work as far as I can tell now
% * searchText: Array of variable names to search for (can also be a single string)
% * seperatorText: Use to modify how the string is split '} ' if there is an example prefix or '; ' if there is no
% prefix
%
%% Outputs
%
% * varDatasetNameArray: array of dataset names in ascending order of unit or axle #.
%
%% Change Log
%
%
% [0.1.0] - 2017-04-20
%
% Added
%
% * First code

function varDatasetNameArray = getDatasetNameFromPar(parFileData, searchText, seperatorText)

% Determine the indices of the variable within the end par file
varIndices = indexTextArray(parFileData, searchText);

% Determine the number of variables named the same as searchText
nVar = length(varIndices{1,2});

% Initialising the variable array
varDatasetNameArray = cell(1, nVar);

% Loop through each string where the variable was found and extract the value of the variable
for iInstance = 1:nVar
    varSplitString = strsplit(parFileData{varIndices{1,2}(iInstance)}, seperatorText);
    % In the case that the wrong split text is used, this code assumes it is a dummy axle with incorrect naming
    % conventions.
    try
        varDatasetNameArray{1, iInstance} = varSplitString(2);
    catch
        warning('Split text does not appear in the text, assigning as a dummy axle')
        varDatasetNameArray{1, iInstance} = {'Dummy'};
    end
end

end