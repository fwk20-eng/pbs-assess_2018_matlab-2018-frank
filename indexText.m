%% Function Description
% *indexText* returns the index of the position where the specified text
% string can be found in a cell array of strings.
% The output should be a single integer indicating the cell
% which contains the desired text.
% 
%% Inputs
% 
% * strArray: Cell array of strings.
% * searchString: Text string to be searched for in the cell array of 
%   strings.
% 
%% Outputs
% * *index*: A row vector containing all indices where the specified text
% was found
%

%% Change Log
% 
% [0.1.0] - 2017-04-17
% 
% Added
% 
% * Matlab markdown header comments
% * Improved variable name readability

%% Function: indexText
%-------------------------------------------------------------------------
function index = indexText(cellArrayOfStrings, searchString)

index = find(not(cellfun('isempty',strfind(cellArrayOfStrings, ...
                                                          searchString))));

end