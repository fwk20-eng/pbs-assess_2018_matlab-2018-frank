%% Function Description
%
% Writes the results to excel if a full PBS assessment was conducted
%
%% Inputs
%
% * Lim
% * fullName
% * nLevels
% * Project
% * AxleLoading
% * Is
% * roundAxleLoading
% * r
% * Combination
%
%% Outputs
%
% * None. Results are written to the excel file for the current run
%
%% Change Log
%
% [0.1.0] - 2017-05-14
%
% *Added*
%
% * Moved from the Post Processor to its own file

function writeToExcelPbsResults(Lim, fullName, nLevels, Project, AxleLoading, Is, roundAxleLoading, r, Combination,...
    resultsWithLevel)

if Is.fullPBS && Is.save
    results_round = rounder(r, Is);
    printResultsPBSnotes(resultsWithLevel, Project.savePath, 'results', 'postAxleLoad',...
        AxleLoading, Project.resultsFileName, Project.runNotes);
    printResultsPBS(results_round, Lim, fullName, nLevels, Project.savePath, 'resultsRounded', 'postAxleLoadRounded',...
        roundAxleLoading, Is.semi, Project.resultsFileName);
end

if Is.fullPBS && Is.plotSummary
    runSummaryChart(fullName, r, Lim, Combination.pbsLevelDesired, Project.savePath, Project.runKey, Is.semi)
end

end