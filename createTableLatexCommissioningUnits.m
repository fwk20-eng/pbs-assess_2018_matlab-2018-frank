%% Function Description
%
% Compiles all of the data for table one into a single structure that can be used to generate a latex table with the latexTable function
%
%% Inputs
%
% * Tyre
% * Axle
% * Hitch
% * dollys not used as the variable relates to the sprung mass index
% * refPointsLadenCell
% * iVehicleUnit
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
function [PBSreportTable] = createLatexTableCommissioningUnits(Tyre, Axle, Hitch, dollys, refPointsLadenCell, iVehicleUnit)
%
nVehicleUnits = str2num(Axle.VehicleUnitCellArray{end}{end}); % number of vehicle units
nSprungUnits = length(Axle.UnitCellArray); % number of sprung units
unitStr = num2str(iVehicleUnit);
nAxles = sum(strcmp([Axle.VehicleUnitCellArray{:}], unitStr));
index = 1; % indices for the rows of the table
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
% 1. Number of Axles
if iVehicleUnit == 1 % prime mover
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
% 2. Tyre sizes
tyreSizesList = {};
tyreLoadIndicesList = {};
% Loop through each sub-cell
for i = 1:numel(Axle.VehicleUnitCellArray)
    mask = strcmp(Axle.VehicleUnitCellArray{i}, unitStr);
    tyreSizesList = [tyreSizesList, Tyre.sizes{i}(mask)]; %#ok<AGROW>
    tyreLoadIndicesList = [tyreLoadIndicesList, Tyre.loadindices{i}(mask)]; %#ok<AGROW>
end
if all(strcmp(tyreSizesList{1}, tyreSizesList)) && all(strcmp(tyreLoadIndicesList{1}, tyreLoadIndicesList))
    Table.Parameter{index} = 'Tyres on all axles \tnote{1}';
    tempTyreSize = regexprep(tyreSizesList{1}, '(duals) \d+ spacing', '$1');
    Table.RequiredValue{index} = tempTyreSize + ", " + tyreLoadIndicesList{1};
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxles
        Table.Parameter{index} = sprintf('Tyres on axle %d \\tnote{1}', iAxle);
        tempTyreSize = regexprep(tyreSizesList{iAxle}, '(duals) \d+ spacing', '$1');
        Table.RequiredValue{index} = tempTyreSize + ", " + tyreLoadIndicesList{iAxle};
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
% 3. Suspension types
springTypesList = {};
% Loop through each sub-cell
for i = 1:numel(Axle.VehicleUnitCellArray)
    mask = strcmp(Axle.VehicleUnitCellArray{i}, unitStr);
    springTypesList = [springTypesList, Axle.springType{i}(mask)]; %#ok<AGROW>
end
if all(strcmp(springTypesList{1}, springTypesList))
    Table.Parameter{index} = 'Suspension type on all axles';
    Table.RequiredValue{index} = springTypesList{1};
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxles
        Table.Parameter{index} = sprintf('Suspension type on axle %d', iAxle);
        Table.RequiredValue{index} =springTypesList{iAxle};
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
% 4. Track widths
trackWidthsList = {};
% Loop through each sub-cell
for i = 1:numel(Axle.VehicleUnitCellArray)
    mask = strcmp(Axle.VehicleUnitCellArray{i}, unitStr);
    trackWidthsList = [trackWidthsList, Axle.trackWidth{i}(mask)]; %#ok<AGROW>
end
if all(strcmp(trackWidthsList{1}, trackWidthsList))
    Table.Parameter{index} = 'Track width of all axles';
    Table.RequiredValue{index} = num2str(trackWidthsList{1});
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxles
        Table.Parameter{index} = sprintf('Track width of axle %d', iAxle);
        Table.RequiredValue{index} = num2str(trackWidthsList{iAxle});
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
% 5. Stabiliser types
stabiliserModelsList = {};
% Loop through each sub-cell
for i = 1:numel(Axle.VehicleUnitCellArray)
    mask = strcmp(Axle.VehicleUnitCellArray{i}, unitStr);
    stabiliserModelsList = [stabiliserModelsList, Axle.stabiliserModel{i}(mask)]; %#ok<AGROW>
end
if all(strcmp(stabiliserModelsList{1}, stabiliserModelsList))
    Table.Parameter{index} = 'Stabiliser type on all axles';
    if strcmp(stabiliserModelsList{1}, '-')
        tempTableRequiredValue = "none";
    else
        tempTableRequiredValue = stabiliserModelsList{1};
    end
    Table.RequiredValue{index} = tempTableRequiredValue;
    Table.MeasuredValue{index} = "";
    index = index +1;
