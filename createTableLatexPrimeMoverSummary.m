%% Function Description
%
% Compiles all of the data for the prime mover details table in the PBS assessment report
%
%% Inputs
%
% * Sprung
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

function [PBSreportTable, logTable] = createTableLatexPrimeMoverSummary(Engine, Sprung)
%% Table 8:  Truck-Tractor Details
% Extracting table contents

sprungDescriptionArrayForReport = editCombinationCellSplitText(Sprung.DescriptionArray, {' (',' ['}, 1);

sPrimeMoverModel = sprungDescriptionArrayForReport{1}{:};
sEngineModel = Engine.EngineModelDescription;
sGearboxModel = Engine.GearboxModelDescription;
sDifferentialRatio = num2str(Engine.dif);
sClutchEngagementSpeed = num2str(Engine.engageTrpm, '%0.0f');
sClutchEngagementTorque = num2str(Engine.engageTNm, '%0.0f');
sGearChangeSpeed = num2str(Engine.changeT, '%0.0f');

Table.vehicleParameterHeadings = {'Model Designation'; ...
    'Engine model';...
    'Gearbox model';...
    'Differential ratio';...
    'Clutch engagement speed (rpm)';...
    'Clutch engagement torque (Nm)';...
    'Gear change speed (rpm)';};

columnDataForTable = {sPrimeMoverModel;...
    sEngineModel;...
    sGearboxModel;...
    strcat(sDifferentialRatio, ':1');...
    sClutchEngagementSpeed;...
    sClutchEngagementTorque;...
    sGearChangeSpeed};

Table.data = [Table.vehicleParameterHeadings columnDataForTable];

Table.headings = {'\textbf{Vehicle parameter}'  '\textbf{Description}'};

markdownHeadings = {'Vehicle parameter' 'Description'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.data = [Table.headings; Table.data];
Table.tableCaption = 'Prime Mover Specific Details';
Table.tableLabel = 'PrimeMoverSpecificDetails';
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
