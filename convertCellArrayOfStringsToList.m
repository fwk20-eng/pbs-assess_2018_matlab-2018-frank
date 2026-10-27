%% Function Description
% This function takes a cell array of strings, and returns a list of values
% 
%% Inputs
% 
% * cellArrayOfStrings: Cell array of strings that is to be converted
% 
%% Change Log
% 
% [0.1.0] - 2017-08-01
% 
% Added
% 
% * First code

function list = convertCellArrayOfStringsToList(cellArrayOfStrings)

iEntry = 1;
% Loop through units
for iUnit = 1 : length(cellArrayOfStrings)
    % Loop through axles in units
    for iAxle = 1 : length(cellArrayOfStrings{iUnit})
        list{iEntry} = cellArrayOfStrings{iUnit}{iAxle};
        iEntry = iEntry + 1;
    end
end

end