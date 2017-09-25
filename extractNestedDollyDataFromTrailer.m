%% Function Description
% 
% The function takes a raw spliced par file where the dolly par file is nested within the trailer par file and extracts
% the dolly par file into its own unit. The dolly is then ordered as a unit before the trailer within which it was
% nested.
% 
%% Inputs
% 
% * rawSplicedParFile: Spliced par file with the dolly par file still nested within the trailer splice
% 
%% Outputs
% 
% * splicedAllParWithDolly: Dolly extracted and ordered correctly
% 
%% Change Log
% 
% [0.1.0] - 2017-08-21
% 
% *Added*
% 
% * First code

function [splicedAllParWithDolly, dollyUnits] =  extractNestedDollyDataFromTrailer(rawSplicedParFile)

keyCell = {'ENTER_PARSFILE Vehicles\Dolly', 'EXIT_PARSFILE Vehicles\Dolly'};

splicedAllParWithDolly = {};
nRawUnits = length(rawSplicedParFile);
iUnit = 1;
dollyUnits = [];

for iSplice = 1 : nRawUnits
    
    try
        [dollySplice, ~, endIndex] = spliceAllPar(rawSplicedParFile{iSplice}, keyCell);
        % + 2 since there is a blank space after the dolly parsfile is exited
        trailerSpliceWithDollyRemoved = rawSplicedParFile{iSplice}(endIndex + 2: end); 
        
        splicedAllParWithDolly = [splicedAllParWithDolly, dollySplice, {trailerSpliceWithDollyRemoved}];

        dollyUnits = [dollyUnits, iUnit];

        % Increase by 2 to accomodate for both dolly and trailer
        iUnit = iUnit + 2; 
    catch
        % If there are not dolly's, the cell will remain as per the rawSplicedParFile
        splicedAllParWithDolly = [splicedAllParWithDolly, rawSplicedParFile(iSplice)];

        iUnit = iUnit + 1;
    end
    
end

% Create the dolly units variable if no dolly's are found
if ~exist('dollyUnits')
    dollyUnits = [];
end

end