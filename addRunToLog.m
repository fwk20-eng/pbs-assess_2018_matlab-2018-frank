%% Function Description
%
% Write the assessment results to the log file
%
%% Inputs
%
% * Project
% * Is
% * r
%
%% Outputs
%
% * None: log file is appended
%
%% Change Log
%
% [0.2.0] - 2017-09-26
%
% *Added*
%
% * Write a log file in the specific run folder
%
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * Modified output to suit markdown text
% * Axle loads
% * GCM
% * Drive axle load ratio
%
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * Moved from Post Processor to its own function file

function addRunToLog(Project, Is, resultsWithLevel, axleLoading, Axle)

runLogName = 'runLog.md';
runLogPath = strcat(Project.resultsDirectory, '\', runLogName);

% Create file if it does not already exist
if ~exist(runLogPath, 'file')
    fRunLog = fopen(runLogPath,'a');
    fclose(fRunLog);
end

originalLogFileData = readLinesFromFile(runLogPath);
appendLogFileData = {};
appendLogFileData = [appendLogFileData; ['# ', datestr(now,'yyyy-mm-dd'), ': ' ,Project.runKey]];
appendLogFileData = [appendLogFileData; ' '; '## Run Notes'; ' '];

for i = 1:length(Project.runNotes)
    appendLogFileData = [appendLogFileData; Project.runNotes{i,1}];
end

appendLogFileData = [appendLogFileData; ' '; '## Axle loading'; ' '];

%% Generate axle loading cell for markdown table
axleLoading = num2cell(axleLoading);
axleLoadingHeadings = {'**Axle**'; '**LoadSharing 1**'; '**Laden (kg)**'; '**Unladen (kg)**'; '**LoadSharing 2**';...
    '**Laden (kg)**'; '**Unladen (kg)**'};
AxleLoading.data = [axleLoadingHeadings, axleLoading];
markdownAxleLoading = markdownTable(AxleLoading);
appendLogFileData = [appendLogFileData; markdownAxleLoading; ' '];

%% If axle loads are extracted from Trucksim, then add the comparison to log file
if Is.axle
    appendLogFileData = [appendLogFileData; ' '; '### Axle loading comparison with TruckSim'; ' '];
    axleComparison = num2cell(Axle.truckSimLoads);
    axleComparisonHeadings = {'**Axle**'; '**TruckSim Loads (kg)**'; '**Matlab Loads (kg)**'; '**Difference (kg)**';...
        '**Difference (%)**'};
    AxleComparison.data = [axleComparisonHeadings, axleComparison];
    markdownAxleLoadComparison = markdownTable(AxleComparison);
    appendLogFileData = [appendLogFileData; markdownAxleLoadComparison; ' '];
end

appendLogFileData = [appendLogFileData; ' '; '## CGM and Traction Check'; ' '];

%% Adding a table for GCM and drive axle load
gcmHeadings = {'**GCM**', '**Drive axle load (kg)**', '**Drive axle load ratio (>20%)**'};
gcmData = {num2str(Axle.gcm), num2str(Axle.driveAxleLoad, '%0.0f'), num2str(Axle.driveAxleLoadRatio*100, '%0.2f')};
GcmTable.data = [gcmHeadings; gcmData];
markdownGCMTable = markdownTable(GcmTable);
appendLogFileData = [appendLogFileData; markdownGCMTable; ' '];

appendLogFileData = [appendLogFileData; '## Results'; ' '];

if Is.pbs
    ResultsWithLevel.data = resultsWithLevel;
    markdownResultsTable = markdownTable(ResultsWithLevel);
    appendLogFileData = [appendLogFileData; markdownResultsTable; ' '];
end

newLogFileData = appendLogFileData;
% Write the latest assessment data first
appendLogFileData = [appendLogFileData; originalLogFileData];

% Write results to a global run log file
fid = fopen(runLogPath,'w');

nRows = length(appendLogFileData);

for iRow = 1 : nRows
    fprintf(fid,'%s\n', appendLogFileData{iRow});
end

fclose(fid);

localRunLogPath = strcat(Project.runFolderPath, '\Results-Summary_', Project.revision, '.md');
% Write the results to a local run file for the current run
fid = fopen(localRunLogPath,'w');

nRows = length(newLogFileData);

for iRow = 1 : nRows
    fprintf(fid,'%s\n', newLogFileData{iRow});
end

fclose(fid);


end