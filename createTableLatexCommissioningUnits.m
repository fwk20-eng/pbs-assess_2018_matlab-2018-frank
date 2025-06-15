%% Function Description
%
% Compiles all of the data for table one into a single structure that can be used to generate a latex table with the latexTable function
%
%% Inputs
%
% * Tyre 
% * Axle
% * Hitch
% * dollys
% * refPointsLadenCell
% * iUnit
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
function [PBSreportTable] = createLatexTableCommissioningUnits(Tyre, Axle, Hitch, dollys, refPointsLadenCell, iUnit)
%
nUnits = length(Axle.type);
nHitches = length(Hitch.DatasetArray);
nAxles = numel(Axle.type{iUnit});
index = 1;
%
Table.Parameter{index} = 'Vehicle Identification Number (VIN)';
Table.RequiredValue{index} = 'VIN';
Table.MeasuredValue{index} = '\phantom{XXXXXXXXXXXXXXXXXXXXXXXXX}';
index = index + 1;
%
Table.Parameter{index} = 'Registration Plate Number';
Table.RequiredValue{index} = 'Number Plate';
Table.MeasuredValue{index} = '';
index = index + 1;
%
if iUnit == 1 % prime mover
    %
    nSteerAxles = numel(Axle.Grouping{1}); 
    nRearAxles = numel(Axle.Grouping{2});
    %
    Table.Parameter{index} = 'Model';
    Table.RequiredValue{index} = '\pmDescr{}';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Number of front steer axles'; 
    Table.RequiredValue{index} = num2str(nSteerAxles);
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Number of rear axles';
    Table.RequiredValue{index} = num2str(nRearAxles);
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
else % other units
    %
    Table.Parameter{index} = 'Number of axles';
    Table.RequiredValue{index} = num2str(nAxles);
    Table.MeasuredValue{index} = '';
    index = index + 1;    
end
%
nAxlesOnUnit = length(Axle.UnitCellArray{iUnit}); % Same structure as Tyre.sizes
if all(strcmp(Tyre.sizes{iUnit}{1}, Tyre.sizes{iUnit}))
    Table.Parameter{index} = 'Tyres on all axles';    
    tempTyreSize = regexprep(Tyre.sizes{iUnit}{1}, '(duals) \d+ spacing', '$1');
    Table.RequiredValue{index} = tempTyreSize;
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Tyres on axle %d \\tnote{1}', iAxle);
        tempTyreSize = regexprep(Tyre.sizes{iUnit}{iAxle}, '(duals) \d+ spacing', '$1');
        Table.RequiredValue{index} = tempTyreSize + " " + Tyre.loadindices{iUnit}{iAxle};
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
%
if all(strcmp(Axle.springType{iUnit}{1}, Axle.springType{iUnit}))
    Table.Parameter{index} = 'Suspension type on all axles';
    Table.RequiredValue{index} = Axle.springType{iUnit}{1};
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Suspension type on axle %d', iAxle);
        Table.RequiredValue{index} = Axle.springType{iUnit}{iAxle};
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
%
if all(strcmp(Axle.trackWidth{iUnit}{1}, Axle.trackWidth{iUnit}))
    Table.Parameter{index} = 'Track width of all axles';
    Table.RequiredValue{index} = num2str(Axle.trackWidth{iUnit}{1});
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Track width of axle %d', iAxle);
        Table.RequiredValue{index} = num2str(Axle.trackWidth{iUnit}{iAxle});
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
%
if all(strcmp(Axle.stabiliserModel{iUnit}{1}, Axle.stabiliserModel{iUnit}))
    Table.Parameter{index} = 'Stabiliser type on all axles';
    if strcmp(Axle.stabiliserModel{iUnit}{1}, '-')
        tempTableRequiredValue = "none";
    else
        tempTableRequiredValue = Axle.stabiliserModel{iUnit}{1};
    end    
    Table.RequiredValue{index} = tempTableRequiredValue;
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Stabiliser type on axle %d', iAxle);       
        if strcmp(Axle.stabiliserModel{iUnit}{iAxle}, '-')
            tempTableRequiredValue = "none";
        else
            tempTableRequiredValue = Axle.stabiliserModel{iUnit}{iAxle};
        end    
        Table.RequiredValue{index} = tempTableRequiredValue;        
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
%
if iUnit == 1 % prime mover
    for iAxle = 2 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Distance from 1st steer axle to axle %d', iAxle);
        Table.RequiredValue{index} = num2str(1000*Axle.XPositionArray(iAxle)); % A bit dirty but it works
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
else
    for iAxle = 1 : nAxlesOnUnit
        Table.Parameter{index} = sprintf('Distance from hitch to axle %d', iAxle);
        Table.RequiredValue{index} = num2str(1000*Axle.XPositionArray(Axle.Grouping{iUnit+1}(iAxle))); % need to add +1 to iUnit
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end    
end
%
hitchPresent = (iUnit <= nHitches);
if hitchPresent
    temp = strsplit(Hitch.DatasetArray{iUnit}{:}, ' (');
    hitchType = temp{1};        
    if strcmp(hitchType, '5th Wheel')
        Table.Parameter{index} = sprintf('%s forward from centre of rear axle group', hitchType);
        Table.RequiredValue{index} = num2str((mean(Axle.XPositionArray(Axle.Grouping{1+iUnit}))-Hitch.XPositionArray(iUnit))*1000);
        Table.MeasuredValue{index} = '';
    else
        Table.Parameter{index} = sprintf('%s back from last axle', hitchType);
        Table.RequiredValue{index} = num2str((-Axle.XPositionArray(Axle.Grouping{1+iUnit}(end))+Hitch.XPositionArray(iUnit))*1000);
        Table.MeasuredValue{index} = '';
    end
    index = index + 1;
    %
    Table.Parameter{index} = sprintf('%s height (laden)', hitchType);
    Table.RequiredValue{index} = num2str(Hitch.ZPositionArray(iUnit)*1000);
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = sprintf('%s height (unladen hitched)', hitchType);
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
end
%
if iUnit == 1 % prime mover
    %
    Table.Parameter{index} = 'Maximum front overhang';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Maximum overall vehicle length';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
