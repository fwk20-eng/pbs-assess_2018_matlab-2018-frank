%% Function Description
%
% Compiles all of the data for the gearbox details table in the PBS assessment report
%
%% Inputs
%
% * Engine
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

function [PBSreportTable, logTable] = createTableLatexGearboxTransmission(Engine)
%% Extracting table contents

sGearboxLabels = Engine.gearsStartLabels';
sGearRatio = arrayfun(@(x) num2str(x, '%0.2f'), Engine.gearsStart, 'UniformOutput', false)';
sEfficiencies = arrayfun(@(x) num2str(x, '%0.2f'), Engine.eff_gearStart, 'UniformOutput', false)';
Table.data = [sGearboxLabels sGearRatio sEfficiencies];

Table.Headings = {'\textbf{Gear}'  '\textbf{Ratio}' '\textbf{Efficiencies}'};

markdownHeadings = {'Gear' 'Ratio' 'Efficiencies'};
MdTable.data = [markdownHeadings; Table.data];

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Gearbox Transmission Data';
Table.tableLabel = 'GearboxTransmissionData';
Table.booktabs = 0;
Table.tableBorders = 1;

MdTable.label = Table.tableCaption;

logTable = markdownTable(MdTable);

PBSreportTable = latexTable(Table);
end
