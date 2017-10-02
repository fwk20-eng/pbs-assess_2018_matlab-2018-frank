%% Function Description
% 
% This function will search through a standard vehicle combination cell array and determine the unit number for a
% specified parameter (e.g axle number from the Axle.Grouping cell array)
% 
%% Inputs
% 
% * axleNum: Axle number to look for
% * axleGrouping: Axle grouping array where each row is an axle group
% 
%% Outputs
% 
% * nAxleGroup: This will be the axle group to which the axle belongs
% 
%% Change Log
% 
% [0.1.0] - 2017-05-05
% 
% *Added*
% 
% * First code

function nAxleGroup = computeAxleGroup(axleNum, axleGrouping)

    nAxleGroup = find(cellfun(@(x) any(x(:) == axleNum), axleGrouping), 1);

end