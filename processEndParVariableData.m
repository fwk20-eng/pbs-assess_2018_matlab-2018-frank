%% Function Description
% 
% This function takes a cell array of strings containing the lines of an end par file and array of indices. It then
% outputs formatted details on the contents of the variables residing at the indices provided in the array of indices.
% 
%% Inputs
% 
% * *endParFileData*: a cell array of strings containing each line of the end par file
% * *varIndices*: variable indices found using indexTextArray foutput in the form | variable name | [indices] |
% 
%% Outputs
% 
% * *varDetails*: Cell array of strings of the form | variable values | units | variable name |
% 
%% Change Log
% 
% [0.1.0] - 2017-04-20
% 
% Added
% 
% * Moved function from getTruckSimSimulationData to Matlab_Global_Toolbox as a standalone function
function varDetails = processEndParVariableData(endParFileData, varIndices)
    
    nVar = length(varIndices{1,2});
    
    varDetails = cell(length(varIndices), nVar + 2);
    
    for iVar = 1:length(varIndices)
        unitVarLineSplitString = strsplit(endParFileData{varIndices{iVar,2}(1)});
        % Store the variable units
        varDetails{iVar,nVar + 1} = unitVarLineSplitString(4);
        % Store the variable name
        varDetails{iVar,nVar + 2} = varIndices{iVar,1};

        %Store the variable for each instance of the variable found
        for iInstance = 1:length(varIndices{1,2})
            unitVarSplitString = strsplit(endParFileData{varIndices{iVar,2}(iInstance)});
            varDetails(iVar, iInstance) = unitVarSplitString(2);
        end
    end
    
end