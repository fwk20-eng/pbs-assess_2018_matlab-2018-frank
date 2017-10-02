%% Function Description
% 
% Determines axle grouping using a max axle spacing distance. Beyond the max axle spacing distance, the axles are split
% into a new axle group.
% 
%% Inputs
% 
% * axleXDistances: Vector of axle longitudinal distances relative to each other.
% * maxSpacing: Number indicating maximum axle spacing to be considered within the same axle group [mm]
%% Outputs
% 
% * axleGrouping: cell array of vectors {[axle group 1]; [axle group 2]; [axle group 3]} e.g: {[1]; [2,3]; [4,5]} 
% 
%% Change Log
% 
% [0.1.0] - 2017-04-20
% 
% *Added*
% 
% * Moved from runTruckSimDataExtraction to a standalone function in the local folder

function axleGrouping = computeAxleGrouping(axleXDistances, maxSpacing)

    MAX_AXLE_GROUP_DIST_MM = maxSpacing; % [mm]
    
    nAxles = length(axleXDistances);

    % Initialise the axle group to the first axle group.
    nAxleGroup = 1;

    % The first steer axle will always be in the first axle group
    axleGrouping{nAxleGroup} = 1;

    for iAxle = 2 : nAxles
        axleDistanceFromPrevious = axleXDistances(iAxle) - axleXDistances(iAxle-1);
        % Move to the next axle group if the axle spacing is > MAX_AXLE_GROUP_DIST_MM and initialise axle group vector
        if axleDistanceFromPrevious > MAX_AXLE_GROUP_DIST_MM
            nAxleGroup = nAxleGroup + 1;
            axleGrouping{nAxleGroup} = [];
        end

        axleGrouping{nAxleGroup} = [axleGrouping{nAxleGroup}, iAxle];
    end

    % Transposing the matrix to suit the post processor.
    axleGrouping = axleGrouping';

end