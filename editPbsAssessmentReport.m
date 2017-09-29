%% Function Description
%
% Edit the latex report for PBS assessments
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

function editPbsAssessmentReport(Report, Is)

PbsReportFileData = readLinesFromFile(Report.pbsAssessmentMainTexFilePath);

nModifiers = length(Report.modifiers);

for iModifier = 1 : nModifiers
    PbsReportFileData = editLinesInCellArray(PbsReportFileData, Report.modifiers{iModifier,1},...
        Report.modifiers{iModifier,2}, '(?<=\}\{).*(?=\}\>)');
end

% Modify the date the report was generated and version. Cannot use it in report modifiers due to different regexp
date = strsplit(datestr(now,'yyyy-mmmm-dd'),'-');
PbsReportFileData = editLinesInCellArray(PbsReportFileData, '\\ReportDay', date(3), '(?<=\{).*(?=\})');
PbsReportFileData = editLinesInCellArray(PbsReportFileData, '\\ReportMonth', date(2), '(?<=\{).*(?=\})');
PbsReportFileData = editLinesInCellArray(PbsReportFileData, '\\ReportYear', date(1), '(?<=\{).*(?=\})');
PbsReportFileData = editLinesInCellArray(PbsReportFileData, '\\ReportRev', Report.reportRevision, '(?<=\{).*(?=\})');

% Modify the report type to suit the combination being assessed
PbsReportFileData = editLinesInCellArray(PbsReportFileData, ['\\togglefalse\{', Report.vehicleType], 'true', '(?<=toggle).*(?=\{)');

% Write main tex file
fid = fopen(Report.pbsAssessmentMainTexFilePath,'w');

nRows = length(PbsReportFileData);

for iRow = 1 : nRows
    fprintf(fid,'%s\n',PbsReportFileData{iRow});
end

fclose(fid);

% Rename the latex report main tex file
movefile(Report.pbsAssessmentMainTexFilePath, Report.pbsAssessmentRenamedTexFilePath);

% Generate the latex results table
if Is.carCarrier
    ResultsTable.data = [Report.pbsResultsTable(:,1:2) Report.pbsBaselineResultsTable Report.pbsResultsTable(:,3:4) ...
        Report.pbsResultsTableTopdeck Report.pbsResultsTable(:,5:8)];
    
    ResultsTable.multiHeading = {'\multicolumn{1}{c|}{\multirow{3}[2]{*}{\textbf{Standard}}} & \multirow{3}[2]{*}{\begin{sideways}\textbf{Units}\end{sideways}} & \multicolumn{2}{c|}{Baseline} & \multicolumn{2}{c|}{Fully Laden PBS} & \multicolumn{2}{c|}{Topdeck Laden PBS} & \multicolumn{4}{c}{PBS} \\';...
        '      &       & \multicolumn{2}{c|}{Combination} & \multicolumn{2}{c|}{Combination} & \multicolumn{2}{c|}{Combination} & \multicolumn{4}{c}{Performance Requirements}\\';...
        '      &       & \textbf{Result} & \textbf{PBS Level} & \textbf{Result} & \textbf{PBS Level} & \textbf{Result} & \textbf{PBS Level} & \textbf{Level 1} & \textbf{Level 2} & \textbf{Level 3} & \textbf{Level 4}\\'};
    
    ResultsTable.tablePackage = 'tabulary';
    ResultsTable.userAlignment = 'l|c|cc|cc|cc|cccc';
else
    ResultsTable.data = [Report.pbsResultsTable(:,1:2) Report.pbsBaselineResultsTable Report.pbsResultsTable(:,3:8)];
    
    ResultsTable.multiHeading = {'\multicolumn{1}{c|}{\multirow{3}[2]{*}{\textbf{Standard}}} & \multirow{3}[2]{*}{\begin{sideways}\textbf{Units}\end{sideways}} & \multicolumn{2}{c|}{Baseline} & \multicolumn{2}{c|}{PBS} & \multicolumn{4}{c}{PBS} \\';...
        '      &       & \multicolumn{2}{c|}{Combination} & \multicolumn{2}{c|}{Combination} & \multicolumn{4}{c}{Performance Requirements}\\';...
        '      &       & \textbf{Result} & \textbf{PBS Level} & \textbf{Result} & \textbf{PBS Level} & \textbf{Level 1} & \textbf{Level 2} & \textbf{Level 3} & \textbf{Level 4}\\'};
    
    ResultsTable.tablePackage = 'tabulary';
    ResultsTable.userAlignment = 'l|c|cc|cc|cccc';
end

ResultsTable.booktabs = 1;
ResultsTable.tableBorders = 0;
ResultsTable.footNotes = {'\item[1] MoD/DoM performance relaxation approved by the SMART Truck Review Panel for vehicles assessed and operating in South Africa';
    '\item[2] TASP performance relaxation approved by the SMART Truck Review Panel for vehicles assessed and operating in South Africa'};
ResultsTable.tableCaption = 'PBS Assessment Results';
ResultsTable.tableLabel = 'Results';
resultsTableLatexCode = latexTable(ResultsTable);

% Write results tex file
fid = fopen(Report.pbsAssessmentResultsTexFilePath,'w');

nRows = length(resultsTableLatexCode);

for iRow = 1 : nRows
    fprintf(fid,'%s\n',resultsTableLatexCode{iRow});
end

fclose(fid);

end
