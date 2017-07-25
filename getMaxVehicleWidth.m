%% Function Description
% 
% This function determines the maximum vehicle width from the reference points of the combination
% 
%% Inputs
% 
% * referencePointsCell: cell array of reference points as extracted by getReferencePoints
% * nUnits: number of vehicle units
% 
%% Outputs
% 
% * vehicleMaxWidth: Maximum width of the vehicle as determined by the widest reference point present on the combination
% 
%% Change Log
%
%
% [0.1.0] - 2017-04-29
% 
% Added
% 
% * First code

function vehicleMaxWidth = getMaxVehicleWidth(referencePointsCell, nUnits)

combinedYReferencePoints = [];

for iUnit = 1 : nUnits
    combinedYReferencePoints = [combinedYReferencePoints; referencePointsCell{iUnit,2}];
end

combinedYReferencePoints = abs(combinedYReferencePoints).*2;

vehicleMaxWidth = max(combinedYReferencePoints);

end