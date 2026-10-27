%% Function Description
% This function takes a cell array of strings, and returns an array of numerical values
% 
%% Inputs
% 
% * cellArrayOfStrings: Cell array of strings that is to be converted
% 
%% Change Log
% 
% [0.1.0] - 2017-04-20
% 
% Added
% 
% * First code

function numericalMatrix = convertCellArrayOfStringsToNumericalMatrix(cellArrayOfStrings)

% Convert each element to a number
numericalMatrix = cellfun(@str2num,cellArrayOfStrings(:),'un',0)';
% Convert to standard array
numericalMatrix = cell2mat(numericalMatrix);

end