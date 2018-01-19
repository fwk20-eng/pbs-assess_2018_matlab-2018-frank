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
% [0.2.0] 2017-06-04
%
% *Fixed*
%
% * Removed ParDetails pass-through as it is no longer required, all data is extracted in runTruckSimDataExtraction
%
% [0.1.0] - 2017-05-08
%
% *Added*
%
% * First code

function [PBSreportTable, axleDescriptionCellArray, logTable] = createTableLatexVehicleSummary(Tyre, Axle)
%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
%% Table 1: Summary of Vehicle
% Extracting table contents
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double

%% Table One: Units
Table.Units = Axle.UnitCellArray;
Table.AxleDescription = Axle.type;
axleDescriptionCellArray = Table.AxleDescription;
Table.AxleConfiguration = computeAxleGroupType(Axle);
Table.AxleSpringType = Axle.springType;
Table.TyreSize = Tyre.sizes;
Table.RimMaterial = Axle.rimMaterial;
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

Table.Headings = {'\textbf{Unit}' '\textbf{Axle}' '\textbf{Axle configuration}' '\textbf{Suspension type}' '\textbf{Tyre size}' '\textbf{Rim material}'};

markdownHeadings = {'Unit' 'Axle' 'Axle configuration' 'Suspension type' 'Tyre size' 'Rim material'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Summary of Vehicle Combination';
Table.tableLabel = 'SummaryOfVehicleCombination';
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
