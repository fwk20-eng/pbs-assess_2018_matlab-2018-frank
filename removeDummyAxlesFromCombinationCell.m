%% Function Description
%
% This function removes dummy axle entries from a standard pbs combination cell array.
%
%% Inputs
%
% * combinationCell: The combination cell in which you want to remove dummy axle data
% * isRealAxleCell: A combination cell with booleans (1 = real axle, 0 = dummy axle) for all axles in the model
%
%% Outputs
%
% * removedDummyAxleCell: A modified version of the combinationCell with all dummy axle data removed. Any axle which is
% indicated as a 0 in the same index in the isRealAxleCell will be removed.
%
%% Change Log
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * First code

function removedDummyAxleCell = removeDummyAxlesFromCombinationCell(combinationCell, isRealAxleCell)

nUnits = length(combinationCell);

for iUnit = 1 : nUnits
    iValidAxle = 0;
    nAxles = length(combinationCell{iUnit});
    for iAxle = 1 : nAxles
        if isRealAxleCell{iUnit}{iAxle} == 1
            iValidAxle = iValidAxle + 1;
            removedDummyAxleCell{iUnit}{iValidAxle} = combinationCell{iUnit}{iAxle};
        end
    end
end

end