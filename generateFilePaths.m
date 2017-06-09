%% Function Description
% 
% Describe the function here
% 
%% Inputs
% 
% * variable: description
% 
%% Outputs
% 
% * variable: description
% 
%% Change Log
% 
% [0.1.0] - 2017-01-01
% 
% *Added*
% 
% * First code

function [Project, ParDetails, Is] = generateFilePaths(Project, MatKey, Is)

disp('-------------------------------------------------------------------------------------')
disp('	Next Run')
disp('-------------------------------------------------------------------------------------')
%% Run Details
disp('-------------------------------------------------------------------------------------')
disp('	Run Notes')
disp('-------------------------------------------------------------------------------------')

display(Project.runNotes); %Do not suppress
%% Generating project folders/filenames

Project.savePath = sprintf('%s%s%s%s',Project.runFolderPath, '\', datestr(now,'yyyy-mm-dd'), '_', Project.revision);
Project.runKey = sprintf('%s%s%s',Project.key,'_',Project.revision);
Project.resultsFileName = strcat(Project.runKey, '_summary.xlsx');

if Is.save
    checkOverwrite(Project.savePath, Project.resultsFileName); %Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist
end

%% Generating par file filenames
ParDetails.parFileFolderPath = strcat(Project.savePath, '\', Project.runKey, '_raw_files');

% Laden par files from the LST manoeuvre
ParDetails.endParLadenFileName = strcat(Project.runKey, '_', MatKey.lst, '_end.par');
ParDetails.allParLadenFileName = strcat(Project.runKey, '_', MatKey.lst, '_all.par');

% Unladen par files from the LSunT manoeuvre
ParDetails.endParUnladenFileName = strcat(Project.runKey, '_', MatKey.lsunt, '_end.par');
ParDetails.allParUnladenFileName = strcat(Project.runKey, '_', MatKey.lsunt, '_all.par');

%% Run-checks, resetting booleans if necessary

if Is.fullPBS == 1 %Turns on all PBS manoeuvres
    Is.lst = 1;      Is.yawD = 1;     Is.hsto = 1;     Is.long = 1;
    Is.lsunt = 1;    Is.ra = 1;       Is.tasp = 1;     Is.srt = 1;
end

if ~Is.fullPBS
    Is.plotSummary = false; %Turns off plot summary if not a full PBS assessment
end
end