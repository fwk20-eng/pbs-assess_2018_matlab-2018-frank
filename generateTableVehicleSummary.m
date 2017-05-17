%% Function Description
%
% Compiles all of the data for table one into a single structure that can be used to generate a latex table with the
% latexTable function
%
%% Inputs
%
% * allParLadenFileData 
% * Sprung
% * Axle
%
%% Outputs
%
% * Table: a structure containing all the details in table one for a PBS report including the latex settings
%
%% Change Log
%
% [0.1.0] - 2017-05-08
%
% *Added*
%f
% * First code

function [PBSreportTable, axleDescriptionCellArray] = generateTableVehicleSummary(ParDetails, Sprung, Axle)
%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
%% Table 1: Summary of Vehicle
% Extracting table contents
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double

%% Generating par file data
allParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParLadenFileName);
allParLadenFileData = readLinesFromFile(allParLadenFileFullPath);

%% Table One: Units
Table.Units = Axle.UnitCellArray;
%% Table One: Axle Description

GetAxleDescription.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleDescription.key = 'LOG_ENTRY Used Dataset: Animator: Shape File Link;';
GetAxleDescription.keySeperator = '} ';
Table.AxleDescription = getAllParDataForEachAxle(allParLadenFileData, GetAxleDescription, Sprung);

axleDescriptionCellArray = Table.AxleDescription;
%% Table One: Axle Configuration
Table.AxleConfiguration = getAxleGroupConfiguration(Axle);

%% Table One: Spring type
% *Note:* there are 2 iterations of spring for each axle. This is because TruckSim makes contingency for having a
% different left and right spring. Thus will only take the first indice where multiple indices are found.
% For this I have manually added information on the spring indicating its type [Air] or [Steel] within the par file. All
% springs must be renamed accordingly.

%% Table One: Axle spring datasets and spring type
GetAxleSpringDatasets.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', 'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleSpringDatasets.key = 'LOG_ENTRY Used Dataset: Suspension: Spring;';
GetAxleSpringDatasets.keySeperator = '} ';
Axle.SpringDatasets = getAllParDataForEachAxle(allParLadenFileData, GetAxleSpringDatasets, Sprung);

Table.AxleSpringType = getAxleParameterTypeFromTruckSimDatasetName(Axle.SpringDatasets);

%% Table One: Tyre Size and spacing
extractedTyreData = getAllParDataForEachAxleFromTyreData(allParLadenFileData, Sprung);

Table.TyreSize = extractedTyreData.Sizes;

%% Table One: Axle suspension kinematics and rim material
GetSuspensionKinematics.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetSuspensionKinematics.key = 'Suspension: Solid Axle System Kinematics';
GetSuspensionKinematics.keySeperator = '} ';
Axle.SuspensionKinDatasets = getAllParDataForEachAxle(allParLadenFileData, GetSuspensionKinematics, Sprung);

Table.RimMaterial = getAxleParameterTypeFromTruckSimDatasetName(Axle.SuspensionKinDatasets);

%% Convert Table to a format that will create the latexTable correctly.
%
% *Some notes on the conversion*
%
% * For Unit 1 (prime mover) - All axle data is used
% * For Unit 2 and beyond (trailer or dolly units) - Only the data for the first axle is used (this is because all axles
% should be identical in a trailer or dolly)
% * Each field in the table structure will become a new column
% * The table structure should be generated in the order of appearance in the table columns

% Extract the field names from the table structure
sFieldNames = fieldnames(Table);

nFields = length(sFieldNames);
nUnits = length(Table.(sFieldNames{1}));

for iField = 1 : nFields
    % Set unit index to the first unit
    iUnit = 1;
    
    fieldData = Table.(sFieldNames{iField});
    
    tableData{iField} = fieldData{iUnit}';
    
    % Loop through the remaining units
    for iUnit = 2 : nUnits
        % Note the indexing here with the circular brackets.
        tableData{iField} = [tableData{iField}; fieldData{iUnit}(1)'];
    end
    
end

Table.data = tableData{1};

for iCol = 2 : nFields
    
    Table.data = [Table.data, tableData{iCol}];
    
end

Table.Headings = {'\textbf{Unit}' '\textbf{Axle description}' '\textbf{Axle configuration}' '\textbf{Suspension type}' '\textbf{Tyre size}' '\textbf{Rim material}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Summary of Vehicle Combination';
Table.tableLabel = 'SummaryOfVehicleCombination';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
