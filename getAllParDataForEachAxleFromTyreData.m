%% Function Description
%
% This function enters a unit, then either the suspension kinematics or suspension compensation. Then individual
% datasets for each axle group are extracted
%
%% Inputs
%
% * allParFileData: a standard extracted _all par file
% * Sprung: number of units in the combination (in this case it was easiest to pass through the Sprung variable and
% extract the number of units from the structure).
%
%% Outputs
%
% * ExtractedTyreData: A structure with the following data
% * Datasets: The original dataset names used in the simulation
% * Sizes: The tyre sizes and spacing if relevant formatted to the style used in all PBS reports
%
%% Change Log
%
% [0.1.0] - 2017-05-08
%
% *Added*
%
% * First code to allow extraction of tyre data for each axle.
% * Adapted from getAllParDataForEachAxle.

function [ExtractedTyreData] = getAllParDataForEachAxleFromTyreData(allParFileData, Sprung)
%% Extracting data for unit 1
disp('Note: code works for standard combinations with a single lead unit only');
% Begin with the first unit
iUnit = 1;

% Splicing the par file to the lead unit details only
keyCell = {'ENTER_PARSFILE Vehicles\Lead', 'EXIT_PARSFILE Vehicles\Lead'};
SplicedAllPar.Units = spliceAllPar(allParFileData, keyCell);

tyreDualSpacing = getVariableValuesFromPar(SplicedAllPar.Units{iUnit}, '\<L_DUAL');
nAxles = length(tyreDualSpacing);

% Extracting the the dataset for each tyre
tyreDatasetArray = getDatasetNameFromPar(SplicedAllPar.Units{iUnit}, 'LOG_ENTRY Used Dataset: Tire;', '} ');

iTyreIndex = 1;
for iAxle = 1 : nAxles
    disp('Note: code assumes 0 dual spacing indicates single tyres');
       
    % Note the tyreDataset must be named according to 315/80R22.5 (lag). A single space seperates the tyre size from the
    % lag/no lag modifier.
    tyreDataset = tyreDatasetArray{iTyreIndex};
    tyreDatasetSplitWithLag = strsplit(tyreDataset{:}, ' ');
    tyreSize = tyreDatasetSplitWithLag{1};
    
    if tyreDualSpacing(iAxle) == 0
        nTyres = 2;
        reportText = ' (singles)';
    elseif tyreDualSpacing(iAxle) > 0
        nTyres = 4;
        reportText = sprintf('%s%i%s',' (duals ', tyreDualSpacing(iAxle), ' spacing)');
    end
    
    % Increase the tyre index depending on number of tyres on the axle
    iTyreIndex = iTyreIndex + nTyres;
    
    ExtractedTyreData.Datasets{:,iUnit}{iAxle} = tyreDataset;
    ExtractedTyreData.Sizes{:,iUnit}{iAxle} = strcat(tyreSize, reportText);
    
end

%% Extracting data for unit 2 and beyond
% Continuing with the remaining units (assuming there are no dolly's, dolly's will need to be added in the future)
disp('Note: code works for standard trailer units without dolly''s');

% Extract all trailer unit data
keyCell = {'ENTER_PARSFILE Vehicles\Trailer', 'EXIT_PARSFILE Vehicles\Trailer'};
SplicedAllPar.Units = [SplicedAllPar.Units, spliceAllPar(allParFileData, keyCell)];

for iUnit = 2:Sprung.numberOffUnits
    
tyreDualSpacing = getVariableValuesFromPar(SplicedAllPar.Units{iUnit}, '\<L_DUAL');
nAxles = length(tyreDualSpacing);

% Extracting the the dataset for each tyre
tyreDatasetArray = getDatasetNameFromPar(SplicedAllPar.Units{iUnit}, 'LOG_ENTRY Used Dataset: Tire;', '} ');

iTyreIndex = 1;
for iAxle = 1 : nAxles
    disp('Note: code assumes 0 dual spacing indicates single tyres');
    
    if tyreDualSpacing(iAxle) == 0
        nTyres = 2;
        reportText = '(singles)';
    elseif tyreDualSpacing(iAxle) > 0
        nTyres = 4;
        reportText = sprintf('%s%i%s',' (duals ', tyreDualSpacing(iAxle), ' spacing)');
    end
    
    tyreDataset = tyreDatasetArray{iTyreIndex};
    tyreDatasetSplitWithLag = strsplit(tyreDataset{:}, ' ');
    
    tyreSize = tyreDatasetSplitWithLag{1};
    
    % Increase the tyre index depending on number of tyres on the axle
    iTyreIndex = iTyreIndex + nTyres;
    
    ExtractedTyreData.Datasets{:,iUnit}{iAxle} = tyreDataset;
    ExtractedTyreData.Sizes{:,iUnit}{iAxle} = strcat(tyreSize, reportText);
end
    
end

end