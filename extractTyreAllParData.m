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
% * LoadIndices: The Load Indices
%
%% Change Log
%
% [0.2.0] - 2017-08-21
%
% *Added*
%
% * Dolly support
%
% [0.1.0] - 2017-05-08
%
% *Added*
%
% * First code to allow extraction of tyre data for each axle.
% * Adapted from extractAxleAllParData.

function [ExtractedTyreData, dolly_trailerFrontAxleUnits] = extractTyreAllParData(allParFileData, Sprung)
%% Extracting data for unit 1
% disp('Note: code works for standard combinations with a single lead unit only');
% Begin with the first unit
iUnit = 1;

% Splicing the par file to the lead unit details only
keyCell = {'ENTER_PARSFILE Vehicles\Lead', 'EXIT_PARSFILE Vehicles\Lead'};
SplicedAllPar.units = spliceAllPar(allParFileData, keyCell);

tyreDualSpacing = getVariableValuesFromPar(SplicedAllPar.units{iUnit}, '\<L_DUAL');
nAxles = length(tyreDualSpacing);

% Extracting the the dataset for each tyre
tyreDatasetArray = getDatasetNameFromPar(SplicedAllPar.units{iUnit}, 'LOG_ENTRY Used Dataset: Tire;', '} ');

iTyreIndex = 1;
for iAxle = 1 : nAxles
    % disp('Note: code assumes 0 dual spacing indicates single tyres');
    
    % Note the tyreDataset must be named according to 315/80R22.5 (lag). A single space seperates the tyre size from the
    % lag/no lag modifier.
    tyreDataset = tyreDatasetArray{iTyreIndex};
    tyreDatasetSplitWithLag = strsplit(tyreDataset{:}, ' ');
    tyreSize = tyreDatasetSplitWithLag{1};
    
    % Extract number after "dataset"
    tyreDatasetNumber = regexp(tyreDataset{:}, 'dataset\s+(\d+)', 'tokens');
    % The pairing of the dual rating is the lowest readily-available in
    % South Africa that is linked with the given single rating
    switch tyreDatasetNumber{1}{:}
        case '1'
            tyreLoadIndex = '128/124';
        case '2'
            tyreLoadIndex = '132/130';
        case '3'
            tyreLoadIndex = '136/134';
        case '4'
            tyreLoadIndex = '140/137';
        case '5'
            tyreLoadIndex = '144/142';
        case '6'
            tyreLoadIndex = '148/144';
        case '7'
            tyreLoadIndex = '152/147';
        case '8'
            tyreLoadIndex = '156/150';
        case '9'
            tyreLoadIndex = '160/156';
        case '10'
            tyreLoadIndex = '164/160';
        otherwise
            tyreLoadIndex = 'error';
    end
    
    % For single tyre configurations, only use the single load index.
    % For dual configurations retain the full single/dual load index.
    if tyreDualSpacing(iAxle) == 0 && ~strcmp(tyreLoadIndex, 'error')
        tyreLoadIndex = strtok(tyreLoadIndex, '/');
    end
    
    if tyreDualSpacing(iAxle) == 0
        nTyres = 2;
        reportText = ' (singles)';
    elseif tyreDualSpacing(iAxle) > 0
        nTyres = 4;
        reportText = sprintf('%s%i%s',' (duals ', tyreDualSpacing(iAxle), ' spacing)');
    end
    
    % Increase the tyre index depending on number of tyres on the axle
    iTyreIndex = iTyreIndex + nTyres;
    
    ExtractedTyreData.Datasets{:,iUnit}{iAxle} =tyreDatasetNumber{1}{:};
    ExtractedTyreData.Sizes{:,iUnit}{iAxle} = strcat(tyreSize, reportText);
    ExtractedTyreData.LoadIndices{:,iUnit}{iAxle} = tyreLoadIndex;
end

%% Extracting data for unit 2 and beyond
% Continuing with the remaining units
if Sprung.numberOffUnits > 1
    % Extract all trailer unit data
    keyCell = {'ENTER_PARSFILE Vehicles\Trailer', 'EXIT_PARSFILE Vehicles\Trailer'};
    SplicedAllPar.units = [SplicedAllPar.units, spliceAllPar(allParFileData, keyCell)];
end

% Extracting the dolly_trailerFrontAxle dataset if present
[SplicedAllPar.units, dolly_trailerFrontAxleUnits] = extractDollyDataFromTrailer(SplicedAllPar.units);

for iUnit = 2:Sprung.numberOffUnits
    
    tyreDualSpacing = getVariableValuesFromPar(SplicedAllPar.units{iUnit}, '\<L_DUAL');
    nAxles = length(tyreDualSpacing);
    
    % Extracting the the dataset for each tyre
    tyreDatasetArray = getDatasetNameFromPar(SplicedAllPar.units{iUnit}, 'LOG_ENTRY Used Dataset: Tire;', '} ');
    
    iTyreIndex = 1;
    for iAxle = 1 : nAxles
        % disp('Note: code assumes 0 dual spacing indicates single tyres');
        
        if tyreDualSpacing(iAxle) == 0
            nTyres = 2;
            reportText = ' (singles)';
        elseif tyreDualSpacing(iAxle) > 0
            nTyres = 4;
            reportText = sprintf('%s%i%s',' (duals ', tyreDualSpacing(iAxle), ' spacing)');
        end
        
        tyreDataset = tyreDatasetArray{iTyreIndex};
        tyreDatasetSplitWithLag = strsplit(tyreDataset{:}, ' ');
        
        tyreSize = tyreDatasetSplitWithLag{1};
        
        % Extract number after "dataset"
        tyreDatasetNumber = regexp(tyreDataset{:}, 'dataset\s+(\d+)', 'tokens');
        switch tyreDatasetNumber{1}{:}
            case '1'
                tyreLoadIndex = '128/124';
            case '2'
                tyreLoadIndex = '132/130';
            case '3'
                tyreLoadIndex = '136/134';
            case '4'
                tyreLoadIndex = '140/137';
            case '5'
                tyreLoadIndex = '144/142';
            case '6'
                tyreLoadIndex = '148/144';
            case '7'
                tyreLoadIndex = '152/147';
            case '8'
                tyreLoadIndex = '156/150';
            case '9'
                tyreLoadIndex = '160/156';
            case '10'
                tyreLoadIndex = '164/160';
            otherwise
                tyreLoadIndex = 'error';
        end
        
        % For single tyre configurations, only use the single load index.
        % For dual configurations retain the full single/dual load index.
        if tyreDualSpacing(iAxle) == 0 && ~strcmp(tyreLoadIndex, 'error')
            tyreLoadIndex = strtok(tyreLoadIndex, '/');
        end
        
        % Increase the tyre index depending on number of tyres on the axle
        iTyreIndex = iTyreIndex + nTyres;
        
        ExtractedTyreData.Datasets{:,iUnit}{iAxle} = tyreDatasetNumber{1}{:};
        ExtractedTyreData.Sizes{:,iUnit}{iAxle} = strcat(tyreSize, reportText);
        ExtractedTyreData.LoadIndices{:,iUnit}{iAxle} = tyreLoadIndex;
    end
    
end

disp('wait')
end