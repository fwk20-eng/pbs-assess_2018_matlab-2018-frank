%% Function Description
% 
% Writes the run log for the assessment
% 
%% Inputs
% 
% * Is
% * Project
% 
%% Outputs
% 
% * None, a text file is written in the project folder with the run notes.
% 
%% Change Log
% 
% [0.1.0] - 2017-05-14
% 
% *Added*
% 
% * Moved from the main Post Processor

function createRunLog(Is, Project)
if Is.log %Write run notes and revision to text file
    runLogName = 'runLog.txt';
    runLogPath = strcat(Project.resultsFolderPath, '\', runLogName);
    fRunLog = fopen(runLogPath,'a');
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    fprintf(fRunLog,strcat(datestr(now,'yyyy-mm-dd'), ':\t' ,Project.runKey, '\n'));
    fprintf(fRunLog,'-------------------------------------------------------------------------------------\n');
    
    for i = 1:length(Project.runNotes)
        fprintf(fRunLog, Project.runNotes{i,1});
        fprintf(fRunLog,'\n');
    end
    fprintf(fRunLog,'\nComments:\n');
    fclose(fRunLog);
end
end