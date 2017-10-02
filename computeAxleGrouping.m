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
% * axleUnitAndGroup: array of the format [axle number, axle unit, axle group]
%
%% Change Log
%
% [0.4.0]
%
% *Added*
%
% * Support for dummy axles
%
% [0.3.0] 2017-05-08
%
% *Added*
%
% * Cell array for axles indicating the unit for each axle in the same format as the standard combination cell. This
% allows for easier generation of the latex tables.
%
% [0.2.0] 2017-05-04
%
% *Fixed*
%
% * Improved functionality to determine axle grouping from unit as well as distance from previous axle.
% * Function should now work for any vehicle combination
%
% [0.1.0] - 2017-04-20
%
% *Added*
%
% * Moved from runTruckSimDataExtraction to a standalone function in the local folder

function [axleGroupCell, axleUnitAndGroup, axleUnitCellArray] = computeAxleGrouping(parFileData, axleXDistances, ...
    maxSpacing, Dummy)

MAX_AXLE_GROUP_DIST_MM = maxSpacing; % [mm]

% Determine the indices of the variable within the end par file
varIndices = indexTextArray(parFileData, '\<LX_AXLE');

% If there are dummy axles, modify the varIndices variable 
if Dummy.isDummyAxle
    varIndices{1,2} = removeDummyAxlesFromArray(varIndices{1,2}, Dummy.isRealAxleArray);
end

% Determine the number of variables named the same as searchText
nAxles = length(varIndices{1,2});

% Initialise the first axle group
axleGroupCell{1,:} = [];
axleUnitAndGroup = [];

% Start on the first unit, in the first axle group with the first axle
iUnit = 1;
iAxle = 0;
nAxleGroup = 1;

% Loop through each axle and determine which unit it resides in
for iAxle = 1 : nAxles
    % This will return 'unit,axlenumber'
    axleUnitAndNumber = regexpFindTextBetweenText(parFileData{varIndices{1,2}(iAxle)},'\(', '\)');
    axleUnitAndNumberArray = strsplit(axleUnitAndNumber{:}, ',');
    
    nUnit = str2double(axleUnitAndNumberArray(1));
    
    % Initialise unit array if it does not exist and move to next unit
    if nUnit > iUnit
        % Move to the next axle group since it is a new unit
        nAxleGroup = nAxleGroup + 1;
        % Initialise the next axle group
        axleGroupCell{nAxleGroup,:} = [];
        % Move to the next unit
        iUnit = iUnit + 1;
    elseif nUnit == iUnit
        % Once the first axle is assigned, check if any of the following axles are far enough to be in the next group
        if iAxle > 1
            axleDistanceFromPrevious = axleXDistances(iAxle) - axleXDistances(iAxle-1);
            if axleDistanceFromPrevious > MAX_AXLE_GROUP_DIST_MM
                % Move to the next axle group since it is a new axle group
                nAxleGroup = nAxleGroup + 1;
                axleGroupCell{nAxleGroup,:} = [];
            end
        end
    end
    
    axleGroupCell{nAxleGroup,:} = [axleGroupCell{nAxleGroup,:} iAxle];
    
    axleUnitAndGroup = [axleUnitAndGroup; iAxle, nUnit, nAxleGroup];
    
end

% Loop through axleUnitAndGroup
currentUnit = 1;
iAxleIndex = 0;

for iAxle = 1 : nAxles
    
    % Extract the unit
    iUnit = axleUnitAndGroup(iAxle, 2);
    
    if iUnit == currentUnit
        iAxleIndex = iAxleIndex + 1;
    else
        iAxleIndex = 1;
        currentUnit = iUnit;
    end
    
    axleUnitCellArray{:,iUnit}{:,iAxleIndex} = int2str(iUnit);
    
end

end