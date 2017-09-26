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
% [0.2.0] - 2017-06-24
%
% *Added*
%
% * Ability to extract data from a manoeuvre that is being run when only a partial run is being conducted.
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

checkOverwrite(Project.savePath, Project.resultsFileName); %Note: xlswrite1 cannot handle creating a directory, so it is manually created in checkOverwrite if it does not exist

%% Determining which matkey to use to extract the information

if ~Is.fullPBS
    if Is.lst
        MatKey.Extraction = MatKey.lst{1};
    elseif Is.lsunt
        MatKey.Extraction = MatKey.lsunt{1};
    elseif Is.yawD
        MatKey.Extraction = MatKey.yawD{1};
    elseif Is.ra
        MatKey.Extraction = MatKey.ra{1};
    elseif Is.hsto
        MatKey.Extraction = MatKey.hsto{1};
    elseif Is.tasp
        MatKey.Extraction = MatKey.tasp{1};
    elseif Is.srt
        MatKey.Extraction = MatKey.srt{1};
    elseif Is.long % Use LST if long is being run alone
        MatKey.Extraction = MatKey.long{1};    
    elseif Is.axle % Use LST if long is being run alone
        MatKey.Extraction = MatKey.axle{1};
    end
else
    % If all manoeuvres are being run at the same time, use the LST maneouvre
    MatKey.Extraction = MatKey.lst{1};
end

%% Generating par file filenames
ParDetails.parFileFolderPath = strcat(Project.savePath, '\', Project.runKey, '_raw_files');

% Laden par files from one of the manoeuvres that is currently being run
ParDetails.endParLadenFileName = strcat(Project.runKey, '_', MatKey.Extraction, '_end.par');
ParDetails.allParLadenFileName = strcat(Project.runKey, '_', MatKey.Extraction, '_all.par');

% Only run the unladen LST maneouve if it is selected, otherwise unladen parameters are not required
if Is.lsunt
    % Unladen par files from the LSunT manoeuvre
    ParDetails.endParUnladenFileName = strcat(Project.runKey, '_', MatKey.lsunt{1}, '_end.par');
    ParDetails.allParUnladenFileName = strcat(Project.runKey, '_', MatKey.lsunt{1}, '_all.par');
end
end