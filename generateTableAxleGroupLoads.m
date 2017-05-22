%% Function Description
%
% Compiles all of the data for table one into a single structure that can be used to generate a latex table with the
% latexTable function
%
%% Inputs
%
% * Axle: Axle structure
% * Axle1: Axle laden loads with loadsharing1
% * AxleU1: Axle unladen loads with loadsharing1
%
%% Outputs
%
% * Table: a structure containing all the details in table two for a PBS report including the latex settings
%
%% Change Log
%
% [0.1.0] - 2017-05-08
%
% *Added*
% 
% * First code

function PBSreportTable = generateTableAxleGroupLoads(Axle, Axle1, AxleU1)
%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
%% Table 2: Axle Group Loads of Proposed Vehicle

% Fetching the axle units
Table.Units = Axle.UnitCellArray;

Table.AxleDescription = Axle.DescriptionCell;

% Fetching the number of axles
nAxles = Axle.NumberOff;

% Initialising variable indices
iAxleIndex = 0;
currentUnit = 1;

for iAxle = 1 : nAxles
    % Extract the unit
    iUnit = Axle.UnitAndGroup(iAxle, 2);
    
    if iUnit == currentUnit
        iAxleIndex = iAxleIndex + 1;
    else
        iAxleIndex = 1;
        currentUnit = iUnit;
    end
    
    Table.AxleLadenLoads{:,iUnit}{:,iAxleIndex} = int2str(Axle1(iAxle));
    axleLadenLoadsNumeric{:,iUnit}{:,iAxleIndex} = Axle1(iAxle);
    
    Table.AxleUnladenLoads{:,iUnit}{:,iAxleIndex} = int2str(AxleU1(iAxle));
    axleUnladenLoadsNumeric{:,iUnit}{:,iAxleIndex} = AxleU1(iAxle);
    
end

% Axle load ratings
Table.axleLoadRating = Axle.loadRatings;
axleLoadRatingNumeric = cellfun(@(x) str2double(x), Axle.loadRatings, 'UniformOutput', false);


%% Convert TableOne to a format that will create the latexTable correctly.
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
        % Calculating axle group loads in the case of tailers/dollys
        if strcmp(sFieldNames{iField},'AxleLadenLoads')
            % Sum the axle loads for the group
            axleGroupLoad = sum(cell2mat(axleLadenLoadsNumeric{iUnit}));
            tableData{iField} = [tableData{iField}; int2str(axleGroupLoad)];
        elseif strcmp(sFieldNames{iField},'AxleUnladenLoads')
            % Sum the axle loads for the group
            axleGroupLoad = sum(cell2mat(axleUnladenLoadsNumeric{iUnit}));
            tableData{iField} = [tableData{iField}; int2str(axleGroupLoad)];
        elseif strcmp(sFieldNames{iField}, 'axleLoadRating')
            % Sum the axle load ratings for the axle group
            axleGroupRating = sum(axleLoadRatingNumeric{iUnit});
            tableData{iField} = [tableData{iField}; int2str(axleGroupRating)];
        else
        % Note the indexing here with the circular brackets.
        tableData{iField} = [tableData{iField}; fieldData{iUnit}(1)'];
        end
    end
end

Table.data = tableData{1};

for iCol = 2 : nFields
    Table.data = [Table.data, tableData{iCol}];
end

Table.headings = {'\textbf{Unit}' '\textbf{Axle description}' '\textbf{Fully laden axle group load (kg)}\tnote{1}'...
                  '\textbf{Unladen axle group load (kg)}\tnote{2}' '\textbf{Axle Load Rating (kg)}'};

Table.footNotes = {'\item[1] Discrepencies between axle loads and GCM may occur due to rounding';...
                   '\item[2] Proposed vehicle with no payload, only fuel and driver'};
               
% Compiling the structure fields required by latexTable
Table.data = [Table.headings; Table.data];
Table.tableCaption = 'Axle Group Loads of Proposed Vehicle';
Table.tableLabel = 'AxleGroupLoadsOfProposedVehicle';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
