%% Function Description
% 
% Extract the sprung mass description from the sprung mass dataset
% 
%% Inputs
% 
% * allParLadenFileData: all_par file data
% 
%% Outputs
% 
% * sprungMassDescriptionArray: array containing unit descriptions
% 
%% Change Log
% 
% [0.2.0] - 2017-08-20
%
% * Added dolly support
%
% [0.1.0] - 2017-01-01
% 
% *Added*
% 
% * First code

function sprungMassDescriptionArray = extractSprungMassDescriptionArray(allParLadenFileData)

GetUnitDescription.key = 'LOG_ENTRY Used Dataset: Vehicle: Lead Unit Sprung Mass;';
GetUnitDescription.keySeperator = '} ';
leadUnitDescription = getDatasetNameFromPar(allParLadenFileData,GetUnitDescription.key, ...
    GetUnitDescription.keySeperator);


GetUnitDescription.key = 'LOG_ENTRY Used Dataset: Vehicle: Trailer Sprung Mass;';
GetUnitDescription.keySeperator = '} ';
trailerDescriptionArray = getDatasetNameFromPar(allParLadenFileData,GetUnitDescription.key, ...
    GetUnitDescription.keySeperator);

sprungMassDescriptionArray = [leadUnitDescription trailerDescriptionArray];

end