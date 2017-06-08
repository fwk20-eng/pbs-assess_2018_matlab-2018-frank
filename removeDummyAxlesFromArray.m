%% Function Description
%
% This function extracts only real axles from the supplied array and generates an array for the axle data without any
% dummy axles
%
%% Inputs
%
% * array: An array containing data for each axle
% * isRealAxleArray: An array containing booleans for each axle (1 = real, 0 = dummy)
%
%% Outputs
%
% * modifiedArray: A new array with all dummy axle data removed. It should look as if the dummy axles were never
% included in the model
%
%% Change Log
%
% [0.1.0] - 2017-06-02
%
% *Added*
%
% * First code

function modifiedArray = removeDummyAxlesFromArray(array, isRealAxleArray)

iValidAxle = 0;

for iAxle = 1: length(isRealAxleArray)
    if isRealAxleArray(iAxle) == 1
        iValidAxle = iValidAxle + 1;
        modifiedArray(iValidAxle) = array(iAxle);
    end
end

end