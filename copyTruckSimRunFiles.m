%% Function Description
%
% Copy the relevant TruckSim run files to the PBS assessment folder
%
%% Inputs
%
% * MatKey
% * Project
%
%% Outputs
%
% * Copied TruckSim run files
%
%% Change Log
%
% [1.0.0] - 2017-07-03
%
% * Modified for TruckSim 2017.1
%
% [0.1.0] - 2017-05-14
%
% *Added*
%
% * Moved from Post Processor to its own function file

function copyTruckSimRunFiles(MatKey, Project, Is)

keyFields = fieldnames(MatKey);
nManoeuvres = length(keyFields);

for iManoeuvre = 1 : nManoeuvres
    if Is.(keyFields{iManoeuvre})
        % Note the filename and error are not used anywhere, hence the tilde ignores the values
        [~, ~] = copySimulationFiles(MatKey.(keyFields{iManoeuvre}){1}, MatKey.(keyFields{iManoeuvre})(2), Project.savePath,...
            Project.truckSimRunsPath, Project.runKey, 1);
    end
end

end