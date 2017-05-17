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
% [0.1.0] - 2017-05-09
%
% *Added*
%
% * First code

function PBSreportTable = generateTableSuspensionDetails(ParDetails, Sprung, Axle)
%% Extracting table contents

%% Generating par file data
allParLadenFileFullPath = strcat(ParDetails.parFileFolderPath, '\', ParDetails.allParLadenFileName);
allParLadenFileData = readLinesFromFile(allParLadenFileFullPath);

%% Table Six: Units and axle description
Table.Units = Axle.UnitCellArray;
Table.AxleDescription = Axle.DescriptionCell;

%% Table Six: Suspension make and model
% You will need to be careful how you name your axle kinematics from now on to allow for accurate reporting
GetAxleSuspensionModel.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSuspensionModel.key = 'LOG_ENTRY Used Dataset: Suspension: Solid Axle System Kinematics;';
GetAxleSuspensionModel.keySeperator = '} ';
Table.AxleSuspensionModel = getAllParDataForEachAxle(allParLadenFileData, GetAxleSuspensionModel, Sprung);

% Extract the name only without any additional parameters stored in parethesis
for iUnit = 1 : Sprung.numberOffUnits
    % Loop through each axle
    nAxles = length(Table.AxleSuspensionModel{iUnit});
    for iAxle = 1 : nAxles
        truckSimDatasetName = Table.AxleSuspensionModel{iUnit}{iAxle};
        breakdownOfDatasetName = split(truckSimDatasetName, ' [');
        reportDescriptionOnly = breakdownOfDatasetName;
        Table.AxleSuspensionModel{iUnit}{iAxle} = reportDescriptionOnly{:};
    end
end

%% Table Six: Roll centre height
% You will need to be careful how you name your roll centre height from now on to allow for accurate reporting
GetAxleRollCentre.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleRollCentre.key = 'LOG_ENTRY Used Dataset: Suspension: Lateral Movement Due to Roll and Jounce;';
GetAxleRollCentre.keySeperator = '; ';
Table.AxleRollCentre = getAllParDataForEachAxle(allParLadenFileData, GetAxleRollCentre, Sprung);

% Extract only the numerical 
for iUnit = 1 : Sprung.numberOffUnits
    % Loop through each axle
    nAxles = length(Table.AxleRollCentre{iUnit});
    for iAxle = 1 : nAxles
        truckSimDatasetName = Table.AxleRollCentre{iUnit}{iAxle};
        breakdownOfDatasetName = regexpFindTextBetweenText(truckSimDatasetName, ':\s+', '\smm');
        reportDescriptionOnly = breakdownOfDatasetName;
        Table.AxleRollCentre{iUnit}{iAxle} = reportDescriptionOnly{:};
    end
end

%% Table Six: Axle Track
GetAxleTrack.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleTrack.key = 'L_TRACK';
GetAxleTrack.keySeperator = ' ';
Table.AxleTrack = getAllParDataForEachAxle(allParLadenFileData, GetAxleTrack, Sprung);

%% Table Six: Auxiliary roll stiffness
GetAxleAuxRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Compliance', 'EXIT_PARSFILE Suspensions\Compliance'};
GetAxleAuxRoll.key = 'MX_AUX_COEFFICIENT';
GetAxleAuxRoll.keySeperator = ' ';
Table.AxleAuxRoll = getAllParDataForEachAxle(allParLadenFileData, GetAxleAuxRoll, Sprung);

%% Table Six: Steer/Roll Ratio
GetAxleSteerRoll.dataSetKeyCell = {'ENTER_PARSFILE Suspensions\Kin_Solid', 'EXIT_PARSFILE Suspensions\Kin_Solid'};
GetAxleSteerRoll.key = 'SUSP_AXLE_ROLL_STEER_COEFFICIENT';
GetAxleSteerRoll.keySeperator = ' ';
Table.AxleSteerRoll = getAllParDataForEachAxle(allParLadenFileData, GetAxleSteerRoll, Sprung);

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

Table.Headings = {'\textbf{Unit}' '\textbf{Axle}' '\textbf{Suspension}' '\textbf{RC height (mm)}\tnote{1}' '\textbf{Track width (mm)}' '\textbf{Auxiliary roll stiffness (Nm/\degree{})}' '\textbf{Steer/roll ratio (\degree{}/\degree{})}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.footNotes = {'\item[1] Roll centre height relative to the axle centre height (+ above, - below)'};
Table.userAlignment = 'c|c|c|C|C|C|C|';
Table.tableCaption = 'Suspension Details';
Table.tableLabel = 'SuspensionDetails';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
