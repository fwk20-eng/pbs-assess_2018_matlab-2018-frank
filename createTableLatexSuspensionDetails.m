%% Function Description
%
% Compiles all of the data for the suspension details table in the PBS assessment report
%
%% Inputs
%
% * ParDetails
% * Sprung
% * Axle
%
%% Outputs
%
% * PBSreportTable: cell array structured correctly to be used with latexTable function
%
%% Change Log
%
% [0.2.0] 2017-06-04
%
% *Fixed*
%
% * Removed ParDetails pass-through as it is no longer required, all data is extracted in runTruckSimDataExtraction
%
% [0.1.0] - 2017-05-09
%
% *Added*
%
% * First code

function PBSreportTable = createTableLatexSuspensionDetails(Axle)
%% Extracting table contents

%% Table Six: Data
Table.Units = Axle.UnitCellArray;
Table.AxleDescription = Axle.DescriptionCell;
Table.AxleSuspensionModel = Axle.complianceReportName;
Table.SpringModel = Axle.springReportModel;
Table.DamperModel = Axle.damperReportModel;
Table.StabiliserModel = Axle.stabiliserModel;

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

Table.Headings = {'\textbf{Unit}' '\textbf{Axle}' '\textbf{Suspension}' '\textbf{Spring Model}' '\textbf{Damper Model}' '\textbf{Stabiliser Model}\tnote{1}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.footNotes = {'\item[1] If ``-", no stabiliser is present, the auxiliary roll moment is due to the inherent stiffness of the axle'};
Table.userAlignment = 'c|c|c|C|C|C|';
Table.tableCaption = 'Suspension Details';
Table.tableLabel = 'SuspensionDetails';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