elseif ~any(iUnit == dollys)
    %
    Table.Parameter{index} = 'Maximum front trailer projection from hitch';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;   
    %
    Table.Parameter{index} = 'Maximum rear trailer projection from rear axle';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Maximum height at trailer front';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;   
    %
    Table.Parameter{index} = 'Maximum height at trailer rear';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Maximum trailer width';
    Table.RequiredValue{index} = '2600';
    Table.MeasuredValue{index} = '';
    index = index + 1;    
else
    %
    Table.Parameter{index} = 'Maximum dolly width';
    Table.RequiredValue{index} = '2600';
    Table.MeasuredValue{index} = '';
    index = index + 1;         
end
%
if iUnit == 1 % prime mover
    %
    Table.Parameter{index} = '"Abnormal vehicle" signage';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Ensure correct gearbox and final drive';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Load measurement system';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'RTMS and PBS boards';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Amber lights';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Marker lights and reflectors';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;    
    %
elseif iUnit == nUnits % last unit
    %
    Table.Parameter{index} = '"Abnormal vehicle" signage';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;    
    %
    Table.Parameter{index} = 'Marker lights and reflectors';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;    
    %
    Table.Parameter{index} = 'EBS/ABS';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %  
else
    %
    Table.Parameter{index} = 'Marker lights and reflectors';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;    
    %
    Table.Parameter{index} = 'EBS/ABS';
    Table.RequiredValue{index} = 'yes';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
end
%

Table.data = [Table.Parameter(:) Table.RequiredValue(:) Table.MeasuredValue(:)];

Table.Headings = {'\textbf{Parameter}' '\textbf{Required Value}' '\textbf{Measured Value}'};

% Compiling the structure fields required by latexTable
Table.footNotes = {'\item[1] tyre load indices are minimum required values'};
Table.data = [Table.Headings; Table.data];
Table.tableCaption = ['Commissioning Table of Unit ' num2str(iUnit)];
Table.tableLabel = ['CommissioningTableOfUnit' num2str(iUnit)];
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end