%% Function Description
%
% This function will determine whether or not the combination has dummy axles and generate logic arrays that can be used
% to process extracted data from TruckSim and remove any dummy axles.
%
%% Inputs
%
% * suspensionDataCell: a pbs combination cell that includes details on either the suspension compliance or kinematics.
% It must include datasets that begin with "Dummy" where there is a dummy suspension dataset.
%
%% Outputs
%
% * Dummy: a structure with the following items
% * isRealAxleCell: A cell with booleans in the place of each axle 1 = real, 0 = dummy
% * isRealAxleArray: An array of real axles with booleans in the place of each axle 1 = real, 0 = dummy
% * isDummyAxle: A boolean to indicate whether there are dummy axles in the combination or not
% * isRealAxleIndex: A list containing the real axle indices. E.g in a 13 axle combination, only axles 1,3,6,7,10,11 are
% real, then isRealAxleIndex = [1,3,6,7,10,11]
%
%% Change Log
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function [Dummy] = findDummyAxles(suspensionDataCell)

Dummy.isRealAxleCell = {};
Dummy.isRealAxleArray = [];
Dummy.isDummyAxle = 0;

nUnits = length(suspensionDataCell);

for iUnit = 1 : nUnits
    nAxles = length(suspensionDataCell{iUnit});
    for iAxle = 1 : nAxles
        if strncmp(suspensionDataCell{iUnit}{iAxle}, 'Dummy', 5)
            Dummy.isRealAxleCell{iUnit}{iAxle} = 0;
            % indicate that there are indeed dummy axles in the model
            Dummy.isDummyAxle = 1;
        else
            Dummy.isRealAxleCell{iUnit}{iAxle} = 1;
        end
    end
    Dummy.isRealAxleArray = [Dummy.isRealAxleArray, Dummy.isRealAxleCell{iUnit}{:}];
end

Dummy.isRealAxleIndex = [];
for iAxle = 1:length(Dummy.isRealAxleArray)
    if Dummy.isRealAxleArray(iAxle)
        Dummy.isRealAxleIndex = [Dummy.isRealAxleIndex iAxle];
    end
end
end