%% Function Description
% 
% Remove the .m files from the TruckSim database runs folder to prevent duplicate .m files in a future run
% 
%% Inputs
% 
% * Project
% * Is
% 
%% Outputs
% 
% * None. If .m files exist in the TruckSim database runs folder, they will be removed.
% 
%% Change Log
% 
% [0.1.0] - 2017-05-14
% 
% *Added*
% 
% * Moved from Post Process to its own function file

function removeMFilesFromTruckSimRunsFolder(Project, Is)
    if Is.removeMFiles == 1
        RemoveMfiles = questdlg('Would you like to delete the .mat files in the run folder?', 'Delete .m files?', 'Yes', 'No', 'No');
        if strcmp(RemoveMfiles, 'Yes')
            f = fullfile(Project.truckSimRunsPath, '*.mat');
            delete(f);
        else if strcmp(RemoveMfiles, 'No')
                msgbox('.mat files not deleted in the run folder.');
            end
        end
    end
end