%% Function Description
%
% Compiles all of the data for table one into a single structure that can be used to generate a latex table with the latexTable function
%
%% Inputs
%
% 
%% Outputs
%
% * Table: a structure containing all the details in table one for a PBS report including the latex settings
%
%% Change Log
%
%
% *Added*
%
% * First code
function [PBSreportTable] = createTableLatexCommissioningVehicleAndAssessor;
%
Table.Parameter{1} = 'Full description of combination';
Table.RequiredValue{1} = '\pmDescr{} and \tlDescr{}';
%
Table.Parameter{2} = 'Operator';
Table.RequiredValue{2} = '\client{}';
%
Table.Parameter{3} = 'Truck make and model';
Table.RequiredValue{3} = '\pmDescr{}';
%
Table.Parameter{4} = 'Trailer manufacturer';
Table.RequiredValue{4} = '\tlManu{}';
%
Table.Parameter{5} = 'Assessor Name';
Table.RequiredValue{5} = '\phantom{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}';
%
Table.Parameter{6} = 'Assessor Affiliation';
Table.RequiredValue{6} = '';
%
Table.Parameter{7} = 'Date of Assessment';
Table.RequiredValue{7} = '';
%
Table.data = [Table.Parameter(:) Table.RequiredValue(:)];
Table.Headings = {'\textbf{Parameter}' '\textbf{Value}'};

% Compiling the structure fields required by latexTable
Table.data = [Table.Headings; Table.data];
Table.tableCaption = 'Vehicle Combination and Assessor';
Table.tableLabel = 'VehicleCombinationAndAssessor';
Table.booktabs = 0;
Table.tableBorders = 1;
Table.tableColumnAlignment = 'L';

PBSreportTable = latexTable(Table);
end