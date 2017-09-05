%% Function Description
%
% This function enters a unit, then either the suspension kinematics or suspension compensation. Then individual
% datasets for each axle group are extracted
%
%% Inputs
%
% * GetAxleData: a structure with the following components
% * GetAxleData.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'}; This
% is to determine whether to look in the kinematics or compensation dataset
% * GetAxleData.key = 'LOG_ENTRY Used Dataset: Animator: Shape File Link;'; This is to determine which dataset component
% to look for within the suspension kinematics or compensation dataset
% * GetAxleData.keySeperator = '} '; The seperator to determine what to extract from the all_par file
% * GetAxleDescription.DuplicateIndices: 0 - each index contains meaningful data. 1 - Every second index contains
% meaningful data (e.g LHS and RHS are identical)
%
%% Outputs
%
% * extractedAxleData: description
%
%% Change Log
%
% [0.4.0]
%
% *Added*
%
% * Dummy axle support
%
% [0.3.0] - 2017-05-08
%
% *Fixed*
%
% * Updated the way a string is referenced in extractedAxleData. Without the additional {}, the string vector is not
% accessed directly and hence the latexTable was failing to compile the table.
%
% [0.2.0] - 2017-05-07
%
% Changed format of output cell array to match the standard combination array
%
% [0.1.0] - 2017-05-05
%
% *Added*
%
% * First code to allow extraction of axle data
% * Duplicate index check. If datasets are duplicated (for example both a left and right hand side, but the left and
% right hand side are actually identical - which is standard in all the projects I have completed up till now).

function extractedAxleData = getAllParDataForEachAxle(allParFileData, GetAxleData, Sprung)
%% Extracting data for unit 1
disp('Note: code works for standard combinations with a single lead unit only');
% Begin with the first unit
iUnit = 1;

% Extracting the axle description (based on animation name)
keyCell = {'ENTER_PARSFILE Vehicles\Lead', 'EXIT_PARSFILE Vehicles\Lead'};
SplicedAllPar.units = spliceAllPar(allParFileData, keyCell);

keyCell = GetAxleData.dataSetKeyCell;
SplicedAllPar.AxleDataset{:,iUnit} = spliceAllPar(SplicedAllPar.units{:,iUnit}, keyCell)';

nSplicedAxles = length(SplicedAllPar.AxleDataset{:,iUnit});

for iAxle = 1: nSplicedAxles
    % Note in this extraction there will only be a single dataset for each axle, as the all par has been sliced down to
    % the suspension kinematics/compensation dataset for each axle
    axleDescription = getDatasetNameFromPar(SplicedAllPar.AxleDataset{:,iUnit}{iAxle}, ...
        GetAxleData.key, GetAxleData.keySeperator);
    
    % The second index is to properly extract the string. If it is not there, there are problems when generating a table
    if ~isempty(axleDescription)
        extractedAxleData{:,iUnit}{iAxle} = axleDescription{1}{1};
    else
        extractedAxleData{:,iUnit}{iAxle} = 'Dummy';
    end
end

%% Extracting data for unit 2 and beyond

% Extract all trailer unit data
keyCell = {'ENTER_PARSFILE Vehicles\Trailer', 'EXIT_PARSFILE Vehicles\Trailer'};
SplicedAllPar.units = [SplicedAllPar.units, spliceAllPar(allParFileData, keyCell)];

% Extracting the dolly dataset if present
SplicedAllPar.units = extractNestedDollyDataFromTrailer(SplicedAllPar.units);

for iUnit = 2:Sprung.numberOffUnits
    
    keyCell = GetAxleData.dataSetKeyCell;
    SplicedAllPar.AxleDataset{:,iUnit} = spliceAllPar(SplicedAllPar.units{:,iUnit}, keyCell)';
    
    nSplicedAxles = length(SplicedAllPar.AxleDataset{:,iUnit});
    
    for iAxle = 1: nSplicedAxles
        % Note in this extraction there will only be a single dataset for each axle, as the all par has been sliced down to
        % the suspension kinematics/compensation dataset for each axle
        axleDescription = getDatasetNameFromPar(SplicedAllPar.AxleDataset{:,iUnit}{iAxle}, ...
            GetAxleData.key, GetAxleData.keySeperator);
        
        if ~isempty(axleDescription)
            extractedAxleData{:,iUnit}{iAxle} = axleDescription{1}{1};
        else
            extractedAxleData{:,iUnit}{iAxle} = 'Dummy';
        end
    end
    
end

end