%% Function Description
% 
% This function will splice an all_par file according to the start and end key. Consecutive slices will allow you to
% narrow down to a specific data set, (e.g. the susp kin dataset for each axle in the lead unit, sorted by order
% beginning at the steer axle)
% 
%% Inputs
% 
% * allParFileData: the data from an _all par file, extracted to a cell array of strings using the readLinesFromFile
% function
% * keyCell: A cell containing the start and end key where you would like to splice the all_par file. A typical example
% would be keyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
%
% 
%% Outputs
% 
% * splicedAllPar: The output variable will result in a nested cell array as follows:
% * splicedAllPar = {DataFromIndexSet1; 
%                   DataFromIndexSet2;...
%                   DataFromIndexSetLast}
% * In other words, the spliced all par will result in an n x 1 cell array where n is the number of indices found for
% the requested keyCell.
%% Change Log
% 
% [0.4.0] - 2017-08-21
%
% * Added dolly functionality
%
% [0.3.0] - 2017-05-07
%
% *Updated*
%
% * Changed the output to be a consistent 1 x n cell array where each column contains the extracted data from a single
% index of the found keyCell start and end key. This is to make it consistent with the combination cell array format s
% decided upon on 2017-05-07.
%
% [0.2.0] - 2017-05-05
% 
% *Fixed*
%
% * Changed output to be a consistent n x 1 cell array where each row contains a the extracted data from a single index 
% of the found keyCell start and end key. 
%
% [0.1.0] - 2017-05-03
% 
% *Added*
% 
% * First code, compiled from the original par file extractor in the Matlab API

function [splicedAllPar, startIndex, endIndex] = spliceAllPar(allParFileData, keyCell)
   
startIndex = indexText(allParFileData, keyCell{1});
endIndex = indexText(allParFileData, keyCell{2});

nIndex = length(startIndex);

% If there is only a single instance of the start and end key, the par file can be spliced directly
if nIndex == 1
    splicedAllPar{1} = allParFileData(startIndex:endIndex);
elseif nIndex > 1
    % If there are multiple instances of the start and end key, the par file will need to be split multiple times, each
    % set of indices will be moved to a new cell
    for iInstance = 1 : nIndex
        splicedAllPar{iInstance} = allParFileData(startIndex(iInstance):endIndex(iInstance));
    end
end

end



