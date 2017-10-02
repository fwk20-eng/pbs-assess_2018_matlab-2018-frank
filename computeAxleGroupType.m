%% Function Description
%
% Function to determine the axle configuration of the axle group for each axle
%
%% Inputs
%
% * Axle: structure with the following elements required
% * Axle.NumberOff: Number of axles in the combination
% * Axle.UnitAndGroup: Array in the form [axle number, axle unit, axle group]
% * Axle.Grouping: Cell array of the form {[axles in axle group 1];[axles in axle group 2];[axles in axle group 3]...}
%
%% Outputs
%
% * axleConfiguration: Axle configuration in the standard combination cell array format.
%
%% Change Log
%
% [0.2.0] - 2017-05-07
%
% *Fixed*
%
% * Changed the output cell array to be an 1 x nU cell array for nU units, within each main cell containing 1 x nA cell
% array for nA axles. This is to conform to the decided upon combination cell array as of 2017-05-07.
%
% [0.1.0] - 2017-05-05
%
% *Added*
%
% * First code

function axleConfiguration = computeAxleGroupType(Axle)

nCurrentUnit = 1;
axleConfiguration{1} = [];

for iAxle = 1:Axle.NumberOff
    
    % Find axle unit and group
    nAxleUnit = Axle.UnitAndGroup(iAxle, 2);
    nAxleGroup = Axle.UnitAndGroup(iAxle, 3);
    nAxlesInGroup = length(Axle.Grouping{nAxleGroup});
    
    % Initialise the cell array for each unit
    if nAxleUnit > nCurrentUnit
        axleConfiguration{nAxleUnit} = [];
        nCurrentUnit = nCurrentUnit + 1;
    end
    
    switch nAxlesInGroup
        case 1
            axleConfiguration{nAxleUnit} = [axleConfiguration{nAxleUnit} {'Single'}];
        case 2
            axleConfiguration{nAxleUnit} = [axleConfiguration{nAxleUnit} {'Tandem'}];
        case 3
            axleConfiguration{nAxleUnit} = [axleConfiguration{nAxleUnit} {'Tridem'}];
        case 4
            axleConfiguration{nAxleUnit} = [axleConfiguration{nAxleUnit} {'Quad'}];
    end
end

end