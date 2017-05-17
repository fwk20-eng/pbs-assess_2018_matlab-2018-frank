%% Function Description
%
% Compiles all unsprung mass details into a table for the PBS assessment report
%
%% Inputs
%
% * Sprung
%
%% Outputs
%
% * Table: a structure containing all the details in table for a PBS report including the latex settings
%
%% Change Log
%
% [0.1.0] - 2017-05-08
%
% *Added*
%
% * First code

function PBSreportTable = generateTableUnsprungMassDetails(Axle)
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double
%% Table 4: Unsprung Mass Values and CoG Heights
% Extracting table contents

Table.data = {};

% Fetching the axle units and description
Table.Units = Axle.UnitCellArray;
nUnits = length(Axle.UnitCellArray);
Table.AxleDescription = Axle.DescriptionCell;

% Fetching the number of axles
nAxles = Axle.NumberOff;

% Initialising variable indices
iAxleIndex = 1;
Table.data = {};

for iUnit = 1 : nUnits
    
    nAxlesOnUnit = length(Axle.UnitCellArray{iUnit});
    
    if iUnit == 1
        for iAxle = 1 : nAxlesOnUnit
            sUnit = int2str(iUnit);
            sAxleDescription = Axle.DescriptionCell{iUnit}{iAxle};
            sUnsprungMass = int2str(Axle.UnsprungMassArray(iAxleIndex));
            % Need to multiply by 1000 to get to mm.
            sAxleCoGz = int2str(Axle.ZPositionArray(iAxleIndex)*1000);
            dataRow = {sUnit, sAxleDescription, sUnsprungMass, sAxleCoGz};
            
            Table.data = [Table.data; dataRow];
            % Move to next axle
            iAxleIndex = iAxleIndex + 1;
        end
    else
        sUnit = int2str(iUnit);
        %Extract only the first description
        sAxleDescription = Axle.DescriptionCell{iUnit}{1};
        sUnsprungMass = int2str(Axle.UnsprungMassArray(iAxleIndex));
        % Need to multiply by 1000 to get to mm.
        sAxleCoGz = int2str(Axle.ZPositionArray(iAxleIndex)*1000);
        dataRow = {sUnit, sAxleDescription, sUnsprungMass, sAxleCoGz};
        Table.data = [Table.data; dataRow];
        iAxleIndex = iAxleIndex + 1;
        % Move straight to next axle group
        iAxleIndex = iAxleIndex + nAxlesOnUnit;
    end
    
end

%% Generating the Latex Tables (this should be moved to a standalone function file when suitably tested.
Table.Headings = {'\textbf{Unit}' '\textbf{Axle description}' '\textbf{Mass (kg)}' '\textbf{CoG height (mm)}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Unsprung Mass Values and CoG Heights';
Table.tableLabel = 'UnsprungMassValuesAndCoGHeights';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