else
    for iAxle = 1 : nAxles
        Table.Parameter{index} = sprintf('Stabiliser type on axle %d', iAxle);
        if strcmp(stabiliserModelsList{iAxle}, '-')
            tempTableRequiredValue = "none";
        else
            tempTableRequiredValue = stabiliserModelsList{iAxle};
        end
        Table.RequiredValue{index} = tempTableRequiredValue;
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
% 6. Distance to axles
vehicleUnitsFlat = [Axle.VehicleUnitCellArray{:}]; % Flatten VehicleUnitCellArray into a simple cell array of strings
mask = strcmp(vehicleUnitsFlat, num2str(iVehicleUnit)); % Build a logical mask for where it matches iVehicleUnit
AxleXposList=Axle.XPositionArray(mask);
if iVehicleUnit == 1 % prime mover
    for iAxle = 2 : nAxles
        Table.Parameter{index} = sprintf('Distance from 1st steer axle to axle %d', iAxle);
        Table.RequiredValue{index} = num2str(1000*AxleXposList(iAxle)); % A bit dirty but it works
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
else
    for iAxle = 1 : nAxles
        Table.Parameter{index} = sprintf('Distance from hitch or 5th wheel to axle %d', iAxle);
        Table.RequiredValue{index} = num2str(1000*AxleXposList(iAxle));
        Table.MeasuredValue{index} = "";
        index = index + 1;
    end
end
% 7. Hitch longitudinal position, laden height, and unladen height
mask = cellfun(@(c) any(strcmp(c, unitStr)), Axle.VehicleUnitCellArray); % Check each group: does it contain this unit?
iGroups = find(mask); % Find matching indices
for iHitch = 1 : length (iGroups)
    iGroup = iGroups(iHitch);
    hitchPresent = (iGroup < nSprungUnits); % The last sprung mass does not have a hitch
    if hitchPresent
        temp = strsplit(Hitch.DatasetArray{iGroup}{:}, ' (');
        hitchType = temp{1};
        if contains(hitchType, '5th Wheel')
            Table.Parameter{index} = sprintf('%s forward from centre of rear axle group', hitchType);
            Table.RequiredValue{index} = num2str((mean(Axle.XPositionArray(Axle.Grouping{1+iGroup}))-Hitch.XPositionArray(iGroup))*1000);
            Table.MeasuredValue{index} = '';
        elseif contains(hitchType, 'Pintle')
            Table.Parameter{index} = sprintf('%s back from last axle', hitchType);
            Table.RequiredValue{index} = num2str((-Axle.XPositionArray(Axle.Grouping{1+iGroup}(end))+Hitch.XPositionArray(iGroup))*1000);
            Table.MeasuredValue{index} = '';
        else
            warning('PBS:HitchType', 'Could not determine hitch type for vehicle %d.', iVehicleUnit);
            Table.Parameter{index} = sprintf('%s forward from centre of rear axle group', hitchType);
            Table.RequiredValue{index} = num2str((mean(Axle.XPositionArray(Axle.Grouping{1+iGroup}))-Hitch.XPositionArray(iGroup))*1000);
            Table.MeasuredValue{index} = '';            
        end
        index = index + 1;
        %
        Table.Parameter{index} = sprintf('%s height (laden)', hitchType);
        Table.RequiredValue{index} = num2str(Hitch.ZPositionArray(iGroup)*1000);
        Table.MeasuredValue{index} = '';
        index = index + 1;
        %
        Table.Parameter{index} = sprintf('%s height (unladen hitched)', hitchType);
        Table.RequiredValue{index} = 'XXXX';
        Table.MeasuredValue{index} = '';
        index = index + 1;
    end
end
% 8. Overhangs - check axleTypesList to find dollies
axleTypesList = {};
% Loop through each sub-cell
for i = 1:numel(Axle.VehicleUnitCellArray)
    mask = strcmp(Axle.VehicleUnitCellArray{i}, unitStr);
    axleTypesList = [axleTypesList, Axle.type{i}(mask)]; %#ok<AGROW>
end
if iVehicleUnit == 1 % prime mover
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
elseif all(strcmp(axleTypesList, 'Dolly'))
    %
    Table.Parameter{index} = 'Maximum dolly width';
    Table.RequiredValue{index} = '2600';
    Table.MeasuredValue{index} = '';
    index = index + 1;
else
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
    Table.Parameter{index} = 'Maximum height (unladen hitched) at trailer front';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Maximum height (unladen hitched) at trailer rear';
    Table.RequiredValue{index} = 'XXXX';
    Table.MeasuredValue{index} = '';
    index = index + 1;
    %
    Table.Parameter{index} = 'Maximum trailer width';
    Table.RequiredValue{index} = '2600';
    Table.MeasuredValue{index} = '';
    index = index + 1;
end
%
if iVehicleUnit == 1 % prime mover
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
elseif iVehicleUnit == nVehicleUnits % last unit
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
Table.tableCaption = ['Commissioning Table of Vehicle Unit ' num2str(iVehicleUnit)];
Table.tableLabel = ['CommissioningTableOfUnit' num2str(iVehicleUnit)];
Table.booktabs = 0;
Table.tableBorders = 1;

PBSreportTable = latexTable(Table);
end