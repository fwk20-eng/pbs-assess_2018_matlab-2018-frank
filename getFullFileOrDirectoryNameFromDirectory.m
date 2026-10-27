%% Function Description
%
% Extracts all of the directory and file names from a directory and finds all files or
%
%% Inputs
%
% * directory: Full path to directory of choice
% * partialName: Part of the filename
% * type: file or directory
%
%% Outputs
%
% * fullName: If there is only 1 instance, this will return a string including the file or directory name
% * If there are multiple instances, this will return a cell array of strings including each result
%
%% Change Log
%
% [0.1.0] - 2017-07-03
%
% *Added*
%
% * First code

%% Test data
% directory = 'C:\Users\deiss\Desktop\test';
% partialName = 'test';
% type = 'directory';

%% Function
function [fullName, isDuplicate] = getFullFileOrDirectoryNameFromDirectory(directory, partialName, type)

isDuplicate = 0;

% Get a directory of all folder names in the trucksim results folder
dirInfo = dir(directory);

% Logical matrix to determine if an item is a directory (i.e. folder)
isDir = [dirInfo.isdir];

% Collet all the file names as a list
fileNames = {dirInfo(~isDir).name}';
% Collect all the folder names as a list
dirNames = {dirInfo(isDir).name}';

% Return the full folder name
switch type
    case 'file'
        % Find the index containing the matching file name
        index = indexText(fileNames, partialName);
        if length(index) > 1
            isDuplicate = 1;
            fullName = fileNames(index);
        else
            fullName = fileNames{index};
        end
    case 'directory'
        % Find the index containing the matching folder
        index = indexText(dirNames, partialName);
        if length(index) > 1
            isDuplicate = 1;
            fullName = dirNames(index);
        else
            fullName = dirNames{index};
        end
end

end
