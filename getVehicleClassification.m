%% Function Description
%
% Use data extracted from TruckSim to determine the vehicle classification for the combination
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
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function Combination = getVehicleClassification(Axle, Tyre, Hitch, Sprung, Combination)


for iUnit = 1:Sprung.numberOffUnits
    
    Combination.vehicleClassification{iUnit} = [];
    indicesOfAxlesInUnit = find(Axle.UnitAndGroup(:,2) == iUnit);
    
    for iAxle = 1:length(indicesOfAxlesInUnit)
        axleGroup = Axle.UnitAndGroup(indicesOfAxlesInUnit(iAxle),3);
        % Calculate the number of axles in the first axle group
        if iAxle == 1
            % Number of axles in group 1 on the current unit
            nAxles = sum(Axle.UnitAndGroup(:,3) == axleGroup);
            Combination.vehicleClassification{iUnit} = [Combination.vehicleClassification{iUnit} ...
                int2str(nAxles)];
            currentAxleGroup = axleGroup;
            % If moved on to a new axle group, then calculate number of axles in the new axle group
        else if iAxle > 1 && axleGroup ~= currentAxleGroup
                nAxles = sum(Axle.UnitAndGroup(:,3) == axleGroup);
                Combination.vehicleClassification{iUnit} = [Combination.vehicleClassification{iUnit} '.'...
                    int2str(nAxles)];
                currentAxleGroup = axleGroup;
            end
        end
    end
    
end

for iUnit = 1:Sprung.numberOffUnits
    
    if iUnit == 1
        Combination.combinationClassification = Combination.vehicleClassification{iUnit};
    else
        switch Hitch.RollCoupledArray(iUnit-1)
            case 1 % 5th wheel
                Combination.combinationClassification = [Combination.combinationClassification '-' ...
                    Combination.vehicleClassification{iUnit}];
            case 0 % Pintle
                Combination.combinationVehicleString = [Combination.combinationVehicleString '+' ...
                    Combination.vehicleClassification{iUnit}];
        end
    end
    
end

end