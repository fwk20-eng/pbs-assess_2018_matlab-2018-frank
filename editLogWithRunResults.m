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
% [0.1.0] - 2017-01-01
%
% *Added*
%
% * Moved from Post Processor to its own function file

function editLogWithRunResults(Project, Is, r)

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
    
    fprintf(fRunLog,'\nResults:\n');
    
    if Is.pbs
        resultTable = struct2table(r);
        resultLog = [resultTable.Properties.VariableNames; table2cell(resultTable)];
        
        for i = 1:length(resultLog)
            fprintf(fRunLog, strcat(resultLog{1,i},': ', num2str(resultLog{2,i}), '\n'));
        end
        
        fprintf(fRunLog,'\nComments:\n');
    end
    fclose(fRunLog);
end

end