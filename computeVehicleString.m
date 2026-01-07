%% Function Description
%
% Use data extracted from TruckSim to determine the vehicle string for the combination
%
%% Inputs
%
% * Axle
% * Tyre
% * Hitch
% * Sprung
% * Combination
%
%% Outputs
%
% * Combination: appended with vehicleStringCell and combinationVehicleString
%
%% Change Log
%
% [0.2.0] - 2017-08-22
%
% * Added Dolly support
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function Combination = computeVehicleString(Axle, Tyre, Hitch, Sprung, Combination)

% Extract whether the tyres or duals or singles for all axles
tyreDualsOrSingles = editCombinationCellSplitText(Tyre.sizes, {'(', ')', ' '}, 2);

for iUnit = 1:Sprung.numberOffUnits
    % Initialise the vehicle string for the unit in question
    vehicleString{iUnit} = [];
    %Determine the indices of the axles in the unit
    indicesOfAxlesInUnit = find(Axle.UnitAndGroup(:,2) == iUnit);
    % Determine the first axle group within the unit
    currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(1),3);
    
    nAxlesInGroup = length(indicesOfAxlesInUnit);
    
    for iAxle = 1:nAxlesInGroup
        % Determine the first axle group within the unit
        axleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
        % Process the axle group main symbol and current axle dual tyre status
        axleType = Axle.type{iUnit}{iAxle};
        axleSpringType = Axle.springType{iUnit}{iAxle};
        dualsOrSingles = tyreDualsOrSingles{iUnit}{iAxle};
        %% First axle (if axle group has more than 1 axle)
        if iAxle == 1
            % Determine main grouping from axle type
            switch axleType
                case 'Steer'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'S('];                 
                case 'Drive'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'D('];
                case 'Trailer'
                    vehicleString{iUnit} = [vehicleString{iUnit} 't('];
                case 'Tag'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').T('];
                case 'Dolly'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'y('];
            end
            % Add duals or singles for the axle
            if nAxlesInGroup == 1 % If only one axle, the parenthesis needs to be closed
                switch dualsOrSingles
                    case 'duals'
                        vehicleString{iUnit} = [vehicleString{iUnit} 'd)'];
                    case 'singles'
                        vehicleString{iUnit} = [vehicleString{iUnit} 's)'];
                end
            else
                switch dualsOrSingles
                    case 'duals'
                        vehicleString{iUnit} = [vehicleString{iUnit} 'd'];
                    case 'singles'
                        vehicleString{iUnit} = [vehicleString{iUnit} 's'];
                end
            end
            currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
            %% Next axle if in the same axle group (excluding the last axle in the unit)
        elseif iAxle > 1 && iAxle ~= length(indicesOfAxlesInUnit) && axleGroup == currentAxleGroup
            % Special formatting if the axle is a tag axle - this still needs to be tested when the case arises
            if strcmp(axleType,'Tag')
                vehicleString{iUnit} = [vehicleString{iUnit} ')T('];
            end
            % Add duals or singles for the axle
            switch dualsOrSingles
                case 'duals'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'd'];
                case 'singles'
                    vehicleString{iUnit} = [vehicleString{iUnit} 's'];
            end
            
            currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
            %% Next axle if in a different axle group  (excluding the last axle in the unit)
        elseif iAxle > 1 && iAxle ~= length(indicesOfAxlesInUnit) && axleGroup ~= currentAxleGroup
            % Determine main grouping from axle type
            switch axleType
                case 'Steer'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').S('];
                case 'Drive'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').D('];
                case 'Trailer'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').t('];
                case 'Tag'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').T('];
                case 'Dolly'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').y('];
            end
            
            % Add duals or singles for the axle
            switch dualsOrSingles
                case 'duals'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'd'];
                case 'singles'
                    vehicleString{iUnit} = [vehicleString{iUnit} 's'];
            end
            
            currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
            %% Last axle for the unit
        elseif iAxle == length(indicesOfAxlesInUnit) && axleGroup == currentAxleGroup
            % Special formatting if the axle is a tag axle - this still needs to be tested when the case arises
            if strcmp(axleType,'Tag')
                vehicleString{iUnit} = [vehicleString{iUnit} ')T('];
            elseif strcmp(axleType,'Self-Steer')
                vehicleString{iUnit} = [vehicleString{iUnit} 'S('];
            end
            
            % Add duals or singles for the axle
            switch dualsOrSingles
                case 'duals'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'd)'];
                case 'singles'
                    vehicleString{iUnit} = [vehicleString{iUnit} 's)'];
            end
            
            if strcmp(axleType,'Self-Steer')
                vehicleString{iUnit} = [vehicleString{iUnit} ')'];
            end
            
            currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
            
        elseif iAxle == length(indicesOfAxlesInUnit)
            switch axleType
                case 'Steer'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').S('];
                case 'Self-Steer'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').S('];                    
                case 'Drive'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').D('];
                case 'Trailer'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').t('];
                case 'Tag'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').T('];
                case 'Dolly'
                    vehicleString{iUnit} = [vehicleString{iUnit} ').y('];
            end
            
            % Add duals or singles for the axle
            switch dualsOrSingles
                case 'duals'
                    vehicleString{iUnit} = [vehicleString{iUnit} 'd)'];
                case 'singles'
                    vehicleString{iUnit} = [vehicleString{iUnit} 's)'];
            end
            
            currentAxleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
            
        end
    end
end

%% Adding underlining for steel suspensions

axleGroup = 1;

listOfAxleSpringTypes = convertCellArrayOfStringsToList(Axle.springType);

for iUnit = 1:Sprung.numberOffUnits
    currentVehicleString = vehicleString{iUnit};
    % Split the vehicle string for the unit into axle group strings
    axleGroupString = strsplit(currentVehicleString, '.');
    % Loop through the axle groups in the unit, and if steel, add underlining
    underlinedVehicleString = [];
    for iAxleGroup = 1:length(axleGroupString)
        % Find the axle # of the first axle in the group
        axleNum = Axle.Grouping{axleGroup}(1);
        
        % Determine if steel suspension and if so underline the vehicle string for the axle group
        
        if strcmp(listOfAxleSpringTypes{axleNum}, 'Steel')
            underlinedVehicleString = [underlinedVehicleString '\underline{' axleGroupString{iAxleGroup} '}'];
        else
            underlinedVehicleString = [underlinedVehicleString axleGroupString{iAxleGroup}];
        end
        
        if iAxleGroup < length(axleGroupString)
            underlinedVehicleString = [underlinedVehicleString '.'];
        end
        
        % Move on to the next axle group
        axleGroup = axleGroup + 1;
    end
    
    vehicleString{iUnit} = underlinedVehicleString;
end

%% Each cell contains the vehicle string for that unit
Combination.vehicleStringCell = vehicleString;

%% Combining into the overall vehicle string
for iUnit = 1:Sprung.numberOffUnits
    
    if iUnit == 1
        Combination.combinationVehicleString = Combination.vehicleStringCell{iUnit};
    else
        switch Hitch.RollCoupledArray(iUnit-1)
            case 1 % 5th wheel
                Combination.combinationVehicleString = [Combination.combinationVehicleString '-' ...
                    Combination.vehicleStringCell{iUnit}];
            case 0 % Pintle
                Combination.combinationVehicleString = [Combination.combinationVehicleString '+' ...
                    Combination.vehicleStringCell{iUnit}];
        end
    end
    
end

end