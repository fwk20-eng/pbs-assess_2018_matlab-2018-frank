%% Function Description
%
% Compiles all of the data for the engine torque curve details table in the PBS assessment report
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

function PBSreportTable = generateTableEngineTorqueCurve(Engine)
% Note: This section will need to be developed as various vehicle configurations are assessed. It has currently been
% tested with:
%
% * Semi-trailer
% * B-Double

%% Extracting table contents

sEngineTorqueRPM = arrayfun(@(x) int2str(x), Engine.Torquerpm, 'UniformOutput', false)';
sEngineTorqueNm = arrayfun(@(x) int2str(x), Engine.TorqueNm, 'UniformOutput', false)';
Table.data = [sEngineTorqueRPM sEngineTorqueNm];

Table.Headings = {'\textbf{Engine speed (rpm)}'  '\textbf{Torque (Nm)}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Engine Torque Curve';
Table.tableLabel = 'EngineTorqueCurve';
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end
