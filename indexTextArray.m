%% Function Description
% *indexTextArray* returns the index of the position where the specified 
% text string can be found in a cell array of strings.
% 
%% Inputs
% 
% * strArray: Cell array of strings.
% * searchString: Text string to be searched for in the cell array of 
%   strings.
% 
%% Outputs
% * *indexArray*: A row vector in the following format: [searchString,
% [indices where search string exists]]
%

%% Change Log
% [0.2.0] - 2017-04-20 
%
% Added
%
% * Regular expressions can now be used in the searchStringVector
% 
% Fixed
% 
% * Changed strfind to regexp to allow more flexibility in searching.
%
% [0.1.0] - 2017-04-17
% 
% Added
% 
% * Matlab markdown header comments
% * Ability to deal with an array or vector

%% Function: indexText
%-------------------------------------------------------------------------
function indexArray = indexTextArray(cellArrayOfStrings, searchStringVector)

% Checking if the user entered a vector or single search string
if ischar(class(searchStringVector))
    searchStringVector = {searchStringVector};
end

% Initialising cell array.
indexArray = cell(length(searchStringVector),2);

% Loop through cell array to extract indices for each variable.
for iString = 1:length(searchStringVector)
    
    index = find(not(cellfun('isempty',regexp(cellArrayOfStrings, searchStringVector(iString)))));

    %Store the variable name 
    indexArray{iString,1} = searchStringVector(iString);
    %Store the variable indices
    indexArray{iString,2} = index;
    
end

end